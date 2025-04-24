extends Node

## Dash enabled.
@export var ENABLED: bool = true
## Speed of the dash.
@export var SPEED: float = 20
## Duration of the dash in seconds: How fast the dash will be.
@export var DURATION_SEC: float = 0.3
## Cooldown of the dash in seconds: How long until the dash can be used again.
@export var COOLDOWN_SEC: float = 1.0
## Double tap time in seconds: The arc of time in which the dash can be activated by double tapping.
@export var DOUBLE_TAP_SEC: float = 0.2
## Max number of dashes in air you can do before touching ground
@export var MAX_AIR_DASHES: int =  1

## Solo per controllare is_on_floor
@onready var CHARACTER: CharacterBody3D = $'../' 

var DURATION_TIMER: Timer
var DOUBLE_TAP_TIMER: Timer
var COOLDOWN_TIMER: Timer

var dashing: bool = false
var last_action_tap: String = ''
var air_dashes: int = 0

func _ready() -> void:
	DURATION_TIMER = Utils.timer_from_time(DURATION_SEC, true, self, end_dash)
	DOUBLE_TAP_TIMER = Utils.timer_from_time(DOUBLE_TAP_SEC, true, self)
	COOLDOWN_TIMER = Utils.timer_from_time(COOLDOWN_SEC, true, self)

func can_dash() -> bool:
	if not ENABLED:
		return false
		
	if CHARACTER.is_on_floor():
		air_dashes = 0
	elif air_dashes >= MAX_AIR_DASHES:
		return false
		
	return not dashing and COOLDOWN_TIMER.is_stopped()

func end_dash():
	last_action_tap = ''
	dashing = false
	COOLDOWN_TIMER.start()

func did_double_tap() -> bool:
	for k_action in CHARACTER.MOVIMENT_CONTROLS: # tutti le possibili action di movimento
		var action = CHARACTER.MOVIMENT_CONTROLS[k_action]
		if Input.is_action_just_pressed(action):
			if DOUBLE_TAP_TIMER.is_stopped() or last_action_tap != action: # Se il tempo per attivare il double tap è finito oppure se
				last_action_tap = action
				DOUBLE_TAP_TIMER.start()
			else:
				return true
	return false


func direction_from_facing(facing_direction: Vector3) -> Dictionary:
	var right = facing_direction.cross(Vector3.UP).normalized()
	return {
		CHARACTER.MOVIMENT_CONTROLS.LEFT: - right,
		CHARACTER.MOVIMENT_CONTROLS.RIGHT: right,
		CHARACTER.MOVIMENT_CONTROLS.FORWARD: facing_direction,
		CHARACTER.MOVIMENT_CONTROLS.BACKWARD: - facing_direction
	}

func do_dash(facing_direction: Vector3) -> void:
	var direction = direction_from_facing(facing_direction)[last_action_tap]
	direction.y = 0
	var tw: Tween = CHARACTER.get_tree().create_tween()
	tw.tween_property(CHARACTER, "velocity", direction * SPEED, DURATION_SEC)
	DURATION_TIMER.start()
	dashing = true
	if CHARACTER.is_in_air():
		air_dashes += 1
	

func is_dashing() -> bool:
	return dashing
