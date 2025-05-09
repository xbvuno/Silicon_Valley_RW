extends Node
class_name State

signal state_started
signal state_ended

func _ready() -> void:
	state_started.connect(state_start)
	state_ended.connect(state_end)
	set_process_input(false)
	set_physics_process(false)

func state_start() -> void:
	enter_state()
	set_physics_process(true)
	set_process_input(true)
	
func state_end() -> void:
	set_process_input(false)
	set_physics_process(false)
	exit_state()

func enter_state() -> void:
	pass

func exit_state() -> void:
	pass
