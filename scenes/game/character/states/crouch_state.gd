extends State
class_name CharacterCrouchState

func _ready() -> void:
	super()
	state_name = States.States.CROUCHING

func _physics_process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_released(character_node.CONTROLS.CROUCH):
		character_node.state_machine.switch_movement_state(States.States.IDLE)

func enter_state():
	character_node.speed = character_node.CROUCH_SPEED
	character_node.CROUCH_ANIMATION.play("crouch")
	
func exit_state():
	character_node.speed = character_node.BASE_SPEED
	character_node.CROUCH_ANIMATION.play_backwards("crouch")
