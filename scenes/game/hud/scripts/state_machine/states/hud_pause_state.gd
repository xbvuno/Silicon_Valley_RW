extends State

## This value will be set by the state machine
var OWNER: Control
var SM: SM_HUD
var sm_name: SM_HUD.States
var readable_name: String

func _physics_process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_esc"):
		SM.switch(SM.States.IN_GAME)

func enter_state()-> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	get_tree().paused = true
	SM.PAUSE_MENU.visible = true
	OWNER.PAUSE_MENU.reset()

func exit_state()-> void:
	get_tree().paused = false
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 	##non serve perchè è risolto in IN_GAME state
	SM.PAUSE_MENU.visible = false
