extends CharacterBody3D
class_name Enemy
@export_group("Nodes")
@export var occhiali : MeshInstance3D 

@export var AREA_SMALL: Area3D
@export var AREA_BIG: Area3D

@onready var COLLISION: CollisionShape3D = $CollisionShape3D
@onready var MESH: MeshInstance3D = $MeshInstance3D
@onready var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

## SISTEMARE GLI EXPORT

@export var MAX_HEALTH = 20
@onready var health = MAX_HEALTH

@export var SPEED : float = 7.

@onready var SM: SM_Enemy = $StateMachine
@onready var CHARACTER: Character = Global.PLAYER
@onready var C_SM: SM_Character = Global.PLAYER.SM


func _ready():
	$FreezeTimer.timeout.connect(unpause)
	AREA_SMALL.body_entered.connect(SM.STATES[SM.S_ROAMING].on_body_enter_area_small)
	AREA_SMALL.body_exited.connect(SM.STATES[SM.S_ROAMING].on_body_exit_area_small)
	
	AREA_BIG.body_entered.connect(SM.STATES[SM.S_ROAMING].on_body_enter_area_big)
	AREA_BIG.body_exited.connect(SM.STATES[SM.S_ROAMING].on_body_exit_area_big)
	
	ready.connect(SM.on_owner_ready)
	
	#%Character.SM.state_changed.connect(character_state_changed)
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	move_and_slide()
	

func pause():
	process_mode = Node.PROCESS_MODE_DISABLED
	$MeshInstance3D.mesh.material.albedo_color = Color(1, 0, 0, 1)
	
func unpause():
	process_mode = Node.PROCESS_MODE_INHERIT
	$MeshInstance3D.mesh.material.albedo_color = Color(0, 1, 0, 1)


func got_parried():
	$FreezeTimer.start()
	pause()

func take_damage(damage):
	health -= damage
	print(self, ' AUCH [HP: ', health, ']')
	if health <= 0:
		queue_free()
		

func _on_area_3d_area_entered(area: Area3D) -> void:
	return
	if area.is_in_group('weapons'):
		var target = area.get_parent()
		if target.state == 'attack':
			take_damage(target.DAMAGE)
	pass
	


func is_player_hearble()->bool:
	var space_state = get_world_3d().direct_space_state
	var player_position = CHARACTER.global_position
	var query = PhysicsRayQueryParameters3D.create(global_position, player_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if "collider" not in result.keys():
		return false
	
	return result["collider"].is_in_group("player")
