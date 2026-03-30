<?php
/**
 * Centralised JSON response helper.
 * Always sends Content-Type: application/json and terminates execution.
 */

function sendResponse(int $status, bool $success, string $message, array $data = [], array $meta = []): never {
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');

    $body = [
        'success' => $success,
        'message' => $message,
    ];

    if (!empty($data)) {
        $body['data'] = $data;
    }

    if (!empty($meta)) {
        $body['meta'] = $meta;
    }

    echo json_encode($body, JSON_UNESCAPED_UNICODE | JSON_UNESCAPED_SLASHES);
    exit();
}

function sendSuccess(string $message, array $data = [], array $meta = [], int $status = 200): never {
    sendResponse($status, true, $message, $data, $meta);
}

function sendError(string $message, int $status = 400, array $errors = []): never {
    $data = [];
    if (!empty($errors)) {
        $data['errors'] = $errors;
    }
    sendResponse($status, false, $message, $data);
}

function sendUnauthorized(string $message = 'Unauthorized. Please log in.'): never {
    sendError($message, 401);
}

function sendForbidden(string $message = 'Access denied.'): never {
    sendError($message, 403);
}

function sendNotFound(string $message = 'Resource not found.'): never {
    sendError($message, 404);
}

function sendMethodNotAllowed(string $message = 'Method not allowed.'): never {
    sendError($message, 405);
}

function sendServerError(string $message = 'An unexpected server error occurred.'): never {
    sendError($message, 500);
}
