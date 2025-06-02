extends Control

@export_group("Nodes")
@export var CHARACTER : Character
@export var MAIN_MENU: Control 
@export var PAUSE_MENU : Control

@onready var MAIN_PAUSE_MENU : Control = $HudStateMachine/Pause/PauseMenu/MarginContainer/PanelContainer/MainMenu
@onready var CONTROL_PAUSE_MENU: Control = $HudStateMachine/Pause/PauseMenu/MarginContainer/PanelContainer/Comandi
@onready var SETTINGS_PAUSE_MENU: Control = $HudStateMachine/Pause/PauseMenu/MarginContainer/PanelContainer/OptionMenu
@onready var DEBUG_MENU : Control = $"HudStateMachine/In Game/DebugMenu"
@onready var RETICLE : Control = $"HudStateMachine/In Game/Reticle"
@onready var HEALTH_BAR : Control = $"HudStateMachine/In Game/HealthBar"
@onready var SM : SM_HUD = $HudStateMachine

signal change_scene(scene_id : String)

func _ready() -> void:
	MAIN_MENU.change_scene.connect((func (scene_id):change_scene.emit(scene_id)))


func _on_pause_menu_riprendi() -> void:
	SM.switch(SM.States.IN_GAME)


func _on_pause_menu_back_to_menu() -> void:
	SM.switch(SM.States.MAIN_MENU)

