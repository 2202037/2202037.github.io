<?php
/**
 * Get Pending Requests for Admin Dashboard
 */

session_start();
require_once '../config/db.php';

// Check if admin is logged in
if (!isset($_SESSION['logged_in']) || $_SESSION['user_role'] !== 'admin') {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized']);
    exit();
}

// Get request type
$type = $_GET['type'] ?? '';

$allowed_types = ['doctors', 'hospitals', 'clinics', 'pharmacies'];
if (!in_array($type, $allowed_types)) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid request type']);
    exit();
}

try {
    $pdo = getDB();
    $table = "temp_" . $type;
    
    // Fetch pending requests
    $stmt = $pdo->prepare("SELECT * FROM $table WHERE status = 'pending' ORDER BY submitted_at DESC");
    $stmt->execute();
    $requests = $stmt->fetchAll();
    
    // Return JSON response
    header('Content-Type: application/json');
    echo json_encode([
        'success' => true,
        'type' => $type,
        'count' => count($requests),
        'requests' => $requests
    ]);
    
} catch (PDOException $e) {
    error_log("Pending Requests Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Database error']);
}
?>
