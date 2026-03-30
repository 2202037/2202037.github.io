<?php
/**
 * POST /api/v1/appointments/cancel
 *
 * Cancel an appointment owned by the authenticated user.
 * Doctors may also cancel appointments assigned to them.
 *
 * Request body (JSON):
 *   { "appointment_id": 5 }
 *
 * Authorization: Bearer <token>
 */

declare(strict_types=1);

require_once __DIR__ . '/../../../config/cors.php';
require_once __DIR__ . '/../../../config/response.php';
require_once __DIR__ . '/../../../config/database.php';
require_once __DIR__ . '/../../../helpers/jwt.php';
require_once __DIR__ . '/../../../helpers/validator.php';

setCorsHeaders();
header('Content-Type: application/json; charset=utf-8');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    sendMethodNotAllowed();
}

// --- Auth ---
$auth   = requireAuth();
$userId = (int)$auth['user_id'];
$role   = $auth['role'];

$body = getRequestBody();

// --- Validate ---
$v = new Validator($body);
$v->required(['appointment_id'])->positiveInt('appointment_id');

if ($v->fails()) {
    sendError('Validation failed.', 422, $v->errors());
}

$appointmentId = (int)$body['appointment_id'];

try {
    $db = (new Database())->getConnection();

    // Fetch appointment.
    $fetch = $db->prepare(
        'SELECT a.id, a.patient_id, a.doctor_id, a.status, d.user_id AS doctor_user_id
         FROM appointments a
         JOIN doctors d ON d.id = a.doctor_id
         WHERE a.id = :id
         LIMIT 1'
    );
    $fetch->execute([':id' => $appointmentId]);
    $appointment = $fetch->fetch();

    if (!$appointment) {
        sendNotFound('Appointment not found.');
    }

    // Ownership check: patient owns it OR the doctor assigned to it.
    $isPatient = ((int)$appointment['patient_id'] === $userId);
    $isDoctor  = ($role === 'doctor' && (int)$appointment['doctor_user_id'] === $userId);
    $isAdmin   = ($role === 'admin');

    if (!$isPatient && !$isDoctor && !$isAdmin) {
        sendForbidden('You do not have permission to cancel this appointment.');
    }

    // Already cancelled / completed?
    if ($appointment['status'] === 'cancelled') {
        sendError('Appointment is already cancelled.', 409);
    }
    if ($appointment['status'] === 'completed') {
        sendError('Completed appointments cannot be cancelled.', 409);
    }

    // Update status.
    $update = $db->prepare(
        'UPDATE appointments SET status = :status WHERE id = :id'
    );
    $update->execute([':status' => 'cancelled', ':id' => $appointmentId]);

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur cancel] ' . $e->getMessage());
    sendServerError();
}

sendSuccess('Appointment cancelled successfully.', [
    'appointment_id' => $appointmentId,
    'status'         => 'cancelled',
]);
