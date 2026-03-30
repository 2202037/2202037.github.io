<?php
/**
 * POST /api/v1/blood_bank/request
 *
 * Submit a blood request. Requires JWT authentication.
 *
 * Request body (JSON):
 *   {
 *     "blood_group":   "O+",
 *     "quantity":      2,
 *     "urgency":       "urgent",       (normal|urgent|critical)
 *     "hospital_name": "City Hospital",
 *     "notes":         "Post-surgery"   (optional)
 *   }
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
$auth        = requireAuth();
$requesterId = (int)$auth['user_id'];

$body = getRequestBody();

// Normalize blood group to uppercase.
if (isset($body['blood_group'])) {
    $body['blood_group'] = strtoupper(trim($body['blood_group']));
}

// Default urgency.
$body['urgency'] = $body['urgency'] ?? 'normal';

// --- Validate ---
$validGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];

$v = new Validator($body);
$v->required(['blood_group', 'quantity', 'urgency', 'hospital_name'])
  ->in('blood_group', $validGroups)
  ->positiveInt('quantity')
  ->in('urgency', ['normal', 'urgent', 'critical'])
  ->max('hospital_name', 200);

if ($v->fails()) {
    sendError('Validation failed.', 422, $v->errors());
}

$bloodGroup   = $body['blood_group'];
$quantity     = (int)$body['quantity'];
$urgency      = $body['urgency'];
$hospitalName = sanitizeString($body['hospital_name']);
$notes        = isset($body['notes']) ? sanitizeString($body['notes']) : null;

try {
    $db = (new Database())->getConnection();

    $insert = $db->prepare(
        'INSERT INTO blood_requests (requester_id, blood_group, quantity, urgency, hospital_name, notes)
         VALUES (:requester_id, :blood_group, :quantity, :urgency, :hospital_name, :notes)'
    );
    $insert->execute([
        ':requester_id' => $requesterId,
        ':blood_group'  => $bloodGroup,
        ':quantity'     => $quantity,
        ':urgency'      => $urgency,
        ':hospital_name'=> $hospitalName,
        ':notes'        => $notes,
    ]);
    $requestId = (int)$db->lastInsertId();

    // Return created request.
    $fetch = $db->prepare(
        'SELECT id, requester_id, blood_group, quantity, urgency, status,
                hospital_name, notes, created_at
         FROM blood_requests WHERE id = :id LIMIT 1'
    );
    $fetch->execute([':id' => $requestId]);
    $request = $fetch->fetch();

    $request['id']           = (int)$request['id'];
    $request['requester_id'] = (int)$request['requester_id'];
    $request['quantity']     = (int)$request['quantity'];

    // Check current inventory for context.
    $invStmt = $db->prepare(
        'SELECT quantity FROM blood_inventory WHERE blood_group = :bg LIMIT 1'
    );
    $invStmt->execute([':bg' => $bloodGroup]);
    $inv = $invStmt->fetch();
    $request['available_units'] = $inv ? (int)$inv['quantity'] : 0;

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur blood request] ' . $e->getMessage());
    sendServerError();
}

sendSuccess('Blood request submitted successfully.', ['request' => $request], [], 201);
