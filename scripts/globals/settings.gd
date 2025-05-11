extends Node

@onready var mouse_sensitivity : float = 0.1

signal mouse_sensitivity_changed()

func set_mouse_sensitivity(value:float):
	mouse_sensitivity = value
	mouse_sensitivity_changed.emit()
