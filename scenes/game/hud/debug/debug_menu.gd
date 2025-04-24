extends Control

## Control che rimarrà in vista mentre il DebugMenu è chiuso
@onready var ALWAYS_SHOWN: Control = $AlwaysShownLabel;
## Control che verrà mostrato
@onready var DEBUG_PANEL: Control = $MarginContainer;
## Meta finale dove andranno appese le label
@onready var LABELS_CONTAINER: Control = $MarginContainer/Panel/MarginContainer/VBoxContainer; 

@export var TOGGLE_DEBUG_ACTION: String = 'a_debug'

var LABEL_FONT: FontFile = preload("uid://bj022vx1alxl") # res://assets/themes/fonts/SpaceMono-Regular.ttf
var HIGHLIGHT_COLOR: Color = Color(1, 1, 0)
var shown: bool = false;

var properties_to_display: Dictionary[String, Variant] = {
	'fps': func() -> int: return int(Performance.get_monitor(Performance.TIME_FPS)),
}

func toggle_shown() -> void:
	shown = !shown
	ALWAYS_SHOWN.visible = !shown
	DEBUG_PANEL.visible = shown

func _ready() -> void:
	for prop: String in properties_to_display:
		var value: Variant = properties_to_display[prop]
		var label: Label = Label.new()
		label.add_theme_font_override("font", LABEL_FONT)
		if value == null:
			label.text = prop
			label.add_theme_color_override("font_color", HIGHLIGHT_COLOR)
		properties_to_display[prop] = {
			'fn': value,
			'lb': label
		}
		LABELS_CONTAINER.add_child(label)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed(TOGGLE_DEBUG_ACTION):
		toggle_shown()
	
	if !shown:
		return
	
	for prop: String in properties_to_display:
		var obj: Variant = properties_to_display[prop]
		if obj['fn'] == null:
			continue
		obj['lb'].text = str( prop.to_upper(), ': ', obj['fn'].call() )
		
		
