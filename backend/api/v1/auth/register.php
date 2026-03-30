<?php
/**
 * POST /api/v1/auth/register
 *
 * Register a new user and return a JWT token.
 *
 * Request body (JSON):
 *   {
 *     "name":     "Jane Doe",
 *     "email":    "jane@example.com",
 *     "password": "Secret@123",
 *     "phone":    "+91-9876543210",   (optional)
 *     "role":     "patient"           (optional, default: patient)
 *   }
 *
 * Success 201:
 *   { "success": true, "message": "Registration successful.", "data": { "token": "...", "user": {...} } }
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

$body = getRequestBody();

// Set default role.
$body['role'] = $body['role'] ?? 'patient';

// --- Validate ---
$v = new Validator($body);
$v->required(['name', 'email', 'password'])
  ->email('email')
  ->min('name', 2)
  ->max('name', 150)
  ->strongPassword('password')
  ->in('role', ['patient', 'doctor', 'clinic', 'pharmacy']);  // admin not self-registerable

if (isset($body['phone'])) {
    $v->phone('phone');
}

if ($v->fails()) {
    sendError('Validation failed.', 422, $v->errors());
}

$name     = sanitizeString($body['name']);
$email    = strtolower(trim($body['email']));
$password = $body['password'];
$phone    = isset($body['phone']) ? sanitizeString($body['phone']) : null;
$role     = $body['role'];

try {
    $db = (new Database())->getConnection();

    // Check uniqueness.
    $check = $db->prepare('SELECT id FROM users WHERE email = :email LIMIT 1');
    $check->execute([':email' => $email]);
    if ($check->fetch()) {
        sendError('An account with this email already exists.', 409);
    }

    // Insert.
    $hash = password_hash($password, PASSWORD_BCRYPT, ['cost' => 12]);

    $insert = $db->prepare(
        'INSERT INTO users (name, email, password_hash, role, phone)
         VALUES (:name, :email, :password_hash, :role, :phone)'
    );
    $insert->execute([
        ':name'          => $name,
        ':email'         => $email,
        ':password_hash' => $hash,
        ':role'          => $role,
        ':phone'         => $phone,
    ]);

    $userId = (int)$db->lastInsertId();

    // Fetch the new record.
    $fetch = $db->prepare(
        'SELECT id, name, email, role, phone, profile_image, address FROM users WHERE id = :id'
    );
    $fetch->execute([':id' => $userId]);
    $user = $fetch->fetch();

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur register] ' . $e->getMessage());
    sendServerError();
}

// --- Issue token ---
$token = JWTHelper::generate([
    'user_id' => $userId,
    'email'   => $user['email'],
    'role'    => $user['role'],
    'name'    => $user['name'],
]);

sendSuccess('Registration successful.', [
    'token' => $token,
    'user'  => [
        'id'            => (int)$user['id'],
        'name'          => $user['name'],
        'email'         => $user['email'],
        'role'          => $user['role'],
        'phone'         => $user['phone'],
        'profile_image' => $user['profile_image'],
        'address'       => $user['address'],
    ],
], [], 201);
