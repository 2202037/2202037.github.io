<?php
/**
 * Database Configuration for Ayur Healthcare Platform
 * 
 * This file establishes a connection to the MySQL database using PDO.
 * Modify the constants below to match your XAMPP setup.
 */

// Database configuration constants
define('DB_HOST', 'localhost');
define('DB_NAME', 'ayur_db');
define('DB_USER', 'root');
define('DB_PASS', ''); // Default XAMPP password is empty

// PDO options for better error handling and security
$options = [
    PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
    PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
    PDO::ATTR_EMULATE_PREPARES   => false,
];

try {
    // Create PDO instance
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        $options
    );
} catch (PDOException $e) {
    // Log error and display user-friendly message
    error_log("Database Connection Error: " . $e->getMessage());
    die("Database connection failed. Please check your configuration or contact the administrator.");
}

/**
 * Function to get database connection
 * @return PDO
 */
function getDB() {
    global $pdo;
    return $pdo;
}
?>
