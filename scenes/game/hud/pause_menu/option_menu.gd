extends Control

@export_group("Nodes")
@export var AUDIO_SLIDER : HSlider
@export var AUDIO_PERCENTILE_LABEL : Label
@export var RESOLUTION_OPTION_BUTTON : OptionButton
@export var audio_bus_name := "Master"
@export var MOUSE_SENSITIVITY_LABEL : Label
@export var MOUSE_SENSITIVITY_SLIDER : HSlider

@onready var _bus := AudioServer.get_bus_index(audio_bus_name)

var audio_volume : float

signal back_clicked()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MOUSE_SENSITIVITY_SLIDER.value = Settings.mouse_sensitivity
	MOUSE_SENSITIVITY_LABEL.text = str(Settings.mouse_sensitivity *100)
	AUDIO_SLIDER.value = 100
	audio_volume = db_to_linear(AudioServer.get_bus_volume_db(_bus))


func _on_h_slider_value_changed(value: float) -> void:
	update_audio_label(value)
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
	print(linear_to_db(value))

func update_audio_label(aux_volume):
	AUDIO_PERCENTILE_LABEL.text= str(aux_volume*100)+"%"
	

func toggle_visibility():
	visible = !visible

func _on_indietro_pressed() -> void:
	back_clicked.emit()


func _on_sensitivity_slider_value_changed(value: float) -> void:
	Settings.set_mouse_sensitivity(value)
	MOUSE_SENSITIVITY_LABEL.text = str(value*100)
