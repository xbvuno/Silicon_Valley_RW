extends Node3D

@onready var ANIM_PLAYER = $AnimationPlayer
@onready var PARRY_TIMER = $ParryTimer

@export var DAMAGE = 5

var state = 'idle'
var can_parry = false

func _ready():
	PARRY_TIMER.timeout.connect((func(): can_parry = false).call)
	pass

func handle_input():
	if state == 'idle':
		if Input.is_action_just_pressed("a_attack"):
			attack()
		elif Input.is_action_just_pressed("a_defend"):
			defend()
	elif state == 'defend':
		if not Input.is_action_pressed("a_defend"):
			to_idle()
	
func attack():
	state = 'attack'
	ANIM_PLAYER.play("attack")

func defend():
	state = 'defend'
	ANIM_PLAYER.play('defend')
	PARRY_TIMER.start()
	can_parry = true

func to_idle():
	if state == 'defend':
		ANIM_PLAYER.play_backwards('defend')
	state = 'idle'
	
	
