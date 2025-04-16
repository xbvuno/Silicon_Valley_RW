extends CharacterBody3D
class_name Enemy

@onready var COLLISION: CollisionShape3D = $CollisionShape3D
@onready var MESH: MeshInstance3D = $MeshInstance3D
@onready var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

## SISTEMARE GLI EXPORT

@export var MAX_HEALTH = 20
@onready var health = MAX_HEALTH


func take_damage(damage):
	health -= damage
	print(self, ' AUCH [HP: ', health, ']')
	if health <= 0:
		queue_free()
		

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group('weapons'):
		var target = area.get_parent()
		if target.state == 'attack':
			take_damage(target.DAMAGE)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	move_and_slide()
	
