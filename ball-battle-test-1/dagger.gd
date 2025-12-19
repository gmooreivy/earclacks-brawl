extends Area2D
signal weapon_attack(angle, weapon_damage, parent, contactLayer)
signal weapon_parry(angle, contactLayer)
var rotation_speed = 10
var damage = 1
var scalar = 0
var stun_time = 0.2
var stun_color = '888888'
var baseRotation = 10
const scalarattr = "Speed"
const type = "Dagger"

func reset_stats():
	damage = 1
	rotation_speed = 10
	
	scalar = 0

	

func increase_stats():
	scalar += 10
	if(rotation_speed > 0):
		rotation_speed += 2.5
	else: rotation_speed -= 2.5
	baseRotation = rotation_speed
	if((scalar / 10) % 10 == 0):
		damage += 2
	print(rotation_speed)

func _process(delta):
	rotation += rotation_speed * delta
	global_position = get_parent().global_position

func _on_body_entered(body: RigidBody2D) -> void:

	var rotationMath = rotation
	emit_signal("weapon_attack", rotation, damage, body.collision_layer)
	
	
func _on_area_entered(area: Area2D) -> void:
	rotation_speed *= -1
	var rotationMath = rotation_degrees
	var spins = abs(roundi(rotationMath / 360))
	rotationMath = roundi(rotationMath - (spins * 360)) 
	emit_signal("weapon_parry", rotationMath, area.collision_layer)
	
