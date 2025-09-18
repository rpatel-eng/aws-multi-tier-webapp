<?php
require 'config.php';

try {
    $name = trim($_POST["name"] ?? '');
    $email = trim($_POST["email"] ?? '');

    if (empty($name) || empty($email)) {
        throw new Exception("Mandatory fields are missing.");
    }

    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        throw new Exception("Invalid email address.");
    }

    $stmt = $conn->prepare("INSERT INTO users(name,email) VALUES(?,?)");
    $stmt->bind_param("ss", $name, $email);

    if ($stmt->execute()) {
        echo "New user created successfully for " . htmlspecialchars($name);
    } else {
        throw new Exception("Failed to insert record.");
    }

    $stmt->close();
    $conn->close();

} catch (mysqli_sql_exception $e) {
    error_log("MySQL Error: " . $e->getMessage());
    die("Database error occurred. Please try again later.");
} catch (Exception $e) {
    die(htmlspecialchars($e->getMessage()));
}
?>

