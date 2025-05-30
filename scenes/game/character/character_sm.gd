## State Machine del Character

extends Node
class_name SM_Character

## [bvuno] Per pragmaticità questo nodo dovrebbe estendere la classe StateMachine, per aggiungere poi enumerazioni, stati ecc.
## Purtroppo non è possibile estendere gli enum, o settare static typing per essi o per l'owner, e ciò nasconde gli hint nell'editor relativi.
## Prendi questa come verità assoluta, non dubitare di nulla, dio è morto in vano

#region States

enum States {
	IDLE, CROUCH, WALK, SPRINT, DASH, IN_AIR
}

## LEGGIBILITÀ: Alias per gli States, in modo da non dover chiamare ogni volta States.Papera
const S_IDLE: States = States.IDLE
const S_CROUCH: States = States.CROUCH
const S_WALK: States = States.WALK
const S_SPRINT: States = States.SPRINT
const S_DASH: States = States.DASH
const S_IN_AIR: States = States.IN_AIR

const STATE_NAMES: Dictionary[States, String] = {
	States.IDLE: "Idle",
	States.CROUCH: "Crouching",
	States.WALK: "Walking",
	States.SPRINT: "Sprinting",
	States.DASH: "Dashing",
	States.IN_AIR: "In air"
}

@onready var STATES: Dictionary[States, State] = {
	States.IDLE: $"Idle",
	States.CROUCH: $"Crouching",
	States.WALK: $"Walking",
	States.SPRINT: $"Sprinting",
	States.DASH: $"Dashing",
	States.IN_AIR: $"InAir"
}

enum StatesGroups {
	SOUND_SILENT, SOUND_WEAK, SOUND_LOUD
}

const SG_SOUND_SILENT = StatesGroups.SOUND_SILENT
const SG_SOUND_WEAK = StatesGroups.SOUND_WEAK
const SG_SOUND_LOUD = StatesGroups.SOUND_LOUD

@onready var STATES_GROUPS: Dictionary[StatesGroups, Array] = {
	SG_SOUND_SILENT: [S_CROUCH, S_IDLE, S_IN_AIR],
	SG_SOUND_WEAK: [S_WALK],
	SG_SOUND_LOUD: [S_DASH, S_SPRINT]
}

#endregion

#region Actions

enum Actions {
	JUMP, LAND
}

const A_JUMP: Actions = Actions.JUMP
const A_LAND: Actions = Actions.LAND

@onready var ACTIONS: Dictionary = {
	Actions.JUMP: $"Actions/Jump",
	Actions.LAND: $"Actions/Land"
}

@onready var ACTION_NAMES: Dictionary[Actions, String] = {
	A_JUMP: 'Jump',
	A_LAND: 'Land'
}
enum ActionsGroups {
	SOUND_WEAK, SOUND_LOUD
}

const AG_SOUND_WEAK = ActionsGroups.SOUND_WEAK
const AG_SOUND_LOUD = ActionsGroups.SOUND_LOUD

@onready var ACTIONS_GROUPS: Dictionary[ActionsGroups, Array] = {
	AG_SOUND_WEAK: [A_LAND],
	AG_SOUND_LOUD: [A_JUMP]
}

#endregion

@onready var OWNER: Character = $".."

func after_setup() -> void:
	current_state = STATES[S_IDLE]
	current_state.state_started.emit()

const _PRINT_PREFIX = "CHAR_"

#region UnderTheHood

## [bvuno] Questa parte di codice dovrebbe essere la stessa per tutte le state machine. se devi aggiungere qualcosa al _ready usa after_setup.

signal state_changed(old_state: States, new_state: States)

var current_state: State

var latest_actions: Array[ExpiringAction] = []

func add_action_to_latest(action: Actions, expires_in: float = .5):
	var i = latest_actions.find_custom(func(exp_action): return exp_action._action == action)
	if i == -1:
		latest_actions.append(ExpiringAction.new(action, expires_in))
	else:
		latest_actions[i]._expires_in = expires_in
		

func _ready() -> void:
	for state_name: States in STATES:
		var state_node: State = STATES[state_name]
		state_node.OWNER = OWNER
		state_node.SM = self
		state_node.sm_name = state_name
		state_node.readable_name = STATE_NAMES[state_name]
	
	for action_name: Actions in ACTIONS:
		var action_node: Node = ACTIONS[action_name]
		action_node.sm_name = action_name
		action_node.OWNER = OWNER
		action_node.SM = self
		
	after_setup()

func _physics_process(delta: float) -> void:
	#print(latest_actions.map(func(exp_action): return ACTION_NAMES[ExpiringAction.action_enum(exp_action)]))
	for exp_action in latest_actions:
		exp_action.scroll(delta)
	latest_actions = latest_actions.filter(ExpiringAction.action_is_valid)

func did_action_lately(action: Actions):
	return action in latest_actions.map(ExpiringAction.action_enum)
	 
func did_action_lately_in_group(sm_action_group: ActionsGroups) -> bool:
	return ACTIONS_GROUPS[sm_action_group].any(did_action_lately)

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

func is_current_in_group(sm_state_group: StatesGroups) -> bool:
	return STATES_GROUPS[sm_state_group].any(is_current)

#endregion


class ExpiringAction:
	var _action: Actions
	var _expires_in: float
	
	func _init(action: Actions, expires_in: float):
		_action = action
		_expires_in = expires_in
	
	func scroll(of: float = 1):
		_expires_in -= of
		
	func is_expired() -> bool:
		return _expires_in <= 0
		
	static func action_is_expired(action: ExpiringAction) -> bool:
		return action.is_expired()
	
	static func action_is_valid(action: ExpiringAction) -> bool:
		return not action.is_expired()
		
	static func action_scroll(action: ExpiringAction, of: float = 1) -> ExpiringAction:
		action.scroll(of)
		return action
	
	static func action_enum(action: ExpiringAction) -> Actions:
		return action._action
