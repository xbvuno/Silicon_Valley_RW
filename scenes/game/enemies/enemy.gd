extends CharacterBody3D
class_name Enemy

@onready var COLLISION: CollisionShape3D = $CollisionShape3D
@onready var MESH: MeshInstance3D = $MeshInstance3D
@onready var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity")

## SISTEMARE GLI EXPORT

@export var MAX_HEALTH: float = 20
@onready var health: float = MAX_HEALTH

func pause() -> void:
	process_mode = Node.PROCESS_MODE_DISABLED
	$MeshInstance3D.mesh.material.albedo_color = Color(1, 0, 0, 1)
	
func unpause() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	$MeshInstance3D.mesh.material.albedo_color = Color(0, 1, 0, 1)

func _ready() -> void:
	$FreezeTimer.timeout.connect(unpause)

func got_parried() -> void:
	$FreezeTimer.start()
	pause()

func take_damage(damage: float) -> void:
	health -= damage
	print(self, ' AUCH [HP: ', health, ']')
	if health <= 0:
		queue_free()
		

func _on_area_3d_area_entered(area: Area3D) -> void:
	if area.is_in_group('weapons'):
		var target: Node3D = area.get_parent()
		if target.state == 'attack':
			take_damage(target.DAMAGE)


func _physics_process(delta: float) -> void:
	if !is_on_floor():
		velocity.y -= GRAVITY * delta
	move_and_slide()
	
