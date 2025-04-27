extends Node
class_name State

signal movement_started
signal movement_ended

signal action_started
signal action_ended

var character_node: Character
var state_name: States.States

func _ready() -> void:
	movement_started.connect(state_start)
	movement_ended.connect(state_end)
	action_started.connect(state_start)
	action_ended.connect(state_end)
	set_physics_process(false)
	set_process_input(false)
	if owner is Character:
		character_node = owner
	else:
		push_error("Owner is not a Character!")

func state_start() -> void:
	enter_state()
	set_physics_process(true)
	set_process_input(true)
	
func state_end() -> void:
	set_physics_process(false)
	set_process_input(false)
	exit_state()

# Abstract Like
func can_transition() -> bool:
	return true

func enter_state() -> void:
	pass

func exit_state() -> void:
	pass
