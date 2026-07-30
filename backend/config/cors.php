<?php
/**
 * Sets CORS headers suitable for a mobile/web client consuming the Ayur API.
 * Call this at the very top of every endpoint file, before any output.
 */
function setCorsHeaders(): void {
    $allowed_origins = [
        'http://localhost',
        'http://localhost:3000',
        'http://localhost:8080',
        'capacitor://localhost',   // Ionic/Capacitor
        'ionic://localhost',
        'https://2202037.github.io',
    ];

    $origin = $_SERVER['HTTP_ORIGIN'] ?? '*';

    if (in_array($origin, $allowed_origins, true)) {
        header("Access-Control-Allow-Origin: {$origin}");
        header('Vary: Origin');
        header('Access-Control-Allow-Credentials: true');
    } else {
        // Wildcard for non-browser clients (native mobile apps).
        // Credentials header must NOT be sent with a wildcard origin.
        header('Access-Control-Allow-Origin: *');
    }
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Content-Type, Authorization, X-Requested-With');
    header('Access-Control-Max-Age: 86400'); // 24 h pre-flight cache

    // Handle pre-flight OPTIONS request immediately.
    if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
        http_response_code(204);
        exit();
    }
}
