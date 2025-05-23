extends State

## This value will be set by the state machine
var OWNER: Control
var SM: SM_HUD
var sm_name: SM_HUD.States
var readable_name: String

func _physics_process(_delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_esc'):
		SM.switch(SM.States.PAUSE)

func enter_state():
	SM.DEBUG_MENU.visible = Settings.debug_mode
	SM.PAUSE_MENU.visible = false
func exit_state():
	SM.PAUSE_MENU.visible = true
