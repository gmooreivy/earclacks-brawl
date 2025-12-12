extends Control
@onready var id = 0
func _ready() -> void:
	if(FileAccess.file_exists("user://username.save")):
		var save_file = FileAccess.open("user://username.save", FileAccess.READ)
		var parsed_data = JSON.parse_string(save_file.get_line())
#		add ID detection
		$LineEdit.placeholder_text = parsed_data['user']
		
func _on_button_pressed() -> void:
	var user_file = FileAccess.open("user://username.save", FileAccess.WRITE)
	var username = $LineEdit.text
	if(username.length() <= 20 && username.length() > 2):
		print(username.length())
		var data = {
			'user': username,
			'score': 0
		}
		var json_data = JSON.stringify(data)
		user_file.store_line(json_data)
		get_tree().change_scene_to_file("res://mainmenu.tscn")
	else:
		print("Username blocked")
		$LineEdit.text = ""
		$LineEdit.placeholder_text = "Invalid Username"
