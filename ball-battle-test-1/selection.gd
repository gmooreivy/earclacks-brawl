extends Node2D
@onready var selected = false
@onready var ball = 0
signal ball_select(ball)

func _ready() -> void:
	modulate.a = 0
	add_to_group("selectors")

func _on_area_2d_mouse_entered() -> void:
	selected = true
	modulate.a = 0.25

func _on_area_2d_mouse_exited() -> void:
	selected = false
	modulate.a = 0


func _on_area_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if (event is InputEventMouseButton):
		if(event.pressed):
			print("It click :D")
			Engine.time_scale = 1.0
			emit_signal("ball_select", ball)
			get_tree().call_group("selectors", "queue_free")


func _on_ball_select(ball: Variant) -> void:
	selected = true
