<?php
/**
 * Registration Handler for Ayur Healthcare Platform
 */

session_start();
require_once '../config/db.php';

// Check if form is submitted
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    header('Location: ../../register.html');
    exit();
}

// Get role
$role = $_POST['role'] ?? '';

// Validate role
$allowed_roles = ['patient', 'doctor', 'hospital', 'clinic', 'pharmacy'];
if (!in_array($role, $allowed_roles)) {
    $_SESSION['error'] = 'Invalid role selected';
    header('Location: ../../register.html');
    exit();
}

try {
    $pdo = getDB();
    
    // Route to appropriate registration handler
    switch ($role) {
        case 'patient':
            registerPatient($pdo);
            break;
        case 'doctor':
            registerDoctor($pdo);
            break;
        case 'hospital':
            registerHospital($pdo);
            break;
        case 'clinic':
            registerClinic($pdo);
            break;
        case 'pharmacy':
            registerPharmacy($pdo);
            break;
    }
    
} catch (PDOException $e) {
    error_log("Registration Error: " . $e->getMessage());
    $_SESSION['error'] = 'Registration failed. Please try again.';
    header('Location: ../../register.html');
    exit();
}

/**
 * Register a patient (direct approval - no admin verification needed)
 */
function registerPatient($pdo) {
    // Sanitize and validate inputs
    $full_name = trim($_POST['full_name']);
    $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
    $phone = trim($_POST['phone']);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];
    $gender = $_POST['gender'];
    $date_of_birth = $_POST['date_of_birth'];
    $address = trim($_POST['address'] ?? '');
    
    // Validate required fields
    if (empty($full_name) || empty($email) || empty($phone) || empty($password) || empty($gender) || empty($date_of_birth)) {
        $_SESSION['error'] = 'All required fields must be filled';
        header('Location: ../../register_patient.html');
        exit();
    }
    
    // Validate email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $_SESSION['error'] = 'Invalid email format';
        header('Location: ../../register_patient.html');
        exit();
    }
    
    // Validate password match
    if ($password !== $confirm_password) {
        $_SESSION['error'] = 'Passwords do not match';
        header('Location: ../../register_patient.html');
        exit();
    }
    
    // Validate password length
    if (strlen($password) < 6) {
        $_SESSION['error'] = 'Password must be at least 6 characters';
        header('Location: ../../register_patient.html');
        exit();
    }
    
    // Check if email already exists
    $stmt = $pdo->prepare("SELECT id FROM patients WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error'] = 'Email already registered';
        header('Location: ../../register_patient.html');
        exit();
    }
    
    // Handle profile image upload
    $profile_image = null;
    if (isset($_FILES['profile_image']) && $_FILES['profile_image']['error'] === UPLOAD_ERR_OK) {
        $profile_image = handleImageUpload($_FILES['profile_image'], 'patient');
    }
    
    // Hash password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    
    // Insert patient
    $stmt = $pdo->prepare("
        INSERT INTO patients (email, password, full_name, phone, gender, date_of_birth, address, profile_image)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    $stmt->execute([
        $email,
        $hashed_password,
        $full_name,
        $phone,
        $gender,
        $date_of_birth,
        $address,
        $profile_image
    ]);
    
    $_SESSION['success'] = 'Registration successful! You can now login.';
    header('Location: ../../login.html');
    exit();
}

/**
 * Register a doctor (requires admin verification)
 */
function registerDoctor($pdo) {
    // Sanitize and validate inputs
    $full_name = trim($_POST['full_name']);
    $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
    $phone = trim($_POST['phone']);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];
    $medical_degree = trim($_POST['medical_degree']);
    $registration_no = trim($_POST['registration_no']);
    $specialization = $_POST['specialization'];
    $experience_years = intval($_POST['experience_years']);
    $consultation_fee = floatval($_POST['consultation_fee']);
    $available_days = trim($_POST['available_days'] ?? '');
    $available_time = trim($_POST['available_time'] ?? '');
    
    // Validate required fields
    if (empty($full_name) || empty($email) || empty($phone) || empty($password) || 
        empty($medical_degree) || empty($registration_no) || empty($specialization)) {
        $_SESSION['error'] = 'All required fields must be filled';
        header('Location: ../../register_doctor.html');
        exit();
    }
    
    // Validate email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $_SESSION['error'] = 'Invalid email format';
        header('Location: ../../register_doctor.html');
        exit();
    }
    
    // Validate password match
    if ($password !== $confirm_password) {
        $_SESSION['error'] = 'Passwords do not match';
        header('Location: ../../register_doctor.html');
        exit();
    }
    
    // Check if email already exists in temp or permanent table
    $stmt = $pdo->prepare("SELECT id FROM temp_doctors WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error'] = 'Email already registered. Your application is pending approval.';
        header('Location: ../../register_doctor.html');
        exit();
    }
    
    $stmt = $pdo->prepare("SELECT id FROM doctors WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error'] = 'Email already registered';
        header('Location: ../../register_doctor.html');
        exit();
    }
    
    // Handle file uploads
    $profile_photo = handleImageUpload($_FILES['profile_photo'], 'doctor_profile', true);
    $degree_certificate = handleDocumentUpload($_FILES['degree_certificate'], 'doctor_certificate', true);
    
    // Hash password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    
    // Insert into temporary table for admin verification
    $stmt = $pdo->prepare("
        INSERT INTO temp_doctors (email, password, full_name, phone, medical_degree, registration_no, 
                                  specialization, experience_years, consultation_fee, available_days, 
                                  available_time, profile_photo, degree_certificate)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    $stmt->execute([
        $email, $hashed_password, $full_name, $phone, $medical_degree, $registration_no,
        $specialization, $experience_years, $consultation_fee, $available_days,
        $available_time, $profile_photo, $degree_certificate
    ]);
    
    $_SESSION['success'] = 'Registration submitted! Your application will be reviewed by our admin team.';
    header('Location: ../../login.html');
    exit();
}

/**
 * Register a hospital (requires admin verification)
 */
function registerHospital($pdo) {
    $name = trim($_POST['name']);
    $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];
    $type = $_POST['type'];
    $license_number = trim($_POST['license_number']);
    $address = trim($_POST['address']);
    $phone = trim($_POST['phone']);
    $departments = trim($_POST['departments'] ?? '');
    $operating_hours = trim($_POST['operating_hours'] ?? '');
    
    // Validate required fields
    if (empty($name) || empty($email) || empty($password) || empty($type) || 
        empty($license_number) || empty($address) || empty($phone)) {
        $_SESSION['error'] = 'All required fields must be filled';
        header('Location: ../../register_hospital.html');
        exit();
    }
    
    // Validate email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $_SESSION['error'] = 'Invalid email format';
        header('Location: ../../register_hospital.html');
        exit();
    }
    
    // Validate password match
    if ($password !== $confirm_password) {
        $_SESSION['error'] = 'Passwords do not match';
        header('Location: ../../register_hospital.html');
        exit();
    }
    
    // Check if email already exists
    $stmt = $pdo->prepare("SELECT id FROM temp_hospitals WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error'] = 'Email already registered. Your application is pending approval.';
        header('Location: ../../register_hospital.html');
        exit();
    }
    
    $stmt = $pdo->prepare("SELECT id FROM hospitals WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error'] = 'Email already registered';
        header('Location: ../../register_hospital.html');
        exit();
    }
    
    // Hash password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    
    // Handle license document
    $license_document = handleDocumentUpload($_FILES['license_document'], 'hospital_license', true);
    
    // Insert into temp_hospitals
    $stmt = $pdo->prepare("
        INSERT INTO temp_hospitals (email, password, name, type, license_number, address, phone, 
                                    departments, operating_hours, license_document)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    $stmt->execute([
        $email, $hashed_password, $name, $type, $license_number, $address,
        $phone, $departments, $operating_hours, $license_document
    ]);
    
    $_SESSION['success'] = 'Registration submitted for verification!';
    header('Location: ../../login.html');
    exit();
}

/**
 * Register a clinic (requires admin verification)
 */
function registerClinic($pdo) {
    $name = trim($_POST['name']);
    $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];
    $license_number = trim($_POST['license_number']);
    $address = trim($_POST['address']);
    $phone = trim($_POST['phone']);
    $departments = trim($_POST['departments'] ?? '');
    $operating_hours = trim($_POST['operating_hours'] ?? '');
    
    // Validate required fields
    if (empty($name) || empty($email) || empty($password) || 
        empty($license_number) || empty($address) || empty($phone)) {
        $_SESSION['error'] = 'All required fields must be filled';
        header('Location: ../../register_clinic.html');
        exit();
    }
    
    // Validate email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $_SESSION['error'] = 'Invalid email format';
        header('Location: ../../register_clinic.html');
        exit();
    }
    
    // Validate password match
    if ($password !== $confirm_password) {
        $_SESSION['error'] = 'Passwords do not match';
        header('Location: ../../register_clinic.html');
        exit();
    }
    
    // Check if email already exists
    $stmt = $pdo->prepare("SELECT id FROM temp_clinics WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error'] = 'Email already registered. Your application is pending approval.';
        header('Location: ../../register_clinic.html');
        exit();
    }
    
    $stmt = $pdo->prepare("SELECT id FROM clinics WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error'] = 'Email already registered';
        header('Location: ../../register_clinic.html');
        exit();
    }
    
    // Hash password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    
    // Handle license document
    $license_document = handleDocumentUpload($_FILES['license_document'], 'clinic_license', true);
    
    // Insert into temp_clinics
    $stmt = $pdo->prepare("
        INSERT INTO temp_clinics (email, password, name, license_number, address, phone, 
                                  departments, operating_hours, license_document)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    $stmt->execute([
        $email, $hashed_password, $name, $license_number, $address,
        $phone, $departments, $operating_hours, $license_document
    ]);
    
    $_SESSION['success'] = 'Registration submitted for verification!';
    header('Location: ../../login.html');
    exit();
}

/**
 * Register a pharmacy (requires admin verification)
 */
function registerPharmacy($pdo) {
    $name = trim($_POST['name']);
    $email = filter_var($_POST['email'], FILTER_SANITIZE_EMAIL);
    $password = $_POST['password'];
    $confirm_password = $_POST['confirm_password'];
    $drug_license_number = trim($_POST['drug_license_number']);
    $owner_name = trim($_POST['owner_name']);
    $address = trim($_POST['address']);
    $phone = trim($_POST['phone']);
    $operating_hours = trim($_POST['operating_hours'] ?? '');
    
    // Validate required fields
    if (empty($name) || empty($email) || empty($password) || 
        empty($drug_license_number) || empty($owner_name) || empty($address) || empty($phone)) {
        $_SESSION['error'] = 'All required fields must be filled';
        header('Location: ../../register_pharmacy.html');
        exit();
    }
    
    // Validate email
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $_SESSION['error'] = 'Invalid email format';
        header('Location: ../../register_pharmacy.html');
        exit();
    }
    
    // Validate password match
    if ($password !== $confirm_password) {
        $_SESSION['error'] = 'Passwords do not match';
        header('Location: ../../register_pharmacy.html');
        exit();
    }
    
    // Check if email already exists
    $stmt = $pdo->prepare("SELECT id FROM temp_pharmacies WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error'] = 'Email already registered. Your application is pending approval.';
        header('Location: ../../register_pharmacy.html');
        exit();
    }
    
    $stmt = $pdo->prepare("SELECT id FROM pharmacies WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        $_SESSION['error'] = 'Email already registered';
        header('Location: ../../register_pharmacy.html');
        exit();
    }
    
    // Hash password
    $hashed_password = password_hash($password, PASSWORD_DEFAULT);
    
    // Handle license document
    $license_document = handleDocumentUpload($_FILES['license_document'], 'pharmacy_license', true);
    
    // Insert into temp_pharmacies
    $stmt = $pdo->prepare("
        INSERT INTO temp_pharmacies (email, password, name, drug_license_number, address, phone, 
                                     operating_hours, owner_name, license_document)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ");
    
    $stmt->execute([
        $email, $hashed_password, $name, $drug_license_number, $address,
        $phone, $operating_hours, $owner_name, $license_document
    ]);
    
    $_SESSION['success'] = 'Registration submitted for verification!';
    header('Location: ../../login.html');
    exit();
}

/**
 * Handle image upload with validation
 */
function handleImageUpload($file, $prefix, $required = false) {
    if ($file['error'] === UPLOAD_ERR_NO_FILE) {
        if ($required) {
            $_SESSION['error'] = 'Required file is missing';
            header('Location: ' . $_SERVER['HTTP_REFERER']);
            exit();
        }
        return null;
    }
    
    if ($file['error'] !== UPLOAD_ERR_OK) {
        $_SESSION['error'] = 'File upload error';
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        exit();
    }
    
    // Validate file type
    $allowed_types = ['image/jpeg', 'image/png', 'image/jpg'];
    if (!in_array($file['type'], $allowed_types)) {
        $_SESSION['error'] = 'Invalid image format. Only JPG and PNG allowed.';
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        exit();
    }
    
    // Validate file size (2MB)
    if ($file['size'] > 2 * 1024 * 1024) {
        $_SESSION['error'] = 'Image size must be less than 2MB';
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        exit();
    }
    
    // Generate unique filename
    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = $prefix . '_' . uniqid() . '.' . $extension;
    $upload_path = '../../uploads/images/' . $filename;
    
    // Move uploaded file
    if (!move_uploaded_file($file['tmp_name'], $upload_path)) {
        $_SESSION['error'] = 'Failed to upload image';
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        exit();
    }
    
    return 'uploads/images/' . $filename;
}

/**
 * Handle document upload (PDF/Image)
 */
function handleDocumentUpload($file, $prefix, $required = false) {
    if ($file['error'] === UPLOAD_ERR_NO_FILE) {
        if ($required) {
            $_SESSION['error'] = 'Required document is missing';
            header('Location: ' . $_SERVER['HTTP_REFERER']);
            exit();
        }
        return null;
    }
    
    if ($file['error'] !== UPLOAD_ERR_OK) {
        $_SESSION['error'] = 'Document upload error';
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        exit();
    }
    
    // Validate file type
    $allowed_types = ['image/jpeg', 'image/png', 'image/jpg', 'application/pdf'];
    if (!in_array($file['type'], $allowed_types)) {
        $_SESSION['error'] = 'Invalid document format. Only JPG, PNG, and PDF allowed.';
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        exit();
    }
    
    // Validate file size (5MB)
    if ($file['size'] > 5 * 1024 * 1024) {
        $_SESSION['error'] = 'Document size must be less than 5MB';
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        exit();
    }
    
    // Generate unique filename
    $extension = pathinfo($file['name'], PATHINFO_EXTENSION);
    $filename = $prefix . '_' . uniqid() . '.' . $extension;
    $upload_path = '../../uploads/documents/' . $filename;
    
    // Move uploaded file
    if (!move_uploaded_file($file['tmp_name'], $upload_path)) {
        $_SESSION['error'] = 'Failed to upload document';
        header('Location: ' . $_SERVER['HTTP_REFERER']);
        exit();
    }
    
    return 'uploads/documents/' . $filename;
}
?>
