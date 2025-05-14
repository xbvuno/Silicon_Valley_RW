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
	if Input.is_action_just_pressed('ui_esc'):
		SM.switch(SM.States.PAUSE)

func enter_state():
	get_tree().paused = false
	SM.RETICLE.visible = true
	SM.PAUSE_MENU.visible = false
	SM.DEBUG_MENU.visible = Settings.debug_mode
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func exit_state():
	pass
