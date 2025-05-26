extends CharacterBody3D
class_name Enemy
@export_group("Nodes")
@export var occhiali : MeshInstance3D 
@export var small_area: Area3D
@export var big_area: Area3D


@onready var COLLISION: CollisionShape3D = $CollisionShape3D
@onready var MESH: MeshInstance3D = $MeshInstance3D
@onready var GRAVITY = ProjectSettings.get_setting("physics/3d/default_gravity")

## SISTEMARE GLI EXPORT

@export var MAX_HEALTH = 20
@onready var health = MAX_HEALTH

@export var SPEED : float = 7

@onready var SM : SM_ENEMY = $StateMachine

var in_big_area : bool  = false
var in_small_area: bool = false

func _ready():
	$FreezeTimer.timeout.connect(unpause)
	#%Character.SM.state_changed.connect(character_state_changed)
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	move_and_slide()
	
	if in_small_area:
		player_in_small_area()
	elif in_big_area:
		player_in_big_area()
	
	
	if SM.current_state.sm_name == SM.States.FOLLOWING:
		look_at_player()
		move_to_player(delta)

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
	
func look_at_player():
	var player_position : Vector3 = %Character.global_position 
	# Ottieni la posizione attuale
	var current_position = global_transform.origin
	# Calcola la direzione
	var direction = (player_position - current_position).normalized()
	# Evita rotazioni errate quando l'oggetto guarda direttamente in su o in giù
	if direction != Vector3.ZERO:
		look_at(player_position, Vector3.UP)
		rotation.x = 0
		rotation.z = 0
	
	
	
func move_to_player(delta):
	var player_position = %Character.global_position
	var direction = global_position.direction_to(player_position)* SPEED
	velocity.x = direction.x
	velocity.z = direction.z


func character_state_changed(old_state,new_state):
	var char_SM = %Character.SM
	if new_state == char_SM.S_CROUCH :
		return
	if big_area.overlaps_body(%Character):
		if new_state not in  [char_SM.S_WALK,char_SM.S_IDLE]:
			if is_player_hearble():
				SM.switch(SM.States.FOLLOWING)
				return
	if small_area.overlaps_body(%Character):
		if is_player_hearble():
			SM.switch(SM.States.FOLLOWING)

		
	

func _on_trigger_area_small_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_small_area = true


func _on_trigger_area_big_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_big_area = true

func _on_trigger_area_small_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_small_area = false

func _on_trigger_area_big_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		in_big_area = false

func player_in_big_area():
	var char_SM = %Character.SM
	if is_player_hearble():
		if not [char_SM.States.WALK, char_SM.States.CROUCH, char_SM.States.IDLE].any(char_SM.is_current):
		#if not char_SM.is_current(char_SM.States.WALK) or not char_SM.is_current(char_SM.States.CROUCH):
			SM.switch(SM.States.FOLLOWING)
			
func player_in_small_area():
	var char_SM = %Character.SM
	if is_player_hearble():
		if not char_SM.is_current(char_SM.States.CROUCH):
			SM.switch(SM.States.FOLLOWING)

func is_player_hearble()->bool:
	var space_state = get_world_3d().direct_space_state
	var player_position = %Character.global_position
	var query = PhysicsRayQueryParameters3D.create(global_position, player_position)
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	
	if "collider" not in result.keys():
		return false
	
	return result["collider"].is_in_group("player")
