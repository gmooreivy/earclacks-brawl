extends Control

func _ready():
	$HTTPRequest.request_completed.connect(_on_request_completed)
	$HTTPRequest.request("http://localhost/earclash/api.php?action=getscores")
	
func _on_request_completed(result, response_code, headers, body):
	
	var json_string = body.get_string_from_utf8()
	print(typeof(body))
	var iverystronglydislikejsonformatting = JSON.new()
	
	var json_result = iverystronglydislikejsonformatting.parse(json_string)
	var json_data = iverystronglydislikejsonformatting.data
	print(json_data)
	print(json_result)
	
	var players: Array = json_data
	var boardindex = 1
	for player in players:
		format_scoreboard(player['user'], player['score'], boardindex)
		boardindex+= 1
	add_personal_score()

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://mainmenu.tscn")

func format_scoreboard(user, score, index):
#Giant switch case of doom and despair
	score = floori(score)
	var entryString = str(user, ": ", score)
	match index:
		1:
			$Entry1.text = entryString
		2:
			$Entry2.text = entryString
		3:
			$Entry3.text = entryString
		4:
			$Entry4.text = entryString
		5:
			$Entry5.text = entryString
		6:
			$Entry6.text = entryString
		7:
			$Entry7.text = entryString
		8:
			$Entry8.text = entryString
		9:
			$Entry9.text = entryString
		10:
			$Entry10.text = entryString

	
	
func add_personal_score() -> void:
	var json = JSON.new()
	var save_file = FileAccess.open("user://username.save", FileAccess.READ)
	var save_data = save_file.get_line()
	var parsed_data = JSON.parse_string(save_data)
	var user = parsed_data['user']
	var score = floori(parsed_data['score'])
	$Entry11.text = str(user, ": ", score)
#	add the users score to the leaderboard
