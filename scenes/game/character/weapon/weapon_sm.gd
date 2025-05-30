## State Machine del Character

extends Node
class_name SM_Weapon



## [bvuno] Per pragmaticità questo nodo dovrebbe estendere la classe StateMachine, per aggiungere poi enumerazioni, stati ecc.
## Purtroppo non è possibile estendere gli enum, o settare static typing per essi o per l'owner, e ciò nasconde gli hint nell'editor relativi.
## Prendi questa come verità assoluta, non dubitare di nulla, dio è morto in vano

enum States {
	IDLE, ATTACK, PARRY
}

## LEGGIBILITÀ: Alias per gli States, in modo da non dover chiamare ogni volta States.Papera
const S_IDLE: States = States.IDLE
const S_ATTACK: States = States.ATTACK
const S_PARRY: States = States.PARRY

enum Actions {
}

const STATE_NAMES: Dictionary[States, String] = {
	States.IDLE: "Idle",
	States.ATTACK: "Attacking",
	States.PARRY: "Parrying",
}

@onready var STATES: Dictionary[States, State] = {
	States.IDLE: $"Idle",
	States.ATTACK: $"Attacking",
	States.PARRY: $"Parrying",
}

@onready var ACTIONS: Dictionary = {
}

@onready var OWNER: CurrentWeapon = $".."

func after_setup() -> void:
	current_state = STATES[S_IDLE]
	current_state.state_started.emit()
	for state_node: State in STATES.values():
		state_node.CHARACTER = OWNER.CHARACTER

const _PRINT_PREFIX = "WEAP_"

#region UnderTheHood

## [bvuno] Questa parte di codice dovrebbe essere la stessa per tutte le state machine. se devi aggiungere qualcosa al _ready usa after_setup.

signal state_changed(old_state: States, new_state: States)

var current_state: State

func _ready() -> void:
	for state_name: States in STATES:
		var state_node: State = STATES[state_name]
		state_node.OWNER = OWNER
		state_node.SM = self
		state_node.sm_name = state_name
		state_node.readable_name = STATE_NAMES[state_name]
	
	for action_name: Actions in ACTIONS:
		var action_node: Node = ACTIONS[action_name]
		action_node.OWNER = OWNER
		action_node.SM = self
		
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

func is_current(sm_state: States) -> bool:
	return sm_state == current_state.sm_name


#endregion
