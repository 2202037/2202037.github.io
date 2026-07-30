<?php
/**
 * Login Handler for Ayur Healthcare Platform
 */

session_start();
require_once '../config/db.php';

// Check if form is submitted
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ../../login.html');
    exit();
}

// Get and sanitize input
$email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
$password = $_POST['password'];
$role = $_POST['role'];

// Validate inputs
if (empty($email) || empty($password) || empty($role)) {
    $_SESSION['error'] = 'All fields are required';
    header('Location: ../../login.html');
    exit();
}

// Validate email format
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    $_SESSION['error'] = 'Invalid email format';
    header('Location: ../../login.html');
    exit();
}

// Define table names for each role
$tables = [
    'admin' => 'admins',
    'patient' => 'patients',
    'doctor' => 'doctors',
    'hospital' => 'hospitals',
    'clinic' => 'clinics',
    'pharmacy' => 'pharmacies'
];

// Validate role
if (!array_key_exists($role, $tables)) {
    $_SESSION['error'] = 'Invalid role selected';
    header('Location: ../../login.html');
    exit();
}

try {
    $pdo = getDB();
    $table = $tables[$role];
    
    // For admin, use username or email
    if ($role === 'admin') {
        $stmt = $pdo->prepare("SELECT * FROM $table WHERE email = ? OR username = ? LIMIT 1");
        $stmt->execute([$email, $email]);
    } else {
        // Check for suspended accounts
        $stmt = $pdo->prepare("SELECT * FROM $table WHERE email = ? LIMIT 1");
        $stmt->execute([$email]);
    }
    
    $user = $stmt->fetch();
    
    // Check if user exists
    if (!$user) {
        $_SESSION['error'] = 'Invalid email or password';
        header('Location: ../../login.html');
        exit();
    }
    
    // Check if account is suspended (not for admin)
    if ($role !== 'admin' && isset($user['status']) && $user['status'] === 'suspended') {
        $_SESSION['error'] = 'Your account has been suspended. Please contact support.';
        header('Location: ../../login.html');
        exit();
    }
    
    // Verify password
    if (!password_verify($password, $user['password'])) {
        $_SESSION['error'] = 'Invalid email or password';
        header('Location: ../../login.html');
        exit();
    }
    
    // Login successful - set session variables
    $_SESSION['user_id'] = $user['id'];
    $_SESSION['user_email'] = $user['email'];
    $_SESSION['user_role'] = $role;
    $_SESSION['user_name'] = $user['full_name'] ?? $user['name'] ?? $user['username'];
    $_SESSION['logged_in'] = true;
    
    // Redirect to appropriate dashboard
    $dashboards = [
        'admin' => '../../admin_dashboard.html',
        'patient' => '../../patient_dashboard.html',
        'doctor' => '../../doctor_dashboard.html',
        'hospital' => '../../hospital_dashboard.html',
        'clinic' => '../../clinic_dashboard.html',
        'pharmacy' => '../../pharmacy_dashboard.html'
    ];
    
    header('Location: ' . $dashboards[$role]);
    exit();
    
} catch (PDOException $e) {
    error_log("Login Error: " . $e->getMessage());
    $_SESSION['error'] = 'An error occurred during login. Please try again.';
    header('Location: ../../login.html');
    exit();
}
?>
