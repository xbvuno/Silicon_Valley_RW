## [spacci] State Machine del HUD 

extends Node
class_name SM_Enemy

enum States {
	ROAMING,FOLLOWING,ATTACKING,STUNNED
}

## LEGGIBILITÀ: Alias per gli States, in modo da non dover chiamare ogni volta States.Papera
const S_ROAMING : States = States.ROAMING
const S_FOLLOWING : States = States.FOLLOWING
const S_ATTACKING: States = States.ATTACKING
const S_STUNNED : States = States.STUNNED

const STATE_NAMES: Dictionary[States, String] = {
	States.ROAMING: "Roaming",
	States.FOLLOWING: "Following",
	States.ATTACKING: "Attacking",
	States.STUNNED:"Stunned"
}

@onready var STATES: Dictionary[States, State] = {
	States.ROAMING:$Roaming,
	States.FOLLOWING:$Following,
	States.ATTACKING:$Attacking,
	States.STUNNED:$Stunned
}


@onready var OWNER: Enemy = $".."

func after_setup() -> void:
	current_state = STATES[S_ROAMING]
	current_state.state_started.emit()

const _PRINT_PREFIX = "ENEMY_"

#region UnderTheHood

## [bvuno] Questa parte di codice dovrebbe essere la stessa per tutte le state machine. se devi aggiungere qualcosa al _ready usa after_setup.

signal state_changed(old_state: States, new_state: States)

var current_state: State

func on_owner_ready():
	for state_name: States in STATES:
		var state_node: State = STATES[state_name]
		state_node.OWNER = OWNER
		state_node.SM = self
		state_node.CHARACTER = OWNER.CHARACTER
		state_node.C_SM = OWNER.C_SM
		state_node.sm_name = state_name
		state_node.readable_name = STATE_NAMES[state_name]
	after_setup()

func switch(sm_state: States) -> void:
	if sm_state == current_state.sm_name:
		push_warning("[", _PRINT_PREFIX, "SM] tried to change the current state ", current_state.readable_name, " to itself.")
		return
		
	var new_state_node = STATES[sm_state]
	current_state.state_ended.emit()
	state_changed.emit(current_state.sm_name, sm_state)
	#print("[", _PRINT_PREFIX, "SM] ", current_state.readable_name, ' -> ', new_state_node.readable_name)
	current_state = new_state_node
	new_state_node.state_started.emit()

	

#endregion
