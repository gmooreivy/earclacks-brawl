extends Node
#signal hit_timeout
@onready var ball1 = null
@onready var ball2 = null
@onready var weapon1 = null
@onready var weapon2 = null
@onready var label1 = null
@onready var label2 = null
@onready var sclr1 = null
@onready var sclr2 = null
@onready var col1 = null
@onready var col2 = null
@onready var tangible = true
@onready var victoryText = null
const ballScene = preload("res://ball.tscn")
const spearScene = preload("res://spear.tscn")
const swordScene = preload("res://sword.tscn")

func _ready():
	#start_game('ec00f5', '0008ff', 'spear', 'sword')
	update_constants()
	$GUI/CanvasLayer.color = col1
	$GUI2/CanvasLayer2.color = col2
	print(col1, col2)
	weapon1.rotation_degrees = randi_range(90, 270)
	weapon2.rotation_degrees = randi_range(90, 270)
	update_labels()
	
func update_constants():
	ball1 = $BallContainer1/CanvasModulate/Ball1
	ball2 = $BallContainer2/CanvasModulate/Ball2
	weapon1 = $BallContainer1/CanvasModulate/Ball1/weapon1
	weapon2 = $BallContainer2/CanvasModulate/Ball2/weapon2
	label1 = $BallContainer1/CanvasModulate/Ball1/label1
	label2 = $BallContainer2/CanvasModulate/Ball2/label2
	sclr1 = $GUI/CanvasLayer/sclr1
	sclr2 = $GUI2/CanvasLayer2/sclr2
	col1 = $BallContainer1/CanvasModulate.color
	col2 = $BallContainer2/CanvasModulate.color
	tangible = true
	victoryText = $GUI3/CanvasLayer3/VictoryScreen

func _process(float) -> void:
	if(is_instance_valid(ball1) && is_instance_valid(ball2)):
		update_labels()
	else: pass
	
func end_game(ball, winner, color):
	weapon1.reset_stats()
	weapon2.reset_stats()
	ball1.health = 100
	ball2.health = 100
	get_tree().call_group("balls", "queue_free")
	get_tree().call_group("weapons", "queue_free")
	victoryText.text = ". . ."
	#if(ball == 1):
		#ball2.queue_free()
	#if(ball == 2):
		#ball1.queue_free()
	toggleLabels(false)
	await get_tree().create_timer(1.0).timeout
	victoryText.text = str(winner) + " Wins!"
	$GUI3/CanvasLayer3.color = color

func is_on_layer(body, layer_number: int) -> bool:
	if not body or layer_number < 1 or layer_number > 32:
		return false
	var layer_bit := 1 << (layer_number - 1)
	return(body.collision_layer & layer_bit) != 0


func toggleLabels(visible):
	if(visible):
		label1.show()
		label2.show()
		sclr1.show()
		sclr2.show()
	else:
		label1.hide()
		label2.hide()
		sclr1.hide()
		sclr2.hide()

func start_game(newCol1, newCol2, newWeapon1, newWeapon2):
	col1 = newCol1
	col2 = newCol2
	
	$BallContainer1/CanvasModulate.color = col1
	$BallContainer2/CanvasModulate.color = col2
	ball1 = ballScene.instantiate()
	ball1.name = "Ball1"
	ball2 = ballScene.instantiate()
	ball2.name = "Ball2"
	$BallContainer1/CanvasModulate.add_child(ball1)
	$BallContainer2/CanvasModulate.add_child(ball2)
	match newWeapon1:
		'spear':
			weapon1 = spearScene.instantiate()
		'sword':
			weapon1 = swordScene
		
	match newWeapon2:
		'spear':
			weapon2 = spearScene.instantiate()
			
		'sword':
			weapon2 = swordScene.instantiate()
	weapon1.name = "weapon1"
	weapon2.name = "weapon2"
	ball1.add_child(weapon1)
	ball2.add_child(weapon2)
	reparent_object($label1, ball1)
	reparent_object($label2, ball2)
	ball1.position = Vector2(65, 35)
	ball2.position = Vector2(115, 35)
#	Collision Layers
	ball1.set_collision_layer_value(1, true)
	ball1.set_collision_mask_value(2, true)
	ball1.set_collision_mask_value(4, true)
	ball1.set_collision_mask_value(5, true)
	
	weapon1.set_collision_layer_value(3, true)
	weapon1.set_collision_mask_value(2, true)
	weapon1.set_collision_mask_value(4, true)
	
	weapon2.set_collision_layer_value(4, true)
	weapon2.set_collision_mask_value(1, true)
	weapon2.set_collision_mask_value(3, true)
	
	ball2.set_collision_layer_value(2, true)
	ball2.set_collision_mask_value(1, true)
	ball2.set_collision_mask_value(3, true)
	ball2.set_collision_mask_value(5, true)
	
	#print("Ball1: " + str(is_on_layer(ball1, 3)))
	#print("Ball2: " + str(is_on_layer(ball2, 3)))
	#print("Weapon1: " + str(is_on_layer(weapon1, 3)))
	#print("Weapon2: " + str(is_on_layer(weapon2, 3)))
	
	
#	SIGNALS
	connect_signal(weapon1, "weapon_attack", _on_weapon_attack)
	connect_signal(weapon1, "weapon_parry", _on_weapon_parry)
	
	connect_signal(weapon2, "weapon_attack", _on_weapon_attack)
	connect_signal(weapon2, "weapon_parry", _on_weapon_parry)
	
func connect_signal(object, signal_name, method):
	if not(object.is_connected(signal_name, method)):
		object.connect(signal_name, method)

func reparent_object(object: Node, new_parent: Node):
#	FROM GODOT FORUMS
	# Remove from current parent
	var current_parent = object.get_parent()
	if current_parent:
		current_parent.remove_child(object)

	# Add to new parent
	new_parent.add_child(object)
		
func hit_pause(timeScale, duration, ball):
#	Credits to Master Albert on youtube
	Engine.time_scale = timeScale
	if(ball == 1):
		$BallContainer1/CanvasModulate.color = 'FFFFFF'
	else: if(ball == 2):
		$BallContainer2/CanvasModulate.color = 'FFFFFF'
	await(get_tree().create_timer(duration * timeScale).timeout)
	$BallContainer1/CanvasModulate.color = col1
	$BallContainer2/CanvasModulate.color = col2
	Engine.time_scale = 1.0
	
func update_labels():
	
	label1.text = str(ball1.health)
	label2.text = str(ball2.health)
	sclr1.text = str(weapon1.scalarattr, ": ", weapon1.scalar)
	sclr2.text = str(weapon2.scalarattr, ": ", weapon2.scalar)

func _on_weapon_attack(angle, damage, collisionLayer) -> void:
	#print("-- START --")
	#print("Angle: ", angle)
	#print("Damage: ", damage)
	#print("Layer: ", collisionLayer)
	#print("-- END --")

	match collisionLayer:
		1, 2:
			
			var thrust = Vector2(0, -100)
			if(tangible):
				update_labels()
				if(collisionLayer == 1):
					hit_pause(0.05, 0.5, 1)
					ball1.health -= damage
					weapon2.increase_stats()
					ball1.apply_central_impulse((Vector2(cos(angle), sin(angle))) * thrust)
				else:if(collisionLayer == 2):
					hit_pause(0.05, 0.5, 2)
					ball2.health -= damage
					weapon1.increase_stats()
					ball2.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))
			
			if(ball1.health <= 0):
				end_game(2, weapon2.type, col2)
			else: if(ball2.health <= 0):
				end_game(1, weapon1.type, col1)

func _on_weapon_parry(angle: Variant, contactLayer: Variant) -> void:
	var thrust = Vector2(0, -25)
	#print("parried")
	if(tangible):
		$attackTimeout.start()
		if(contactLayer == 4) :
			ball1.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))
			weapon1.rotation_speed *= randf_range(1.1, 1.4)
			
		else :
			ball2.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))
			weapon2.rotation_speed *= randf_range(1.1, 1.4)
		hit_pause(0.05, 0.35, 0)
		tangible = false
		
	#print("+ PARRY")
	#print("Layer: ", contactLayer)
	
	


func _on_attack_timeout_timeout() -> void:
	if(is_instance_valid(ball1) && is_instance_valid(ball2)):
		tangible = true
		if(weapon1.rotation_speed > 0):
			weapon1.rotation_speed = weapon1.baseRotation
		else: weapon1.rotation_speed = weapon1.baseRotation * -1
		
		if(weapon2.rotation_speed > 0):
			weapon2.rotation_speed = weapon2.baseRotation
		else: weapon2.rotation_speed = weapon2.baseRotation * -1


	
