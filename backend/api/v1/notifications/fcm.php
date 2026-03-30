<?php
/**
 * POST /api/v1/notifications/fcm
 *
 * Save or update a device FCM token for push notifications.
 * Requires JWT authentication.
 *
 * Request body (JSON):
 *   {
 *     "token":    "<FCM registration token>",
 *     "platform": "android"   (android|ios|web, default: android)
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
$auth   = requireAuth();
$userId = (int)$auth['user_id'];

$body = getRequestBody();

// Default platform.
$body['platform'] = $body['platform'] ?? 'android';

// --- Validate ---
$v = new Validator($body);
$v->required(['token'])
  ->min('token', 10)
  ->max('token', 500)
  ->in('platform', ['android', 'ios', 'web']);

if ($v->fails()) {
    sendError('Validation failed.', 422, $v->errors());
}

$token    = trim($body['token']);
$platform = $body['platform'];

try {
    $db = (new Database())->getConnection();

    // Upsert: if the same token already exists (possibly for another user), re-assign it.
    $upsert = $db->prepare(
        'INSERT INTO device_tokens (user_id, token, platform)
         VALUES (:user_id, :token, :platform)
         ON DUPLICATE KEY UPDATE user_id = :user_id2, platform = :platform2'
    );
    $upsert->execute([
        ':user_id'   => $userId,
        ':token'     => $token,
        ':platform'  => $platform,
        ':user_id2'  => $userId,
        ':platform2' => $platform,
    ]);

    // Return how many tokens this user now has registered.
    $countStmt = $db->prepare(
        'SELECT COUNT(*) FROM device_tokens WHERE user_id = :user_id'
    );
    $countStmt->execute([':user_id' => $userId]);
    $tokenCount = (int)$countStmt->fetchColumn();

} catch (RuntimeException $e) {
    sendServerError($e->getMessage());
} catch (PDOException $e) {
    error_log('[Ayur FCM] ' . $e->getMessage());
    sendServerError();
}

sendSuccess('Device token registered successfully.', [
    'user_id'      => $userId,
    'platform'     => $platform,
    'token_count'  => $tokenCount,
]);
