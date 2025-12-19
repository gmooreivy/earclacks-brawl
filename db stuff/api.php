<?php
// Include the database connection file
// This file should create a PDO instance and assign it to $pdo
include 'db.php';

// Set the content type to JSON for API responses
header("Content-Type: application/json");

// Retrieve input data from the request body
// json_decode converts JSON input into a PHP associative array
$input = json_decode(file_get_contents('php://input'), true);
if ($_SERVER['REQUEST_METHOD'] === 'POST' && strpos($_SERVER['CONTENT_TYPE'], 'application/json') === 0) {
    $_POST = json_decode(file_get_contents('php://input'), true) ?? [];
}

// if ($_SERVER['REQUEST_METHOD'] === 'GET' && strpos($_SERVER['CONTENT_TYPE'], 'application/json') === 0) {
//     $_GET = json_decode(file_get_contents('php://input'), true) ?? [];
// }
// Determine the action from a GET parameter
// This allows the API to handle different actions like 'read', 'create', etc.
$action = isset($_GET['action']) ? $_GET['action'] : '';

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
    
    case 'getallscores':
        // Use a prepared statement to prevent SQL injection
        $stmt = $pdo->query("SELECT user, score FROM leaderboard ORDER BY score DESC");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC); // Fetch the result as an associative array 
        send_response($data); // Send the user data as a response
        break;

    case 'getanalytics':

        // Use a prepared statement to prevent SQL injection
        $stmt = $pdo->query("SELECT * FROM analytics");
        $data = $stmt->fetchAll(PDO::FETCH_ASSOC); // Fetch the result as an associative array 
        send_response($data); // Send the user data as a response
        break;


    case 'checkuser':
        if (isset($_GET['user'])) {
            $user = $_GET['user'];
            echo $user;
            $stmt = $pdo->query("SELECT * FROM leaderboard WHERE user = :user");
            $stmt->execute(['user' => $user]);
            $data = $stmt->fetchAll(PDO::FETCH_ASSOC);
            echo($data);
            // send_response($data);
            // if ($stmt->rowCount() > 0) {
            //     send_response(true);
            // }
            // else {
            //     send_response(false);   
            // }
            // if($data > 0){send_response(true);}
            // else{send_response(false);}
        }
        break;

    case 'getplayerscore':
        $id = $_GET['id'];
        $stmt = $pdo->prepare("SELECT user, score FROM leaderboard WHERE id = :id");
        $stmt->execute(['id' => $id]); // Bind the ID parameter
        $data = $stmt->fetch(PDO::FETCH_ASSOC); // Fetch the result as an associative array
        send_response($data); // Send the user data as a response
        break;
    // --- CREATE (GET) ACTION ---
    case 'newplayer':
        echo("New player called");
        echo($_POST['user']);
        if (isset($_POST['user'])) {
            $user = $_POST['user'];
            // Use a prepared statement to insert data securely
            $stmt = $pdo->prepare("INSERT INTO leaderboard (user, score) VALUES (:user, :score)");
            $success = $stmt->execute(['user' => $user, 'score' => 0]);
            

            if ($success) {
                // Respond with a success message and the new user's ID
                send_response(["message" => "User added successfully", "id" => $pdo->lastInsertId()]);
            } else {
                send_response(["message" => "Error creating user"], 500);
            }
        } else{
    
        }
        break;

    case 'newmatch':
        if (isset($_GET['player'], $_GET['opponent'], $_GET['matchLength'], $_GET['win'] )) {
            $player = $_GET['player'];
            $opponent = $_GET['opponent'];
            $matchLength  = $_GET['matchLength'];
            $win = $_GET['win'];
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
            echo($_POST['matchlength']);
            send_response(["message" => "Missing required fields for creation"], 400);
        }
    // --- UPDATE (PUT) ACTION ---
    case 'updatescore':
        if (isset($_GET['user'], $_GET['score'])) {
            $user = $_GET['user'];
            $score = $_GET['score'];

            // Use a prepared statement to update data securely
            $stmt = $pdo->prepare("UPDATE leaderboard SET score = :score WHERE user = :user");
            $success = $stmt->execute(['user' => $user, 'score' => $score]);

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

    case 'updateuser':
        if (isset($_GET['user'], $_GET['newname'])) {
            $user = $_GET['user'];
            $newname = $_GET['newname'];

            // Use a prepared statement to update data securely
            $stmt = $pdo->prepare("UPDATE leaderboard SET user = :newname WHERE user = :user");
            $success = $stmt->execute(['user' => $user, 'newname' => $newname]);

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
            echo($_POST['id']);
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