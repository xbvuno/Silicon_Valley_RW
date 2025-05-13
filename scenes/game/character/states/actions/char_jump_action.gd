extends Node

var OWNER: Character
var SM: SM_Character

## Air Jump enabled.
@export var AIR_JUMP_ENABLED: bool = true
## Jump Boost Multiplier.
@export var AIR_JUMP_BOOST: float = 1.4
## Time to wait from a jump to another
@export var AIR_JUMP_COOLDOWN_SEC: float = .1
## Max number of dashes in air you can do before touching ground
@export var MAX_AIR_JUMPS: int =  1
## Max in air frames to consider as still on floor
@export var MAX_FRAMES_STILL_ON_FLOOR: int = 16

var AIR_JUMP_COOLDOWN_TIMER: Timer
var air_jumps: int = 0

func _ready():
	AIR_JUMP_COOLDOWN_TIMER = Utils.timer_from_time(AIR_JUMP_COOLDOWN_SEC, true, self)
	

func can_jump(in_air: bool = false) -> bool:
	if in_air and OWNER.last_frame_on_floor >= MAX_FRAMES_STILL_ON_FLOOR:
		if not AIR_JUMP_ENABLED:
			return false
		if air_jumps >= MAX_AIR_JUMPS:
			return false
		if not AIR_JUMP_COOLDOWN_TIMER.is_stopped():
			return false
	if OWNER.under_low_ceiling():
		return false
	
	return true

func do_jump(in_air: bool = false):
	var multiply: float = 1
	if in_air and OWNER.last_frame_on_floor >= MAX_FRAMES_STILL_ON_FLOOR:
		multiply = AIR_JUMP_BOOST
		air_jumps += 1
		AIR_JUMP_COOLDOWN_TIMER.start()
	else:
		SM.switch(SM.S_IN_AIR)
	OWNER.velocity.y = OWNER.JUMP_VELOCITY * multiply
	OWNER.JUMP_ANIMATION.play("jump", 0.25)
	print(OWNER.last_frame_on_floor)

func reset():
	air_jumps = 0
	
