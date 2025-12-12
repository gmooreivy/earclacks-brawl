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
@onready var colid1
@onready var colid2
const ballScene = preload("res://ball.tscn")
const spearScene = preload("res://spear.tscn")
const swordScene = preload("res://sword.tscn")
const daggerScene = preload("res://dagger.tscn")
const rapierScene = preload("res://rapier.tscn")
const selectScene = preload("res://selection.tscn")

func _ready():
	var weaponid1 = randi_range(1, 4)
	var weaponid2 = randi_range(1, 4)
	while(weaponid2 == weaponid1):
		weaponid2 = randi_range(1, 4)
	var hue = randf() * 360
	colid1 = Color.from_hsv(hue, 1.0, 1.0)
	colid2 = Color.from_hsv(360 - hue, 1.0, 1.0)
	start_game(colid1, colid2, weaponid1, weaponid2)
	update_constants()
	$GUI/CanvasLayer.color = col1
	$GUI2/CanvasLayer2.color = col2
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
		if(ball1.linear_velocity.x > 1000 || ball1.linear_velocity.x < -1000):
			ball1.linear_velocity.x *= 0.5
			print(ball1.linear_velocity)
		if(ball1.linear_velocity.y > 1000 || ball1.linear_velocity.y < -1000):
			ball1.linear_velocity.y *= 0.5
			print(ball1.linear_velocity)
			
		if(ball2.linear_velocity.x > 1000 || ball2.linear_velocity.x < -1000):
			ball2.linear_velocity.x *= 0.5
			print(ball2.linear_velocity)
		if(ball2.linear_velocity.y > 1000 || ball2.linear_velocity.y < -1000):
			ball2.linear_velocity.y *= 0.5
			print(ball2.linear_velocity)
			
		#if(ball2.linear_velocity > 30 || ball2.linear_velocity < -30):
			#ball2.linear_velocity *= Vector2(0.9, 0.9)
			#print(ball2.linear_velocity)
	else: pass
	
func end_game(ball, winner, color):
	var ball_group = get_tree().get_nodes_in_group("balls")
	weapon1.reset_stats()
	weapon2.reset_stats()
	
	ball1.health = 100
	ball2.health = 100
	var selected = ball.selected
	get_tree().call_group("balls", "queue_free")
	get_tree().call_group("weapons", "queue_free")
	$GUI3/CanvasLayer3.color = Color.WHITE
	victoryText.text = ". . ."
	#if(ball == 1):
		#ball2.queue_free()
	#if(ball == 2):
		#ball1.queue_free()
	#toggleLabels(false)
	await get_tree().create_timer(1.0).timeout
	$GUI3/CanvasLayer3.color = color
	victoryText.text = str(winner) + " Wins!"
	label1 = Label.new()
	label2 = Label.new()
	await get_tree().create_timer(2.5).timeout
	victoryText.text = " "
	if(selected):
		var curScore = int($score.text)
		curScore += 1
		$score.text = str(curScore)
		_ready()
	else:
		save_score(int($score.text))
		get_tree().change_scene_to_file("res://mainmenu.tscn")
func is_on_layer(body, layer_number: int) -> bool:
	if not body or layer_number < 1 or layer_number > 32:
		return false
	var layer_bit := 1 << (layer_number - 1)
	return(body.collision_layer & layer_bit) != 0

func save_score(score):
	if(FileAccess.file_exists("user://username.save")):
		var save_file = FileAccess.open("user://username.save", FileAccess.READ)
		var parsed_data = JSON.parse_string(save_file.get_line())
		var username = parsed_data['user']
		var curScore = parsed_data['score']
		if(score > curScore):
			var data = {
				'user': username,
				'score': score
			}
			var user_file = FileAccess.open("user://username.save", FileAccess.WRITE)
			var json_data = JSON.stringify(data)
			user_file.store_line(json_data)
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
	ball1.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	ball2 = ballScene.instantiate()
	ball2.name = "Ball2"
	ball2.freeze_mode = RigidBody2D.FREEZE_MODE_STATIC
	$BallContainer1/CanvasModulate.add_child(ball1)
	$BallContainer2/CanvasModulate.add_child(ball2)
	match newWeapon1:
		1:
			weapon1 = spearScene.instantiate()
		2:
			weapon1 = swordScene.instantiate()
		3:
			weapon1 = daggerScene.instantiate()
		4:
			weapon1 = rapierScene.instantiate()
		
	match newWeapon2:
		1:
			weapon2 = spearScene.instantiate()
		2:
			weapon2 = swordScene.instantiate()
		3:
			weapon2 = daggerScene.instantiate()
		4:
			weapon2 = rapierScene.instantiate()
			
	weapon1.name = "weapon1"
	weapon2.name = "weapon2"
	ball1.add_child(weapon1)
	ball2.add_child(weapon2)
	label1 = Label.new()
	label1.name = "label1"
	label1.horizontal_alignment = 1
	label1.position = Vector2(-24, -24)
	label1.vertical_alignment = 1
	label1.add_theme_color_override("font_color", Color.BLACK)
	label1.add_theme_font_size_override("font_size", 32)

	label2 = Label.new()
	label2.name = "label2"
	label2.horizontal_alignment = 1
	label2.position = Vector2(-24, -24)
	label2.vertical_alignment = 1
	label2.add_theme_color_override("font_color", Color.BLACK)
	label2.add_theme_font_size_override("font_size", 32)
	reparent_object(label1, ball1)
	reparent_object(label2, ball2)
	ball1.position = Vector2(65, 35)
	ball2.position = Vector2(100, 35)
	weapon1.rotation = 0
	weapon2.rotation = 0
#	Collision Layers
	place_bets()
	
	await(get_tree().create_timer(0.5).timeout)
	$betHeader.text = ""
	toggleLabels(true)
#BITMASKBITMASKBITMASKBITMASKBITMASKBITMASKBITMASKBITMASKBITMASKBITMASKBITMASKBITMASKBITMASK
	ball1.collision_layer = 0b00000000_00000000_00000000_00000001
	ball1.collision_mask = 0b00000000_00000000_00000000_00011010
	
	weapon1.collision_layer = 0b00000000_00000000_00000000_00000100
	weapon1.collision_mask = 0b00000000_00000000_00000000_00001010
	
	weapon2.collision_layer = 0b00000000_00000000_00000000_00001000
	weapon2.collision_mask = 0b00000000_00000000_00000000_00000101
	
	ball2.collision_layer = 0b00000000_00000000_00000000_00000010
	ball2.collision_mask = 0b00000000_00000000_00000000_00010101
	
	#print("Ball1: " + str(is_on_layer(ball1, 3)))
	#print("Ball2: " + str(is_on_layer(ball2, 3)))
	#print("Weapon1: " + str(is_on_layer(weapon1, 3)))
	#print("Weapon2: " + str(is_on_layer(weapon2, 3)))
	
	
#	SIGNALS
	connect_signal(weapon1, "weapon_attack", _on_weapon_attack)
	connect_signal(weapon1, "weapon_parry", _on_weapon_parry)
	
	connect_signal(weapon2, "weapon_attack", _on_weapon_attack)
	connect_signal(weapon2, "weapon_parry", _on_weapon_parry)

func _on_ball_select(ball: Variant) -> void:
	if(ball == 1):
		print("Selected ball 1")
		ball1.selected = true
	else: if(ball == 2):
		print("Selected ball 1")
		ball2.selected = true
	else:
		print("NO BALL SELECTED")


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
		
#func hit_pause(timeScale, duration, ball, flash):
##	Credits to Master Albert on youtube
	#Engine.time_scale = timeScale
	#if(ball == 1 || ball == 3):
		#$BallContainer1/CanvasModulate.color = flash
	#else: if(ball == 2 || ball == 4):
		#$BallContainer2/CanvasModulate.color = flash
	#if(ball != 3 && ball != 4):
		#await(get_tree().create_timer(duration * timeScale).timeout)
	#else:
		#await(get_tree().create_timer(0.4 * timeScale).timeout)
	#$BallContainer1/CanvasModulate.color = col1
	#$BallContainer2/CanvasModulate.color = col2
	#Engine.time_scale = 1.0
func hit_pause(duration, ball, flash):
	Engine.time_scale = 0.05
	await(get_tree().create_timer(0.05 * 0.05).timeout)
	Engine.time_scale = 1
	match ball:
		1:
			if(is_instance_valid(ball1)):
				if(!ball1.stunned):
					ball1.stunned = true
					$BallContainer1/CanvasModulate.color = flash
					ball1.mass = 100.0
					var saved_rotation = weapon1.rotation_speed
					var saved_speed = ball1.linear_velocity
					ball1.gravity_scale = 0
					weapon1.rotation_speed = 0
					ball1.linear_velocity = Vector2.ZERO
					weapon1.baseRotation = 0
					ball1.freeze = true
					await(get_tree().create_timer(duration).timeout)
					if(is_instance_valid(ball1)):
						$BallContainer1/CanvasModulate.color = col1
						ball1.mass = 1.0
						ball1.stunned = false
						ball1.gravity_scale = 1.0
						ball1.freeze = false
						ball1.linear_velocity = saved_speed
						weapon1.rotation_speed = saved_rotation
						weapon1.baseRotation = saved_rotation
				
		2:
			if(is_instance_valid(ball2)):
				if(!ball2.stunned):
					ball2.stunned = true
					$BallContainer2/CanvasModulate.color = flash
					ball2.mass = 100.0
					var saved_rotation = weapon2.rotation_speed
					var saved_speed = ball2.linear_velocity
					ball2.gravity_scale = 0
					weapon2.rotation_speed = 0
					ball2.linear_velocity = Vector2.ZERO
					weapon2.baseRotation = 0
					ball2.freeze = true
					await(get_tree().create_timer(duration).timeout)
					if(is_instance_valid(ball2)):
						$BallContainer2/CanvasModulate.color = col2
						ball2.mass = 1.0
						ball2.stunned = false
						ball2.gravity_scale = 1.0
						ball2.freeze = false
						ball2.linear_velocity = saved_speed
						weapon2.rotation_speed = saved_rotation
						weapon2.baseRotation = saved_rotation
func place_bets():
	$betHeader.text = str("Place your bets:\n", weapon1.type, " vs. ", weapon2.type)
	Engine.time_scale = 0.0
	var selectionWindow1 = selectScene.instantiate()
	connect_signal(selectionWindow1, "ball_select", _on_ball_select)
	var selectionWindow2 = selectScene.instantiate()
	connect_signal(selectionWindow2, "ball_select", _on_ball_select)
	
	$GUI/CanvasLayer.add_child(selectionWindow1)
	$GUI2/CanvasLayer2.add_child(selectionWindow2)
	selectionWindow1.ball = 1
	selectionWindow2.ball = 2
	selectionWindow2.position = Vector2(960, 0)
	
func update_labels():
	
	label1.text = str(ball1.health)
	label2.text = str(ball2.health)

	if(label1.text != '100'):
		label1.position.x = -24
	if(label2.text != '100'):
		label2.position.x = -24
	sclr1.text = str(weapon1.scalarattr, ": ", weapon1.scalar)
	sclr2.text = str(weapon2.scalarattr, ": ", weapon2.scalar)

func _on_weapon_attack(angle, damage, collisionLayer) -> void:

	match collisionLayer:
		
		1, 2:
			
			var thrust = Vector2(0, -100)
			if(tangible):
				update_labels()
				if(collisionLayer == 1):
					ball1.health -= damage
					weapon2.increase_stats()
					await(hit_pause(weapon2.stun_time, 1, weapon2.stun_color))
					#ball1.apply_central_impulse((Vector2(cos(angle), sin(angle))) * thrust)
				else:if(collisionLayer == 2):
					ball2.health -= damage
					weapon1.increase_stats()
					await(hit_pause(weapon1.stun_time, 2, weapon1.stun_color))
					#ball2.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))
			if(is_instance_valid(ball1)):
				if(ball1.health <= 0):
					end_game(ball2, weapon2.type, col2)
				else: if(ball2.health <= 0):
					end_game(ball1, weapon1.type, col1)

func _on_weapon_parry(angle: Variant, contactLayer: Variant) -> void:
	var thrust = Vector2(0, -250)
	if(tangible):
		$attackTimeout.start()
		if(contactLayer == 4) :
			ball1.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))
			#weapon1.rotation_speed *= randf_range(1.1, 1.4)
			
		else :
			ball2.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))
			#weapon2.rotation_speed *= randf_range(1.1, 1.4)
		tangible = false

func _on_attack_timeout_timeout() -> void:
	if(is_instance_valid(ball1) && is_instance_valid(ball2)):
		tangible = true
		#if(weapon1.rotation_speed >= 0):
			#weapon1.rotation_speed = weapon1.baseRotation
		#else: if(weapon1.rotation_speed < 0): weapon1.rotation_speed = weapon1.baseRotation * -1
		#
		#if(weapon2.rotation_speed >= 0):
			#weapon2.rotation_speed = weapon2.baseRotation
		#else: if(weapon2.rotation_speed < 0):weapon2.rotation_speed = weapon2.baseRotation * -1


	
