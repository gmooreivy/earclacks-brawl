extends Area2D
signal weapon_attack(angle, weapon_damage, parent, contactLayer)
signal weapon_parry(angle, contactLayer)
var rotation_speed = 7.4
var damage = 2
var scalar = 5
var baseRotation = 7.4
var stun_time = 0.25
var stun_color = "CCCCCC"
var critStatus = false
const scalarattr = "Crit chance/damage"
const type = "Rapier"

func reset_stats():
	damage = 3
	rotation_speed = 7.4
	critStatus = false
	scalar = 5

	

func increase_stats():
	scalar += 5

func _process(delta):
	rotation += rotation_speed * delta
	global_position = get_parent().global_position
	

func _on_body_entered(body: RigidBody2D) -> void:
	var dealtDamage = damage
	if(randi() % 100) <= scalar:
		stun_time = 0.75
		stun_color = "#FFD15D"
		critStatus = true
		dealtDamage *= (scalar / 25) + 1
	else:
		stun_color = "CCCCCC"
		critStatus = false
		stun_time = 0.25
		
	emit_signal("weapon_attack", rotation, dealtDamage, body.collision_layer)
	
	
func _on_area_entered(area: Area2D) -> void:
	rotation_speed *= -1
	var rotationMath = rotation_degrees
	var spins = abs(roundi(rotationMath / 360))
	rotationMath = roundi(rotationMath - (spins * 360)) 
	emit_signal("weapon_parry", rotationMath, area.collision_layer)
	
