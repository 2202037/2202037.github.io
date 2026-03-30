<?php
/**
 * GET  /api/v1/auth/profile  — Retrieve authenticated user's profile.
 * PUT  /api/v1/auth/profile  — Update authenticated user's profile.
 *
 * Authorization: Bearer <token>
 *
 * PUT body (JSON, all fields optional):
 *   { "name": "...", "phone": "...", "address": "...", "profile_image": "..." }
 */

declare(strict_types=1);

require_once __DIR__ . '/../../../config/cors.php';
require_once __DIR__ . '/../../../config/response.php';
require_once __DIR__ . '/../../../config/database.php';
require_once __DIR__ . '/../../../helpers/jwt.php';
require_once __DIR__ . '/../../../helpers/validator.php';

setCorsHeaders();
header('Content-Type: application/json; charset=utf-8');

$method = $_SERVER['REQUEST_METHOD'];

if (!in_array($method, ['GET', 'PUT'], true)) {
    sendMethodNotAllowed();
}

// --- Auth ---
$auth = requireAuth();
$userId = (int)$auth['user_id'];

try {
    $db = (new Database())->getConnection();
} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
}

// ============================================================
// GET — return profile
// ============================================================
if ($method === 'GET') {
    $stmt = $db->prepare(
        'SELECT u.id, u.name, u.email, u.role, u.phone, u.profile_image, u.address,
                u.created_at, u.updated_at,
                d.specialty, d.fee, d.experience_years, d.bio, d.rating AS doctor_rating,
                d.is_available, d.clinic_id
         FROM users u
         LEFT JOIN doctors d ON d.user_id = u.id
         WHERE u.id = :id
         LIMIT 1'
    );
    $stmt->execute([':id' => $userId]);
    $user = $stmt->fetch();

    if (!$user) {
        sendNotFound('User not found.');
    }

    // Cast numeric fields.
    $user['id']           = (int)$user['id'];
    $user['fee']          = $user['fee'] !== null          ? (float)$user['fee']          : null;
    $user['experience_years'] = $user['experience_years'] !== null ? (int)$user['experience_years'] : null;
    $user['doctor_rating']    = $user['doctor_rating'] !== null    ? (float)$user['doctor_rating']   : null;
    $user['is_available']     = $user['is_available'] !== null     ? (bool)$user['is_available']     : null;
    $user['clinic_id']        = $user['clinic_id'] !== null        ? (int)$user['clinic_id']         : null;

    sendSuccess('Profile retrieved successfully.', ['user' => $user]);
}

// ============================================================
// PUT — update profile
// ============================================================
if ($method === 'PUT') {
    $body = getRequestBody();

    $updatable = ['name', 'phone', 'address', 'profile_image'];
    $fields    = [];
    $params    = [':id' => $userId];

    $v = new Validator($body);

    if (isset($body['name'])) {
        $v->min('name', 2)->max('name', 150);
        $fields[]         = 'name = :name';
        $params[':name']  = sanitizeString($body['name']);
    }
    if (isset($body['phone'])) {
        $v->phone('phone');
        $fields[]          = 'phone = :phone';
        $params[':phone']  = sanitizeString($body['phone']);
    }
    if (isset($body['address'])) {
        $fields[]            = 'address = :address';
        $params[':address']  = sanitizeString($body['address']);
    }
    if (isset($body['profile_image'])) {
        $fields[]                    = 'profile_image = :profile_image';
        $params[':profile_image']    = sanitizeString($body['profile_image']);
    }

    if ($v->fails()) {
        sendError('Validation failed.', 422, $v->errors());
    }

    if (empty($fields)) {
        sendError('No updatable fields provided.', 400);
    }

    try {
        $sql  = 'UPDATE users SET ' . implode(', ', $fields) . ' WHERE id = :id';
        $stmt = $db->prepare($sql);
        $stmt->execute($params);

        // Return updated record.
        $fetch = $db->prepare(
            'SELECT id, name, email, role, phone, profile_image, address, updated_at
             FROM users WHERE id = :id LIMIT 1'
        );
        $fetch->execute([':id' => $userId]);
        $updated = $fetch->fetch();
        $updated['id'] = (int)$updated['id'];

        sendSuccess('Profile updated successfully.', ['user' => $updated]);
    } catch (PDOException $e) {
        error_log('[Ayur profile PUT] ' . $e->getMessage());
        sendServerError();
    }
}
