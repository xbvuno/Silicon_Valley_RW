extends State
class_name CharacterAirJumpState

## Air Jump enabled.
@export var ENABLED: bool = true
## Cumulative Jump Boost Multiplier.
@export var JUMP_BOOST: float = 1.4
## Time to wait from a jump to another
@export var COOLDOWN_SEC: float = 1.0
## Max number of dashes in air you can do before touching ground
@export var MAX_AIR_JUMPS: int =  1

var COOLDOWN_TIMER: Timer
var air_jumping: bool = false
var air_jumps: int = 0

func _ready() -> void:
	super()
	COOLDOWN_TIMER = Utils.timer_from_time(COOLDOWN_SEC, true, self)
	state_name = States.States.AIR_JUMP

func can_air_jump() -> bool:
	if not ENABLED:
		return false

	elif air_jumps >= MAX_AIR_JUMPS:
		return false
		
	return COOLDOWN_TIMER.is_stopped()

func get_multiply():
	air_jumps += 1
	COOLDOWN_TIMER.start()
	return JUMP_BOOST * air_jumps

func start_timer():
	COOLDOWN_TIMER.start()
	
func reset():
	air_jumps = 0

func _physics_process(delta: float) -> void:
	character_node.state_machine.switch_movement_state(States.States.JUMPING)

func enter_state():
	character_node.velocity.y *= get_multiply()
	
func exit_state():
	pass
