extends Node3D
class_name CurrentWeapon

@onready var ANIM_PLAYER = $AnimationPlayer
@export var DAMAGE = 5
@export var CHARACTER: Character

@onready var SM: SM_Weapon = $StateMachine

#
#
#var state = 'idle'
#var did_defend = false;
#
#
	#
#func attack():
	#state = 'attack'
	#
#
#func to_idle():
	#if state == 'defend':
		#if not did_defend:
			#print('non hai effettuato il parry contro un attacco, verrà disattivato per ', PARRY_COOLDOWN_SEC, ' secondi')
			#$Audio/FailedParry.play()
			#PARRY_COOLDOWN_TIMER.start()
		#else:
			#print('hai fatto un buon parry!')
			#$Audio/GoodParry.play()
		#ANIM_PLAYER.play_backwards('defend')
	#state = 'idle'
	#did_defend = false
#
	#
	
