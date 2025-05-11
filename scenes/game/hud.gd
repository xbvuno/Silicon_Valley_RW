extends Control

@export_group("Nodes")
@export var PAUSE_MENU : Control
@export var DEBUG_MENU : Control
@export var RETICLE : Control

var in_pause :bool = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if in_pause:
			start_game()
			PAUSE_MENU.reset()
		else:
			stop_game()
			
func _unhandled_input(event: InputEvent) -> void:
	if in_pause:
		if Input.mouse_mode ==Input.MOUSE_MODE_CAPTURED:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if Input.MOUSE_MODE_VISIBLE:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
func stop_game():
	get_tree().paused = true
	PAUSE_MENU.visible = true
	in_pause = true
	RETICLE.visible = false

func start_game():
	get_tree().paused = false
	PAUSE_MENU.visible = false
	in_pause = false
	RETICLE.visible = true
	
func _on_pause_menu_riprendi() -> void:
	start_game()
