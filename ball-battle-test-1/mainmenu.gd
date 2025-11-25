extends Control


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://main.tscn")


func _on_leaderboard_pressed() -> void:
	get_tree().change_scene_to_file("res://leaderboard.tscn")

func _on_settings_pressed() -> void:
	get_tree().change_scene_to_file("res://settings.tscn")
