extends Control

@export_group("Nodes")
@export var PAUSE_MENU : Control
@export var DEBUG_MENU : Control
@export var RETICLE : Control
@export var SM : SM_HUD


	
func _on_pause_menu_riprendi() -> void:
	SM.switch(SM.States.IN_GAME)
