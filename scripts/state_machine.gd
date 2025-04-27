extends Node
class_name StateMachine

# Solo per stati di movimento
signal state_changed(old_state, new_state)

@export_category("States")
@export var movement_states: Array[State]
@export var action_states: Array[State]

@export_category("Current States")
@export var current_movement: State
@export var current_action: State

func _ready() -> void:
	current_movement.movement_started.emit()
	current_action.action_started.emit()

func _process(_delta: float) -> void:
	pass

func switch_movement_state(state_class: States.States) -> void:
	var new_state: State = null
	for state: State in movement_states:
		if state.state_name == state_class:
			new_state = state
			break
	
	if current_movement.state_name == state_class:
		return
	
	if new_state == null:
		return
		
	if !new_state.can_transition():
		return
	
	current_movement.movement_ended.emit() # Da settare come costante per uscita di stato
	state_changed.emit(current_movement, new_state)
	current_movement = new_state
	current_movement.movement_started.emit() # Da settare come costante per entrata di stato

func switch_action_state(state_class: States.States) -> void:
	
	var new_state: State = null
	for state: State in action_states:
		if state.state_name == state_class:
			new_state = state
			break
	
	if new_state == null:
		return
		
	if current_action.state_name == state_class:
		return
	
	if !new_state.can_transition():
		return
	
	current_action.action_ended.emit() # Da settare come costante per uscita di stato
	current_action = new_state
	current_action.action_started.emit() # Da settare come costante per entrata di stato
