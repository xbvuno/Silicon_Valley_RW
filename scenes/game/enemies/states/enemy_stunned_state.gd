extends State

## This value will be set by the state machine
var OWNER: Enemy
var SM: SM_Enemy
var CHARACTER: Character
var C_SM: SM_Character
var sm_name: SM_Enemy.States
var readable_name: String

var STUNNED_TIMER : Timer

func _ready() -> void:
	super()
	STUNNED_TIMER = Utils.timer_from_time(2, true, self, to_idle)
	#OWNER.ready.connect(timer_setup)

func _physics_process(_delta: float) -> void:
	pass

func enter_state():
	OWNER.velocity = Vector3.ZERO
	OWNER.MESH.mesh.material.albedo_color = Color(0, 0, 256, 0)
	STUNNED_TIMER.start()
	OWNER.PARRY_PARTICLES.emitting = true
	OWNER.WEAPON.ATTACK_ANIMATION.play("RESET")
	
func exit_state():
	OWNER.WEAPON.parried = false

func to_idle():
	SM.switch(SM.States.ROAMING)

	
