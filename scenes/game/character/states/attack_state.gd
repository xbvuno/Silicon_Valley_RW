extends State
class_name CharacterAttackState

@export var weapon: Weapon

func _ready() -> void:
	super()
	state_name = States.States.ATTACK

func _physics_process(_delta: float) -> void:
	if weapon.state == 'idle':
		character_node.state_machine.switch_action_state(States.States.NONE)
	
func _input(event: InputEvent) -> void:
	pass

func enter_state():
	weapon.attack()
	
func exit_state():
	pass
