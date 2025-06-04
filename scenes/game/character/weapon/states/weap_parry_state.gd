extends State

## This value will be set by the state machine
var CHARACTER: Character
var OWNER: CurrentWeapon
var SM: SM_Weapon
var sm_name: SM_Weapon.States
var readable_name: String

## How many secs the parry should last
@export var PARRY_SEC: float = 0.4
## How many secs should the player wait if he fails a parry
@export var PARRY_COOLDOWN_SEC: float = 1.0

const blocked_by: Array[SM_Character.States] = [
	SM_Character.S_CROUCH,
	SM_Character.S_SPRINT,
	SM_Character.S_DASH,
	SM_Character.S_IN_AIR,
]

var PARRY_TIMER: Timer
var PARRY_COOLDOWN_TIMER: Timer

func on_parry_enabled():
	print('parry riabilitato')
	$"../../Audio/CanDefend".play()

func _ready():
	super()
	PARRY_TIMER = Utils.timer_from_time(PARRY_SEC, true, self, to_idle)
	PARRY_COOLDOWN_TIMER = Utils.timer_from_time(PARRY_COOLDOWN_SEC, true, self, on_parry_enabled)

func can():
	return OWNER.CHARACTER.SM.current_state.sm_name not in blocked_by and PARRY_COOLDOWN_TIMER.is_stopped()

func to_idle():
	OWNER.ANIM_PLAYER.play_backwards('defend')
	SM.switch(SM.S_IDLE)

func enter_state():
	OWNER.parry()
	OWNER.ANIM_PLAYER.play('defend')
	$"../../Audio/Defend".play()
	PARRY_TIMER.start()
