extends Control

@export_group("Nodes")
@export var CHARACTER : Character

@onready var PAUSE_MENU : Control = $HudStateMachine/Pause/PauseMenu
@onready var MAIN_PAUSE_MENU : Control = $HudStateMachine/Pause/PauseMenu/MarginContainer/PanelContainer/MainMenu
@onready var CONTROL_PAUSE_MENU: Control = $HudStateMachine/Pause/PauseMenu/MarginContainer/PanelContainer/Comandi
@onready var SETTINGS_PAUSE_MENU: Control = $HudStateMachine/Pause/PauseMenu/MarginContainer/PanelContainer/OptionMenu
@onready var DEBUG_MENU : Control = $"HudStateMachine/In Game/DebugMenu"
@onready var RETICLE : Control = $"HudStateMachine/In Game/Reticle"
@onready var SM : SM_HUD = $HudStateMachine

func _ready() -> void:
	pass


func _on_pause_menu_riprendi() -> void:
	SM.switch(SM.States.IN_GAME)
