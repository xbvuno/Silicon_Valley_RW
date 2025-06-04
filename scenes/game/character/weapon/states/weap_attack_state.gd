extends State

## This value will be set by the state machine
var CHARACTER: Character
var OWNER: CurrentWeapon
var SM: SM_Weapon
var sm_name: SM_Weapon.States
var readable_name: String

const blocked_by: Array[SM_Character.States] = [
	SM_Character.S_DASH,
]

func can():
	return CHARACTER.SM.current_state.sm_name not in blocked_by

func to_idle():
	SM.switch(SM.S_IDLE)

func enter_state():
	OWNER.attack()
	OWNER.ANIM_PLAYER.play("attack")
	$"../../Audio/Attack".play()
