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
var resolution_dictionary : Dictionary = {
	"1440p":Vector2i(2560,1440),
	"1080p":Vector2i(1920,1080),
	"720p":Vector2i(1280,720),
}
signal back_clicked()
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MOUSE_SENSITIVITY_SLIDER.value = Settings.mouse_sensitivity
	MOUSE_SENSITIVITY_LABEL.text = str(Settings.mouse_sensitivity *100)
	AUDIO_SLIDER.value = 100
	for key in resolution_dictionary.keys():
		RESOLUTION_OPTION_BUTTON.add_item(key)
	RESOLUTION_OPTION_BUTTON.select(1)
	audio_volume = db_to_linear(AudioServer.get_bus_volume_db(_bus))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_h_slider_value_changed(value: float) -> void:
	update_audio_label(value)
	AudioServer.set_bus_volume_db(_bus, linear_to_db(value))
	print(linear_to_db(value))

func update_audio_label(audio_volume):
	AUDIO_PERCENTILE_LABEL.text= str(audio_volume*100)+"%"
	
	
##TODO Non funziona
func change_resolution(resolution:String):
	var resolution_vector : Vector2i = resolution_dictionary[resolution]
	#ProjectSettings.set_setting("display/window/size/width",resolution_vector[0])
	#ProjectSettings.set_setting("display/window/size/height",resolution_vector[1])
	get_window().content_scale_size = resolution_vector
	
	# center window
	#var screen_center = DisplayServer.screen_get_position()+DisplayServer.get_window_at_screen_position() 
	#var window_size = get_window().get_size_with_decorations()
	#get_window().set_ime_position(screen_center-window_size/2)
	
	get_window().size = resolution_vector
	get_window().content_scale_size = resolution_vector
	get_window().mode = Window.MODE_WINDOWED
	get_window().position =DisplayServer.screen_get_size(DisplayServer.get_primary_screen())/2
	get_window().content_scale_size = resolution_vector





func _on_option_button_item_selected(index: int) -> void:
	var text = RESOLUTION_OPTION_BUTTON.get_item_text(index)
	change_resolution(text)

func toggle_visibility():
	visible = !visible


func _on_indietro_pressed() -> void:
	back_clicked.emit()



	


func _on_sensitivity_slider_value_changed(value: float) -> void:
	Settings.set_mouse_sensitivity(value)
	MOUSE_SENSITIVITY_LABEL.text = str(value*100)
