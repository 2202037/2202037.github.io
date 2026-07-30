<?php
/**
 * GET /api/v1/appointments/my
 *
 * Returns appointments for the authenticated user.
 * Doctors see appointments where they are the doctor.
 * Patients see appointments where they are the patient.
 *
 * Query params (all optional):
 *   status — filter by status: pending|confirmed|completed|cancelled
 *   page   — default 1
 *   limit  — default 10, max 50
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

if ($_SERVER['REQUEST_METHOD'] !== 'GET') {
    sendMethodNotAllowed();
}

// --- Auth ---
$auth   = requireAuth();
$userId = (int)$auth['user_id'];
$role   = $auth['role'];

// --- Params ---
$page   = max(1, (int)($_GET['page']  ?? 1));
$limit  = min(50, max(1, (int)($_GET['limit'] ?? 10)));
$offset = ($page - 1) * $limit;
$status = trim($_GET['status'] ?? '');

$allowedStatuses = ['pending', 'confirmed', 'completed', 'cancelled'];
if ($status !== '' && !in_array($status, $allowedStatuses, true)) {
    sendError('Invalid status filter. Allowed: ' . implode(', ', $allowedStatuses), 422);
}

try {
    $db = (new Database())->getConnection();

    // Determine which column to filter on.
    $roleCondition = ($role === 'doctor')
        ? 'EXISTS (SELECT 1 FROM doctors d WHERE d.id = a.doctor_id AND d.user_id = :user_id)'
        : 'a.patient_id = :user_id';

    $params = [':user_id' => $userId];

    // Build WHERE.
    $where = [$roleCondition];
    if ($status !== '') {
        $where[]          = 'a.status = :status';
        $params[':status'] = $status;
    }
    $whereSQL = 'WHERE ' . implode(' AND ', $where);

    // Count.
    $countSql  = "SELECT COUNT(*) FROM appointments a {$whereSQL}";
    $countStmt = $db->prepare($countSql);
    $countStmt->execute($params);
    $total = (int)$countStmt->fetchColumn();

    // Data.
    $sql = "SELECT
        a.id,
        a.patient_id,
        a.doctor_id,
        a.appointment_date,
        a.appointment_time,
        a.status,
        a.payment_status,
        a.notes,
        a.created_at,
        pu.name          AS patient_name,
        pu.phone         AS patient_phone,
        pu.profile_image AS patient_image,
        du.name          AS doctor_name,
        du.phone         AS doctor_phone,
        doc.specialty,
        doc.fee,
        doc.image_url    AS doctor_image,
        c.name           AS clinic_name
    FROM appointments a
    JOIN users pu   ON pu.id = a.patient_id
    JOIN doctors doc ON doc.id = a.doctor_id
    JOIN users du   ON du.id = doc.user_id
    LEFT JOIN clinics c ON c.id = doc.clinic_id
    {$whereSQL}
    ORDER BY a.appointment_date DESC, a.appointment_time DESC
    LIMIT :limit OFFSET :offset";

    $queryParams = array_merge($params, [':limit' => $limit, ':offset' => $offset]);

    $stmt = $db->prepare($sql);
    foreach ($queryParams as $key => $val) {
        if (in_array($key, [':limit', ':offset'], true)) {
            $stmt->bindValue($key, $val, PDO::PARAM_INT);
        } else {
            $stmt->bindValue($key, $val);
        }
    }
    $stmt->execute();
    $appointments = $stmt->fetchAll();

    // Cast types.
    foreach ($appointments as &$a) {
        $a['id']         = (int)$a['id'];
        $a['patient_id'] = (int)$a['patient_id'];
        $a['doctor_id']  = (int)$a['doctor_id'];
        $a['fee']        = $a['fee'] !== null ? (float)$a['fee'] : null;
    }
    unset($a);

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur my appointments] ' . $e->getMessage());
    sendServerError();
}

sendSuccess('Appointments retrieved successfully.', ['appointments' => $appointments], [
    'page'        => $page,
    'limit'       => $limit,
    'total'       => $total,
    'total_pages' => (int)ceil($total / $limit),
]);
