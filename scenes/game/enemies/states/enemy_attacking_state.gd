extends State

## This value will be set by the state machine
var OWNER: Enemy
var SM: SM_Enemy
var CHARACTER: Character
var C_SM: SM_Character
var sm_name: SM_Enemy.States
var readable_name: String



func _physics_process(_delta: float) -> void:
	pass

func enter_state():
	OWNER.WEAPON_ANIMATION.play("enemy_attack")
	
func exit_state():
	pass




func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name != "RESET":
		SM.switch(SM.States.FOLLOWING) 