extends Control

@onready var score = 0
var is_new := false
var local_user = "err"
var _pending_username := ""
var _http: HTTPRequest
const API_BASE = "http://localhost/earclash/api.php?action=" # Ensure api.php is actually served here under htdocs/earclash

func _ready() -> void:
	if(FileAccess.file_exists("user://username.save")):
		var save_file = FileAccess.open("user://username.save", FileAccess.READ)
		var parsed_data = JSON.parse_string(save_file.get_line())
		$LineEdit.placeholder_text = parsed_data['user']
		local_user = parsed_data['user']
		score = parsed_data['score']
	else:
		is_new = true
	# Reuse a single HTTPRequest so it isn't freed on scene change.
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)
	
func _on_button_pressed():
	var username = $LineEdit.text
	_pending_username = username
	if (username.length() <= 20 && username.length() > 2):
		if (is_new):
			var url = API_BASE + "newplayer"
			make_request(url, username)
			return # Wait for the request to finish before saving/changing scene.
		else:
			var actionString = "updateuser&user=%s&newname=%s"
			var url = API_BASE + actionString % [local_user, username]
			print(url)
			make_request(url, username)
			return
		# Not a new user: save immediately and change scene.
	else:
		print("Username blocked")
		$LineEdit.text = ""
		$LineEdit.placeholder_text = "Invalid Username"

func make_request(url, username):
	print("Request made")
	print(url)
	print(username)
	var data = {"user": username}
	var body = JSON.stringify(data)
	var headers = ["Content-Type: application/json"]
	var err = _http.request(url, headers, HTTPClient.METHOD_POST, body)
	if (err != OK):
		print("HTTP request error: %s" % err)

func _on_request_completed(result, response_code, headers, body):
	print("Request completed")
	var body_text = body.get_string_from_utf8()
	if (response_code == 200 or response_code == 201):
		print("User added successfully: %s" % body_text)
		var user_file = FileAccess.open("user://username.save", FileAccess.WRITE)
		var data = {'user': _pending_username, 'score': score}
		user_file.store_line(JSON.stringify(data))
		get_tree().change_scene_to_file("res://mainmenu.tscn")
	else:
		print("Failed to add user: %d, body: %s" % [response_code, body_text])
		$LineEdit.text = ""
		$LineEdit.placeholder_text = "Signup failed, check server URL"
