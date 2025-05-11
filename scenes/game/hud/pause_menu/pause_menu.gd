extends Control
@export_group("Nodes")
@export var OPTION_MENU : Control
@export var MAIN_MENU : CenterContainer
@export var RIPRENDI_BUTTON : Button
@export var OPTIONS_BUTTON : Button
@export var ESCI_BUTTON:Button
@export var COMANDI_BUTTON: Button
@export var COMANDI_MENU: Control
signal riprendi()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	OPTION_MENU.visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_riprendi_pressed() -> void:
	print("Riprendi")
	riprendi.emit()



func _on_opzioni_pressed() -> void:
	print("Opzioni")
	MAIN_MENU.visible = false
	OPTION_MENU.visible = true


func _on_esci_pressed() -> void:
	print("Quit")
	get_tree().quit()


func _on_riprendi_button_down() -> void:
	pass


func _on_option_menu_back_clicked() -> void:
	MAIN_MENU.visible = true
	OPTION_MENU.visible = false


func _on_comandi_pressed() -> void:
	MAIN_MENU.visible = false
	COMANDI_MENU.visible = true


func _on_indietro_pressed() -> void:
	MAIN_MENU.visible = true
	COMANDI_MENU.visible = false
func reset():
	MAIN_MENU.visible = true
	COMANDI_MENU.visible = false
	OPTION_MENU.visible = false
