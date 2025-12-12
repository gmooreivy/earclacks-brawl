extends Area2D
signal weapon_attack(angle, weapon_damage, parent, contactLayer)
signal weapon_parry(angle, contactLayer)
var rotation_speed = 6.3
var baseRotation = 6.3
var damage = 1
var scalar = 1
var stun_time = 0.25
var stun_color = "CCCCCC"
const scalarattr = "Damage"
const type = "Sword"

func reset_stats():
	damage = 1
	rotation_speed = 6.3
	scalar = 0

func increase_stats():
	scalar += 1
	damage = scalar

func _process(delta):
	rotation += rotation_speed * delta
	global_position = get_parent().global_position
	

func _on_body_entered(body: Node2D) -> void:
	emit_signal("weapon_attack", rotation, damage, body.collision_layer)
	
func _on_area_entered(area: Area2D) -> void:
	rotation_speed *= -1
	var rotationMath = rotation_degrees
	var spins = abs(roundi(rotationMath / 360))
	rotationMath = roundi(rotationMath - (spins * 360)) 
	emit_signal("weapon_parry", rotationMath, area.collision_layer)
