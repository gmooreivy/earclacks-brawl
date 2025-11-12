extends Node
signal hit_timeout
@onready var ball1 = $BallContainer1/CanvasModulate/Ball1
@onready var ball2 = $BallContainer2/CanvasModulate/Ball2
@onready var spear1 = $BallContainer1/CanvasModulate/Ball1/spear1
@onready var spear2 = $BallContainer2/CanvasModulate/Ball2/spear2
@onready var label1 = $BallContainer1/CanvasModulate/Ball1/label1
@onready var label2 = $BallContainer2/CanvasModulate/Ball2/label2
@onready var dmg1 = $GUI/CanvasLayer/dmg1
@onready var sclr1 = $GUI/CanvasLayer/sclr1
@onready var dmg2 = $GUI2/CanvasLayer2/dmg2
@onready var sclr2 = $GUI2/CanvasLayer2/sclr2
@onready var col1 = $BallContainer1/CanvasModulate.color
@onready var col2 = $BallContainer2/CanvasModulate.color
@onready var tangible = true


func _ready():
	
	$GUI/CanvasLayer.color = col1
	$GUI2/CanvasLayer2.color = col2
	print(col1, col2)
	spear2.rotation_degrees = randi_range(90, 270)
	

func _process(float) -> void:
	#print(label1)
	label1.text = str(ball1.health)
	label2.text = str(ball2.health)
	sclr1.text = str(spear1.scalarattr, ": ", spear1.scalar + 1)
	dmg1.text = str("Damage: ", spear1.damage)
	sclr2.text = str(spear2.scalarattr, ": ", spear2.scalar + 1)
	dmg2.text = str("Damage: ", spear2.damage)
	
	if(ball1.health <= 0):
		end_game('ball2')
	else: if(ball2.health <= 0):
		end_game('ball1')
	
	
func end_game(winner):
	if(winner == 'ball1'):
		ball2.queue_free()
	else:
		ball1.queue_free()
		
func hit_pause(timeScale, duration):
#	Credits to Master Albert on youtube
	Engine.time_scale = timeScale
	await(get_tree().create_timer(duration * timeScale).timeout)
	Engine.time_scale = 1.0


func _on_weapon_attack(angle, damage, parent, collisionLayer) -> void:
	#print("-- START --")
	#print("Angle: ", angle)
	#print("Damage: ", damage)
	#print("Parent: ", parent)
	#print("Layer: ", collisionLayer)
	#print("-- END --")
	
	match collisionLayer:
		1, 2:
			print("ball hit")
			var thrust = Vector2(0, -100)
			hit_pause(0.05, 0.5)
			if(collisionLayer == 1 && tangible):
				ball1.health -= damage
				ball1.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))
			else:if(collisionLayer == 2):
				ball2.health -= damage
				ball2.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))


func _on_weapon_parry(angle: Variant, contactLayer: Variant) -> void:
	var thrust = Vector2(0, -25)
	if(tangible):
		$attackTimeout.start()
		if(contactLayer == 4) :
			ball1.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))
			#print("Applied force to ball 1")
		else :
			ball2.apply_central_impulse((Vector2(cos(angle), sin(angle)) * thrust))
		#	print("Applied force to ball 2")
		hit_pause(0.05, 0.5)
		tangible = false
	#print("+ PARRY")
	#print("Layer: ", contactLayer)
	
	


func _on_attack_timeout_timeout() -> void:
	tangible = true
