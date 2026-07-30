<?php
/**
 * Lightweight HS256 JWT implementation.
 *
 * Usage:
 *   $token  = JWTHelper::generate(['user_id' => 1, 'role' => 'patient']);
 *   $payload = JWTHelper::validate($token);   // returns array or throws
 */
class JWTHelper {
    /** HMAC-SHA256 secret — must be set via JWT_SECRET env var in production. */
    private static string $secret = 'Ayur_Sup3r_S3cr3t_JWT_K3y_2024!@#$';

    /** Token lifetime in seconds (7 days). */
    private const TTL = 604800;

    // ------------------------------------------------------------------ //
    // Public API
    // ------------------------------------------------------------------ //

    /**
     * Generate a signed JWT token.
     *
     * @param  array<string, mixed> $payload  Custom claims to embed.
     * @return string  Signed JWT string.
     */
    public static function generate(array $payload): string {
        $secret = self::resolveSecret();

        $header = self::base64UrlEncode(json_encode([
            'alg' => 'HS256',
            'typ' => 'JWT',
        ], JSON_THROW_ON_ERROR));

        $now            = time();
        $payload['iat'] = $now;
        $payload['exp'] = $now + self::TTL;
        $payload['iss'] = 'ayur-api';

        $encodedPayload = self::base64UrlEncode(json_encode($payload, JSON_THROW_ON_ERROR));

        $signature = self::base64UrlEncode(
            hash_hmac('sha256', "{$header}.{$encodedPayload}", $secret, true)
        );

        return "{$header}.{$encodedPayload}.{$signature}";
    }

    /**
     * Validate a JWT token and return its payload.
     *
     * @param  string $token  Raw JWT string (may include "Bearer " prefix).
     * @return array<string, mixed>  Decoded payload.
     * @throws RuntimeException  On any validation failure.
     */
    public static function validate(string $token): array {
        $secret = self::resolveSecret();

        // Strip optional Bearer prefix.
        $token = preg_replace('/^Bearer\s+/i', '', trim($token));

        $parts = explode('.', $token);
        if (count($parts) !== 3) {
            throw new RuntimeException('Invalid token structure.', 401);
        }

        [$header, $payload, $providedSig] = $parts;

        // Verify signature.
        $expectedSig = self::base64UrlEncode(
            hash_hmac('sha256', "{$header}.{$payload}", $secret, true)
        );

        if (!hash_equals($expectedSig, $providedSig)) {
            throw new RuntimeException('Token signature is invalid.', 401);
        }

        // Decode payload.
        $decoded = json_decode(self::base64UrlDecode($payload), true, 512, JSON_THROW_ON_ERROR);

        if (!is_array($decoded)) {
            throw new RuntimeException('Token payload is malformed.', 401);
        }

        // Check expiry.
        if (isset($decoded['exp']) && $decoded['exp'] < time()) {
            throw new RuntimeException('Token has expired. Please log in again.', 401);
        }

        // Check issuer.
        if (($decoded['iss'] ?? '') !== 'ayur-api') {
            throw new RuntimeException('Token issuer is invalid.', 401);
        }

        return $decoded;
    }

    // ------------------------------------------------------------------ //
    // Private helpers
    // ------------------------------------------------------------------ //

    private static function resolveSecret(): string {
        $secret = getenv('JWT_SECRET');
        if ($secret !== false && $secret !== '') {
            return $secret;
        }
        // Reject empty secret in production.
        $env = getenv('APP_ENV') ?: 'development';
        if ($env === 'production') {
            throw new RuntimeException('JWT_SECRET environment variable must be set in production.', 500);
        }
        return self::$secret;
    }

    private static function base64UrlEncode(string $data): string {
        return rtrim(strtr(base64_encode($data), '+/', '-_'), '=');
    }

    private static function base64UrlDecode(string $data): string {
        $padded = str_pad(strtr($data, '-_', '+/'), strlen($data) + (4 - strlen($data) % 4) % 4, '=');
        $decoded = base64_decode($padded, true);
        if ($decoded === false) {
            throw new RuntimeException('Token base64 decoding failed.', 401);
        }
        return $decoded;
    }
}

/**
 * Middleware helper — extract authenticated user from Authorization header.
 * Calls sendUnauthorized() and exits on failure.
 *
 * @return array<string, mixed>  JWT payload (includes user_id, role, etc.)
 */
function requireAuth(): array {
    $authHeader = $_SERVER['HTTP_AUTHORIZATION']
        ?? (function_exists('apache_request_headers') ? (apache_request_headers()['Authorization'] ?? '') : '');

    if (empty($authHeader)) {
        sendUnauthorized('Authorization header is missing.');
    }

    try {
        return JWTHelper::validate($authHeader);
    } catch (RuntimeException $e) {
        sendUnauthorized($e->getMessage());
    }
}
