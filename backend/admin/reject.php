<?php
/**
 * Reject Provider Registration
 */

session_start();
require_once '../config/db.php';

// Check if admin is logged in
if (!isset($_SESSION['logged_in']) || $_SESSION['user_role'] !== 'admin') {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized']);
    exit();
}

// Get POST data
$data = json_decode(file_get_contents('php://input'), true);
$type = $data['type'] ?? '';
$id = $data['id'] ?? 0;

$allowed_types = ['doctors', 'hospitals', 'clinics', 'pharmacies'];
if (!in_array($type, $allowed_types) || $id <= 0) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid request']);
    exit();
}

try {
    $pdo = getDB();
    $temp_table = "temp_" . $type;
    
    // Update status to rejected
    $stmt = $pdo->prepare("UPDATE $temp_table SET status = 'rejected' WHERE id = ? AND status = 'pending'");
    $stmt->execute([$id]);
    
    if ($stmt->rowCount() === 0) {
        http_response_code(404);
        echo json_encode(['error' => 'Request not found']);
        exit();
    }
    
    header('Content-Type: application/json');
    echo json_encode(['success' => true, 'message' => 'Provider rejected']);
    
} catch (PDOException $e) {
    error_log("Rejection Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Database error']);
}
?>
