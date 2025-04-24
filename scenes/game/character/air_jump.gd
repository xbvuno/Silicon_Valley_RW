extends Node

## Air Jump enabled.
@export var ENABLED: bool = true
## Cumulative Jump Boost Multiplier.
@export var JUMP_BOOST: float = 1.4
## Time to wait from a jump to another
@export var COOLDOWN_SEC: float = 1.0
## Max number of dashes in air you can do before touching ground
@export var MAX_AIR_JUMPS: int =  1

# solo per controllare se is_on_floor
@onready var CHARACTER: CharacterBody3D = $'../' 

var COOLDOWN_TIMER: Timer

var air_jumping: bool = false
var air_jumps: int = 0

func _ready() -> void:
	COOLDOWN_TIMER = Utils.timer_from_time(COOLDOWN_SEC, true, self)

func can_air_jump() -> bool:
	if !ENABLED:
		return false

	elif air_jumps >= MAX_AIR_JUMPS:
		return false
		
	return COOLDOWN_TIMER.is_stopped()

func get_multiply() -> int:
	air_jumps += 1
	COOLDOWN_TIMER.start()
	return int(JUMP_BOOST) * air_jumps

func start_timer() -> void:
	COOLDOWN_TIMER.start()
	

func reset() -> void:
	air_jumps = 0
