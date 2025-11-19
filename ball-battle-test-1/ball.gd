extends RigidBody2D
@onready var health = 100

func _ready():
	var rand_force = Vector2(randf_range(-150, 150), randi_range(-1, 1) * 150)
	apply_impulse(rand_force)

func _process(delta) -> void:
	if(rotation >= 1 || rotation <= -1):
		print(rotation)
		rotation = 0;
func configCollision():
	pass
#	set up collision layers YOU MORON ITS PER OBJECT DO IT IN THE OTHER FUNCTION IN MAIN NVM NVM NVM
