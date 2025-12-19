extends Control

func _ready() -> void:
	await(get_tree().create_timer(0.25).timeout)
	if not (FileAccess.file_exists("user://username.save")):
		get_tree().change_scene_to_file("res://popup.tscn")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_leaderboard_pressed() -> void:
	get_tree().change_scene_to_file("res://leaderboard.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://popup.tscn")
