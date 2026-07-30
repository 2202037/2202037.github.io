<?php
/**
 * Approve Provider Registration
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
    $pdo->beginTransaction();
    
    $temp_table = "temp_" . $type;
    $permanent_table = $type;
    
    // Get data from temporary table
    $stmt = $pdo->prepare("SELECT * FROM $temp_table WHERE id = ? AND status = 'pending'");
    $stmt->execute([$id]);
    $provider = $stmt->fetch();
    
    if (!$provider) {
        $pdo->rollBack();
        http_response_code(404);
        echo json_encode(['error' => 'Request not found']);
        exit();
    }
    
    // Prepare data for insertion based on type
    if ($type === 'doctors') {
        $stmt = $pdo->prepare("
            INSERT INTO $permanent_table (email, password, full_name, phone, medical_degree, 
                                          registration_no, specialization, experience_years, 
                                          consultation_fee, available_days, available_time, 
                                          profile_photo, degree_certificate)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $provider['email'],
            $provider['password'],
            $provider['full_name'],
            $provider['phone'],
            $provider['medical_degree'],
            $provider['registration_no'],
            $provider['specialization'],
            $provider['experience_years'],
            $provider['consultation_fee'],
            $provider['available_days'],
            $provider['available_time'],
            $provider['profile_photo'],
            $provider['degree_certificate']
        ]);
    } elseif ($type === 'hospitals') {
        $stmt = $pdo->prepare("
            INSERT INTO $permanent_table (email, password, name, type, license_number, 
                                          address, phone, departments, operating_hours, 
                                          license_document)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $provider['email'],
            $provider['password'],
            $provider['name'],
            $provider['type'],
            $provider['license_number'],
            $provider['address'],
            $provider['phone'],
            $provider['departments'],
            $provider['operating_hours'],
            $provider['license_document']
        ]);
    } elseif ($type === 'clinics') {
        $stmt = $pdo->prepare("
            INSERT INTO $permanent_table (email, password, name, license_number, 
                                          address, phone, departments, operating_hours, 
                                          license_document)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $provider['email'],
            $provider['password'],
            $provider['name'],
            $provider['license_number'],
            $provider['address'],
            $provider['phone'],
            $provider['departments'],
            $provider['operating_hours'],
            $provider['license_document']
        ]);
    } elseif ($type === 'pharmacies') {
        $stmt = $pdo->prepare("
            INSERT INTO $permanent_table (email, password, name, drug_license_number, 
                                          address, phone, operating_hours, owner_name, 
                                          license_document)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([
            $provider['email'],
            $provider['password'],
            $provider['name'],
            $provider['drug_license_number'],
            $provider['address'],
            $provider['phone'],
            $provider['operating_hours'],
            $provider['owner_name'],
            $provider['license_document']
        ]);
    }
    
    // Update status in temporary table
    $stmt = $pdo->prepare("UPDATE $temp_table SET status = 'approved' WHERE id = ?");
    $stmt->execute([$id]);
    
    $pdo->commit();
    
    header('Content-Type: application/json');
    echo json_encode(['success' => true, 'message' => 'Provider approved successfully']);
    
} catch (PDOException $e) {
    $pdo->rollBack();
    error_log("Approval Error: " . $e->getMessage());
    http_response_code(500);
    echo json_encode(['error' => 'Database error']);
}
?>
