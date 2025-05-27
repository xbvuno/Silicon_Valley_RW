extends State

## This value will be set by the state machine
var OWNER: Enemy
var SM: SM_Enemy
var CHARACTER: Character
var C_SM: SM_Character
var sm_name: SM_Enemy.States
var readable_name: String

func _physics_process(_delta: float) -> void:
	look_at_player()
	move_to_player()


func enter_state():
	OWNER.MESH.mesh.material.albedo_color = Color(1, 0, 0, 0)
	
func exit_state():
	pass

func look_at_player():
	var player_position : Vector3 = OWNER.CHARACTER.global_position 
	var current_position = OWNER.global_transform.origin
	# Calcola la direzione
	var direction = (player_position - current_position).normalized()
	# Evita rotazioni errate quando l'oggetto guarda direttamente in su o in giù
	if direction != Vector3.ZERO:
		OWNER.look_at(player_position, Vector3.UP)
		OWNER.rotation.x = 0
		OWNER.rotation.z = 0
	
	
func move_to_player():
	var player_position = OWNER.CHARACTER.global_position 
	var direction = OWNER.global_position.direction_to(player_position) * OWNER.SPEED
	OWNER.velocity.x = direction.x
	OWNER.velocity.z = direction.z
