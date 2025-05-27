extends State

## This value will be set by the state machine
var OWNER: Control
var SM: SM_HUD
var sm_name: SM_HUD.States
var readable_name: String


func _physics_process(_delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	pass

func enter_state():
	OWNER.MAIN_MENU.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Global.GAME_MANAGER != null:
		Global.GAME_MANAGER.change_scene("main_menu_background")
	
func exit_state():
	OWNER.MAIN_MENU.visible = false


func _on_main_menu_change_scene(scene_id: String) -> void:
	SM.switch(SM.States.IN_GAME)
