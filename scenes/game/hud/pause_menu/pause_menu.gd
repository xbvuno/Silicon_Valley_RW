extends Control
@export_group("Nodes")
@export var OPTIONS_MENU : Control
@export var MAIN_MENU : Control
@export var CONTROLS_MENU: Control
@export var HUD : Control
@export var STATE_MACHINE : SM_PAUSE_MENU
@export var STATE_MACHINE_HUD : SM_HUD

signal back_to_menu()


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
func _on_riprendi_pressed() -> void:
	STATE_MACHINE_HUD.switch(STATE_MACHINE_HUD.States.IN_GAME)

func _on_opzioni_pressed() -> void:
	STATE_MACHINE.switch(STATE_MACHINE.States.SETTINGS)

func _on_esci_pressed() -> void:
	back_to_menu.emit()

func _on_option_menu_back_clicked() -> void:
	STATE_MACHINE.switch(STATE_MACHINE.States.PAUSE)



func _on_comandi_pressed() -> void:
	STATE_MACHINE.switch(STATE_MACHINE.States.CONTROLS)

#Comandi indietro
func _on_indietro_pressed() -> void:
	STATE_MACHINE.switch(STATE_MACHINE.States.PAUSE)


func reset()->void:
	STATE_MACHINE.switch(STATE_MACHINE.States.PAUSE)
