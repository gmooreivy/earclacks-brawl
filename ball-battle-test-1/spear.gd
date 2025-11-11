extends Area2D
signal weapon_attack(angle, weapon_damage, parent, contactLayer)
signal weapon_parry(angle, contactLayer)
var rotation_speed = 6.7;
var damage = 1;
var scalar = 0;
var scalarattr = "Length"
var damageCounter = 0

func _process(delta):
	rotation += rotation_speed * delta
	global_position = get_parent().global_position
	

func _on_body_entered(body: Node2D) -> void:
	
	#print(body.get_collision_layer())
	var rotationMath = rotation
	emit_signal("weapon_attack", rotation, damage, get_parent(), body.collision_layer)
	damageCounter += 1
	if(damageCounter >= 3):
		damage += 1
		damageCounter = 0
	
	scale += Vector2(0, 0.1)
	scalar += 0.1
	
func _on_area_entered(area: Area2D) -> void:
	rotation_speed *= -1
	var rotationMath = rotation_degrees
	var spins = abs(roundi(rotationMath / 360))
	rotationMath = roundi(rotationMath - (spins * 360)) 
	emit_signal("weapon_parry", rotationMath, area.collision_layer)
	
