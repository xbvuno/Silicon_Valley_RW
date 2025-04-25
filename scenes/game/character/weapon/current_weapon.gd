extends Node3D

@onready var ANIM_PLAYER = $AnimationPlayer

## How many secs the parry should last
@export var PARRY_SEC: float = 0.4
## How many secs should the player wait if he fails a parry
@export var PARRY_COOLDOWN_SEC: float = 1.0

@export var DAMAGE = 5

var PARRY_TIMER: Timer
var PARRY_COOLDOWN_TIMER: Timer

var state: String = 'idle'
var did_defend: bool = false;
var attack_started_or_ended: bool = false

func on_parry_enabled():
	print('parry riabilitato')
	$Audio/CanDefend.play()

func _ready():
	
	PARRY_TIMER = Utils.timer_from_time(PARRY_SEC, true, self, to_idle)
	PARRY_COOLDOWN_TIMER = Utils.timer_from_time(PARRY_COOLDOWN_SEC, true, self, on_parry_enabled)
	pass

func handle_input():
	if state == 'idle':
		if Input.is_action_just_pressed("a_attack"):
			attack()
		elif Input.is_action_just_pressed("a_defend") and PARRY_COOLDOWN_TIMER.is_stopped():
			defend()
	
func attack():
	state = 'attack'
	ANIM_PLAYER.play("attack")
	$Audio/Attack.play()

func defend():
	state = 'defend'
	ANIM_PLAYER.play('defend')
	$Audio/Defend.play()
	PARRY_TIMER.start()

func to_idle():
	if state == 'defend':
		if not did_defend:
			print('non hai effettuato il parry contro un attacco, verrà disattivato per ', PARRY_COOLDOWN_SEC, ' secondi')
			$Audio/FailedParry.play()
			PARRY_COOLDOWN_TIMER.start()
		else:
			print('hai fatto un buon parry!')
			$Audio/GoodParry.play()
		ANIM_PLAYER.play_backwards('defend')
	state = 'idle'
	did_defend = false


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Enemy:
		$Audio/enemyWasHit.play()
	else:
		$Audio/collidedWithElse.play()
