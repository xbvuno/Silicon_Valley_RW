extends State
class_name CharacterDashState

## Dash enabled.
@export var ENABLED: bool = true
## Speed of the dash.
@export var SPEED: float = 30
## Duration of the dash in seconds: How fast the dash will be.
@export var DURATION_SEC: float = 0.3
## Cooldown of the dash in seconds: How long until the dash can be used again.
@export var COOLDOWN_SEC: float = 1.0
## Double tap time in seconds: The arc of time in which the dash can be activated by double tapping.
@export var DOUBLE_TAP_SEC: float = 0.2
## Max number of dashes in air you can do before touching ground
@export var MAX_AIR_DASHES: int =  1

var DURATION_TIMER: Timer
var COOLDOWN_TIMER: Timer

var dashing: bool = false
var air_dashes: int = 0

func _ready() -> void:
	super()
	state_name = States.States.DASHING
	DURATION_TIMER = Utils.timer_from_time(DURATION_SEC, true, self, end_dash)
	COOLDOWN_TIMER = Utils.timer_from_time(COOLDOWN_SEC, true, self)

func can_dash() -> bool:
	if not ENABLED:
		return false
		
	if character_node.is_on_floor():
		air_dashes = 0
	elif air_dashes >= MAX_AIR_DASHES:
		return false
		
	return not dashing and COOLDOWN_TIMER.is_stopped()

func end_dash():
	character_node.last_action_tap = ''
	dashing = false
	COOLDOWN_TIMER.start()

func direction_from_facing(facing_direction: Vector3) -> Dictionary:
	var right = facing_direction.cross(Vector3.UP).normalized()
	return {
		character_node.MOVIMENT_CONTROLS.LEFT: - right,
		character_node.MOVIMENT_CONTROLS.RIGHT: right,
		character_node.MOVIMENT_CONTROLS.FORWARD: facing_direction,
		character_node.MOVIMENT_CONTROLS.BACKWARD: - facing_direction
	}

func do_dash(facing_direction: Vector3) -> void:
	var direction = direction_from_facing(facing_direction)[character_node.last_action_tap]
	direction.y = 0
	var tw: Tween = character_node.get_tree().create_tween()
	tw.tween_property(character_node, "velocity", direction * SPEED, DURATION_SEC)
	DURATION_TIMER.start()
	dashing = true
	if character_node.is_in_air():
		air_dashes += 1
	

func is_dashing() -> bool:
	return dashing

func _physics_process(delta: float) -> void:
	if DURATION_TIMER.is_stopped():
		character_node.state_machine.switch_movement_state(States.States.IDLE)

func enter_state():
	var facing_direction: Vector3 = character_node.get_facing_direction()
	do_dash(facing_direction)
	
func exit_state():
	character_node.last_action_tap = ''
	COOLDOWN_TIMER.start()
