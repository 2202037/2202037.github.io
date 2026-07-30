<?php
/**
 * POST /api/v1/auth/login
 *
 * Authenticate a user and return a JWT token.
 *
 * Request body (JSON):
 *   { "email": "user@example.com", "password": "Secret@123" }
 *
 * Success 200:
 *   { "success": true, "message": "Login successful.", "data": { "token": "...", "user": {...} } }
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

// --- Validate input ---
$v = new Validator($body);
$v->required(['email', 'password'])
  ->email('email')
  ->min('password', 1);

if ($v->fails()) {
    sendError('Validation failed.', 422, $v->errors());
}

$email    = strtolower(trim($body['email']));
$password = $body['password'];

// --- Query database ---
try {
    $db   = (new Database())->getConnection();
    $stmt = $db->prepare(
        'SELECT id, name, email, password_hash, role, phone, profile_image, address
         FROM users
         WHERE email = :email
         LIMIT 1'
    );
    $stmt->execute([':email' => $email]);
    $user = $stmt->fetch();
} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur login] ' . $e->getMessage());
    sendServerError();
}

if (!$user || !password_verify($password, $user['password_hash'])) {
    sendError('Invalid email or password.', 401);
}

// --- Issue token ---
$tokenPayload = [
    'user_id' => (int)$user['id'],
    'email'   => $user['email'],
    'role'    => $user['role'],
    'name'    => $user['name'],
];

$token = JWTHelper::generate($tokenPayload);

sendSuccess('Login successful.', [
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
]);
