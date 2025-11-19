<?php
// Database configuration for XAMPP
$host = 'localhost'; // Default XAMPP host
$dbname = 'earclash'; // Replace with your database name
$username = 'root'; // Default XAMPP username
$password = ''; // Default XAMPP password (empty)

// Create a PDO connection
try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8", $username, $password);
    // Set PDO error mode to exception
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    // Handle connection error
    die("Connection failed: " . $e->getMessage());
}
?>