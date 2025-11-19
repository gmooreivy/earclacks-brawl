<?php
// Include the database connection file
// This file should create a PDO instance and assign it to $pdo
include 'db.php';

// Set the content type to JSON for API responses
header("Content-Type: application/json");

// Retrieve input data from the request body
// json_decode converts JSON input into a PHP associative array
$input = json_decode(file_get_contents('php://input'), true);

// Determine the action from a GET parameter
// This allows the API to handle different actions like 'read', 'create', etc.
$action = isset($_POST['action']) ? $_POST['action'] : '';

// Function to send a JSON response and exit
// This is a helper function to standardize API responses
function send_response($data, $http_code = 200) {
    http_response_code($http_code); // Set the HTTP status code
    echo json_encode($data); // Convert the response data to JSON
    exit(); // Stop further script execution
}

// Use a switch statement to handle different actions
switch (strtolower($action)) {
    // --- READ (GET) ACTIONS ---
    case 'read':
        $stmt = $pdo->query("SELECT * FROM leaderboard");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC); // Fetch the result as an associative array 
        send_response($data); // Send the user data as a response
        break;

    case 'getscores':
        // Use a prepared statement to prevent SQL injection
        $stmt = $pdo->query("SELECT user, score FROM leaderboard ORDER BY score DESC LIMIT 10");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC); // Fetch the result as an associative array 
        send_response($data); // Send the user data as a response
        break;

    case 'getanalytics':

        // Use a prepared statement to prevent SQL injection
        $stmt = $pdo->query("SELECT * FROM analytics");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC); // Fetch the result as an associative array 
        send_response($data); // Send the user data as a response
        break;

    case 'getplayerscore':
        $id = $_POST['id'];
        $stmt = $pdo->prepare("SELECT user, score FROM leaderboard WHERE id = :id");
        $stmt->execute(['id' => $id]); // Bind the ID parameter
        $data = $stmt->fetch(PDO::FETCH_ASSOC); // Fetch the result as an associative array
        send_response($data); // Send the user data as a response
        break;
    // --- CREATE (POST) ACTION ---
    case 'newplayer':
        if (isset($_POST['user'], $_POST['score'])) {
            $user = $_POST['user'];
            $score = $_POST['score'];
            // Use a prepared statement to insert data securely
            $stmt = $pdo->prepare("INSERT INTO leaderboard (user, score) VALUES (:user, :score)");
            $success = $stmt->execute(['user' => $user, 'score' => $score]);
            

            if ($success) {
                // Respond with a success message and the new user's ID
                send_response(["message" => "User added successfully", "id" => $pdo->lastInsertId()]);
            } else {
                send_response(["message" => "Error creating user"], 500);
            }
        } else{
            // echo($input['user']);
            // echo($input['score']);
        }
        break;

    case 'newmatch':
        if (isset($_POST['player'], $_POST['opponent'], $_POST['matchLength'], $_POST['win'] )) {
            $player = $_POST['player'];
            $opponent = $_POST['opponent'];
            $matchLength  = $_POST['matchLength'];
            $win = $_POST['win'];
            // Use a prepared statement to insert data securely
            $stmt = $pdo->prepare("INSERT INTO analytics (player, opponent, matchLength, win) VALUES (:player, :opponent, :matchLength, :win)");
            $success = $stmt->execute(['player' => $player, 'opponent' => $opponent, 'matchLength' => $matchLength, 'win' => $win]);

            if ($success) {
                // Respond with a success message and the new user's ID
                send_response(["message" => "Match logged successfully", "id" => $pdo->lastInsertId()]);
            } else {
                send_response(["message" => "Error logging match"], 500);
            }
        } else {
            // Respond with an error if required fields are missing
            echo($_POST['opponent']);
            send_response(["message" => "Missing required fields for creation"], 400);
        }
    // --- UPDATE (PUT) ACTION ---
    case 'update':
        if (isset($_POST['id'], $_POST['user'], $_POST['score'])) {
            $id = $_POST['id'];
            $user = $_POST['user'];
            $score = $_POST['score'];

            // Use a prepared statement to update data securely
            $stmt = $pdo->prepare("UPDATE leaderboard SET user = :user, score = :score WHERE id = :id");
            $success = $stmt->execute(['user' => $user, 'score' => $score, 'id' => $id]);

            if ($success) {
                send_response(["message" => "User updated successfully"]);
            } else {
                send_response(["message" => "Error updating user"], 500);
            }
        } else {
            // Respond with an error if required fields are missing
            send_response(["message" => "Missing required ID or fields for update"], 400);
        }
        break;

    // --- DELETE ACTION ---
    case 'delete':
        if (isset($_GET['id'])) {
            $id = $_GET['id'];

            // Use a prepared statement to delete data securely
            $stmt = $pdo->prepare("DELETE FROM leaderboard WHERE id = :id");
            $success = $stmt->execute(['id' => $id]);

            if ($success) {
                send_response(["message" => "User deleted successfully"]);
            } else {
                send_response(["message" => "Error deleting user"], 500);
            }
        } else {
            // Respond with an error if the ID is missing
            send_response(["message" => "Missing required ID for delete"], 400);
        }
        break;

    // --- DEFAULT (INVALID ACTION) ---
    default:
        // Respond with an error for invalid or missing actions
        send_response(["message" => "Invalid or missing action parameter"], 400);
        break;
}

// No need to explicitly close the PDO connection; it closes automatically when the script ends
?>