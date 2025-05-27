extends State

## This value will be set by the state machine
var OWNER: Control
var SM: SM_HUD
var sm_name: SM_HUD.States
var readable_name: String


func enter_state():
	get_tree().paused = true
	OWNER.MAIN_MENU.visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if Global.GAME_MANAGER != null:
		Global.GAME_MANAGER.change_scene("main_menu_background")
	
func exit_state():
	get_tree().paused = false
	OWNER.MAIN_MENU.visible = false


func _on_main_menu_change_scene(scene_id: String) -> void:
	SM.switch(SM.States.IN_GAME)
