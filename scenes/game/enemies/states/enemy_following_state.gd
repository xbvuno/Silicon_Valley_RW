extends State

## This value will be set by the state machine
var OWNER: Enemy
var SM: SM_Enemy
var CHARACTER: Character
var C_SM: SM_Character
var sm_name: SM_Enemy.States
var readable_name: String

#@onready var timer : Timer = Utils.timer_from_time(2,false,self,(func ():OWNER.AUDIO_PLAYER.play();timer.start()).call())
@onready var frame_counter : int =0
func _physics_process(_delta: float) -> void:
	look_at_player()
	move_to_player()
	
	#if timer.is_stopped():
		#OWNER.AUDIO_PLAYER.play()
		#timer = Utils.timer_from_time(2,self)
		#
	
	

func enter_state():
	OWNER.MESH.mesh.material.albedo_color = Color(1, 0, 0, 0)
	OWNER.NAVIGATION_AGENT.target_position = Global.PLAYER.global_position
	
	
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
	if frame_counter == OWNER.FRAME_TO_UPDATE_TARGET_POSITION:
		OWNER.NAVIGATION_AGENT.target_position = Global.PLAYER.global_position
		frame_counter = 0
	else:
		frame_counter += 1
	var next_position = OWNER.NAVIGATION_AGENT.get_next_path_position()
	print(next_position)
	var direction = (next_position - OWNER.global_position).normalized()
	OWNER.velocity = direction * OWNER.SPEED
