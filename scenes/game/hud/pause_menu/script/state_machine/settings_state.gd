extends State

## This value will be set by the state machine
var OWNER: Control
var SM: SM_PAUSE_MENU
var sm_name: SM_PAUSE_MENU.States
var readable_name: String

func _physics_process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_esc"):
		SM.switch(SM.States.PAUSE)

func enter_state():
	OWNER.OPTIONS_MENU.visible = true
	
func exit_state():
	OWNER.OPTIONS_MENU.visible = false
