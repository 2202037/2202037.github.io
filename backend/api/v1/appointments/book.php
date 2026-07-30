<?php
/**
 * POST /api/v1/appointments/book
 *
 * Book a new appointment. Requires JWT authentication.
 *
 * Request body (JSON):
 *   {
 *     "doctor_id":        1,
 *     "appointment_date": "2024-08-15",
 *     "appointment_time": "10:30",
 *     "notes":            "Follow-up for hypertension."   (optional)
 *   }
 *
 * Success 201:
 *   { "success": true, "message": "Appointment booked.", "data": { "appointment": {...} } }
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
$auth      = requireAuth();
$patientId = (int)$auth['user_id'];

$body = getRequestBody();

// --- Validate ---
$v = new Validator($body);
$v->required(['doctor_id', 'appointment_date', 'appointment_time'])
  ->positiveInt('doctor_id')
  ->date('appointment_date')
  ->time('appointment_time');

if ($v->fails()) {
    sendError('Validation failed.', 422, $v->errors());
}

$doctorId        = (int)$body['doctor_id'];
$appointmentDate = $body['appointment_date'];
$appointmentTime = $body['appointment_time'];
$notes           = isset($body['notes']) ? sanitizeString($body['notes']) : null;

// Ensure date is not in the past.
if ($appointmentDate < date('Y-m-d')) {
    sendError('Appointment date cannot be in the past.', 422);
}

try {
    $db = (new Database())->getConnection();

    // Check doctor exists and is available.
    $docStmt = $db->prepare(
        'SELECT id, is_available FROM doctors WHERE id = :id LIMIT 1'
    );
    $docStmt->execute([':id' => $doctorId]);
    $doctor = $docStmt->fetch();

    if (!$doctor) {
        sendNotFound('Doctor not found.');
    }
    if (!(bool)$doctor['is_available']) {
        sendError('This doctor is currently unavailable.', 409);
    }

    // Check for time-slot conflict (same doctor, same date+time, not cancelled).
    $conflictStmt = $db->prepare(
        'SELECT id FROM appointments
         WHERE doctor_id = :doctor_id
           AND appointment_date = :date
           AND appointment_time = :time
           AND status != :cancelled
         LIMIT 1'
    );
    $conflictStmt->execute([
        ':doctor_id' => $doctorId,
        ':date'      => $appointmentDate,
        ':time'      => $appointmentTime,
        ':cancelled' => 'cancelled',
    ]);
    if ($conflictStmt->fetch()) {
        sendError('This time slot is already booked. Please choose a different time.', 409);
    }

    // Insert appointment.
    $insert = $db->prepare(
        'INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, notes)
         VALUES (:patient_id, :doctor_id, :date, :time, :notes)'
    );
    $insert->execute([
        ':patient_id' => $patientId,
        ':doctor_id'  => $doctorId,
        ':date'       => $appointmentDate,
        ':time'       => $appointmentTime,
        ':notes'      => $notes,
    ]);
    $appointmentId = (int)$db->lastInsertId();

    // Return full appointment with doctor info.
    $fetch = $db->prepare(
        'SELECT
            a.id, a.patient_id, a.doctor_id, a.appointment_date, a.appointment_time,
            a.status, a.payment_status, a.notes, a.created_at,
            u.name AS doctor_name, d.specialty, d.fee, d.image_url AS doctor_image
         FROM appointments a
         JOIN doctors d ON d.id = a.doctor_id
         JOIN users u   ON u.id = d.user_id
         WHERE a.id = :id
         LIMIT 1'
    );
    $fetch->execute([':id' => $appointmentId]);
    $appointment = $fetch->fetch();

    $appointment['id']         = (int)$appointment['id'];
    $appointment['patient_id'] = (int)$appointment['patient_id'];
    $appointment['doctor_id']  = (int)$appointment['doctor_id'];
    $appointment['fee']        = (float)$appointment['fee'];

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur book] ' . $e->getMessage());
    sendServerError();
}

sendSuccess('Appointment booked successfully.', ['appointment' => $appointment], [], 201);
