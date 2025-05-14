extends Control
@export_group("Nodes")
@export var OPTIONS_MENU : Control
@export var MAIN_MENU : Control
@export var CONTROLS_MENU: Control
@export var HUD : Control
var SM : SM_HUD



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SM = HUD.SM
	
func _on_riprendi_pressed() -> void:
	SM.switch(SM.States.IN_GAME)

func _on_opzioni_pressed() -> void:
	SM.switch(SM.States.SETTINGS)

func _on_esci_pressed() -> void:
	get_tree().quit()

func _on_option_menu_back_clicked() -> void:
	SM.switch(SM.States.PAUSE)



func _on_comandi_pressed() -> void:
	SM.switch(SM.States.CONTROLS)

#Comandi indietro
func _on_indietro_pressed() -> void:
	SM.switch(SM.States.PAUSE)
