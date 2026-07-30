<?php
/**
 * Get Dashboard Statistics
 */

session_start();
require_once '../config/db.php';

// Check if admin is logged in
if (!isset($_SESSION['logged_in']) || $_SESSION['user_role'] !== 'admin') {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized']);
    exit();
}

try {
    $pdo = getDB();
    
    // Get statistics
    $stats = [];
    
    // Total doctors
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM doctors WHERE status = 'active'");
    $stats['total_doctors'] = $stmt->fetch()['count'];
    
    // Total hospitals and clinics
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM hospitals WHERE status = 'active'");
    $hospitals = $stmt->fetch()['count'];
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM clinics WHERE status = 'active'");
    $clinics = $stmt->fetch()['count'];
    $stats['total_hospitals_clinics'] = $hospitals + $clinics;
    
    // Total patients
    $stmt = $pdo->query("SELECT COUNT(*) as count FROM patients WHERE status = 'active'");
    $stats['total_patients'] = $stmt->fetch()['count'];
    
    // Pending requests
    $stmt = $pdo->query("
        SELECT 
            (SELECT COUNT(*) FROM temp_doctors WHERE status = 'pending') +
            (SELECT COUNT(*) FROM temp_hospitals WHERE status = 'pending') +
            (SELECT COUNT(*) FROM temp_clinics WHERE status = 'pending') +
            (SELECT COUNT(*) FROM temp_pharmacies WHERE status = 'pending') as count
    ");
    $stats['pending_requests'] = $stmt->fetch()['count'];
    
    header('Content-Type: application/json');
    echo json_encode(['success' => true, 'stats' => $stats]);
    
} catch (PDOException $e) {
    error_log("Stats Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Database error']);
}
?>
