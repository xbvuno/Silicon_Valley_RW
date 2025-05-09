extends Control
#
### Enlarge reticle based on player speed
@export var CHARACTER: CharacterBody3D
#
## TODO: Da spostare
var DEFAULT_FOV: float = 75.0
var current_fov: float

const SCALE_TARGETS = {
	SM_Character.States.IDLE: 32.,
	SM_Character.States.WALK: 48.,
	SM_Character.States.SPRINT: 64.,
	SM_Character.States.CROUCH: 32.,
	SM_Character.States.IN_AIR: 64.,
}

const TARGET_FOVS = {
	SM_Character.States.IDLE: 75.0,
	SM_Character.States.WALK: 80.0,
	SM_Character.States.SPRINT: 85.0,
	SM_Character.States.DASH: 100.0,
	SM_Character.States.IN_AIR: 85.,
}

const IN_AIR_SCALE_MULTIPLY = 1.5
const DASH_SCALE_MULTIPLY = 3

var current_scale_target = SCALE_TARGETS[SM_Character.States.IDLE]

const LERP_SPEED = 10.

const ALPHA_COLOR_TARGETS = {
	SM_Character.States.IDLE: 1.,
	SM_Character.States.WALK: 1.,
	SM_Character.States.SPRINT: 1.,
	SM_Character.States.CROUCH: 0.2,
}

var current_alpha_target: float = ALPHA_COLOR_TARGETS[SM_Character.States.IDLE];

var anchor_offset: float;

@onready var target_fov: float = CHARACTER.CAMERA.fov;

func _ready():
	current_fov = DEFAULT_FOV
	if CHARACTER == null:
		return
	
	CHARACTER.SM.state_changed.connect(on_state_change)
	
func on_state_change(_old_state, new_state):
	if new_state in SCALE_TARGETS:
		current_scale_target = SCALE_TARGETS[new_state]
	else:
		current_scale_target = SCALE_TARGETS[SM_Character.States.IDLE]
	
	if new_state in ALPHA_COLOR_TARGETS:
		current_alpha_target = ALPHA_COLOR_TARGETS[new_state]
	else:
		current_alpha_target = ALPHA_COLOR_TARGETS[SM_Character.States.IDLE]
	
	if new_state in TARGET_FOVS:
		current_fov = TARGET_FOVS[new_state]
	else:
		current_fov = TARGET_FOVS[SM_Character.States.IDLE]

		

func _process(delta: float) -> void:
	if CHARACTER == null:
		return 
	
	var scale_multiplier = 1
	if CHARACTER.is_in_air():
		pass
		# TODO: Trovare un modo per scommentare questa parte. Dipendente da air_jumps 
		# scale_multiplier *= IN_AIR_SCALE_MULTIPLY * (1 + CHARACTER.AIR_JUMP.air_jumps * 0.4)
	#if CHARACTER.DASH.is_dashing():
		#scale_multiplier *= DASH_SCALE_MULTIPLY
	
	var lerp_step: float = (round(delta * 100) / 100) * LERP_SPEED
	
	anchor_offset = lerp(anchor_offset, clamp(current_scale_target * scale_multiplier * 0.8, 1, 128.), lerp_step)
	
	target_fov = lerp(target_fov, anchor_offset * 0.95, lerp_step)
	
	CHARACTER.CAMERA.fov = lerp(CHARACTER.CAMERA.fov, current_fov * 0.95, lerp_step)
	
	offset_left = -anchor_offset
	offset_top = -anchor_offset
	offset_right = anchor_offset
	offset_bottom = anchor_offset
	
	modulate.a = lerp(modulate.a, current_alpha_target,lerp_step)
	
	
