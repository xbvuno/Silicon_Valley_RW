extends State

## This value will be set by the state machine
var OWNER: Enemy
var SM: SM_Enemy
var CHARACTER: Character
var C_SM: SM_Character
var sm_name: SM_Enemy.States
var readable_name: String

var is_char_in_area_big: bool  = false
var is_char_in_area_small: bool = false

func _ready() -> void:
	super()

	

func _physics_process(_delta: float) -> void:
	check_trigger_areas()


func enter_state():
	pass
	
func exit_state():
	pass

	
	
func check_trigger_areas():
	if is_char_in_area_big and OWNER.is_player_hearble():
		if is_char_in_area_small:
			on_char_in_small_area()
		on_char_in_big_area()

func on_body_enter_area_small(body: Node3D):
	if body.is_in_group("player"):
		is_char_in_area_small = true

func on_body_exit_area_small(body: Node3D):
	if body.is_in_group("player"):
		is_char_in_area_small = false

func on_body_enter_area_big(body: Node3D):
	if body.is_in_group("player"):
		is_char_in_area_big = true

func on_body_exit_area_big(body: Node3D):
	if body.is_in_group("player"):
		is_char_in_area_big = false

func on_char_in_small_area():
	if C_SM.is_current_in_group(C_SM.SG_SOUND_WEAK) or C_SM.did_action_lately_in_group(C_SM.AG_SOUND_WEAK):
		SM.switch(SM.States.FOLLOWING)

func on_char_in_big_area():
	if C_SM.is_current_in_group(C_SM.SG_SOUND_LOUD) or C_SM.did_action_lately_in_group(C_SM.AG_SOUND_LOUD):
		SM.switch(SM.States.FOLLOWING)
