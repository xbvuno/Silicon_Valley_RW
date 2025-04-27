extends State
class_name CharacterNoneState

@export var weapon: Weapon

var attack_blocked_by: Array[States.States] = [
	States.States.DASHING,
	States.States.JUMPING,
	States.States.AIR_JUMP,
]

var parry_blocked_by: Array[States.States] = [
	States.States.CROUCHING,
	States.States.SPRINTING,
	States.States.DASHING,
	States.States.JUMPING,
	States.States.AIR_JUMP,
]

func _ready() -> void:
	super()
	state_name = States.States.NONE

func _physics_process(_delta: float) -> void:
	pass
	
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("a_attack") && !is_attack_blocked():
		character_node.state_machine.switch_action_state(States.States.ATTACK)
	if Input.is_action_just_pressed("a_defend") && !is_parry_blocked():
		if weapon.PARRY_COOLDOWN_TIMER.is_stopped():
			character_node.state_machine.switch_action_state(States.States.PARRY)

func is_attack_blocked() -> bool:
	return character_node.state_machine.current_movement.state_name in attack_blocked_by

func is_parry_blocked() -> bool:
	return character_node.state_machine.current_movement.state_name in parry_blocked_by

func is_idle_weapon() -> bool:
	return weapon.state == 'idle'

func enter_state():
	pass
	
func exit_state():
	pass
