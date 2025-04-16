extends Control

## Enlarge reticle based on player speed
@export var CHARACTER: CharacterMovementController

const SCALE_TARGETS = {
	'normal': 32.,
	'sprinting': 64.,
	'crouching': 32.
}

const IN_AIR_SCALE_MULTIPLY = 1.5

var current_scale_target = SCALE_TARGETS['normal']

const LERP_SPEED = 10.

const ALPHA_COLOR_TARGETS = {
	'normal': 1.,
	'sprinting': 1.,
	'crouching': 0.2
}

var current_alpha_target: float = ALPHA_COLOR_TARGETS['normal'];

var anchor_offset: float;

func _ready():
	if CHARACTER == null:
		return
	
	CHARACTER.state_changed.connect(on_state_change)
	
func on_state_change(_old_state, new_state):
	current_scale_target = SCALE_TARGETS[new_state]
	current_alpha_target = ALPHA_COLOR_TARGETS[new_state]
		

func _process(delta: float) -> void:
	if CHARACTER == null:
		return 
	
	var scale_multiplier = 1
	if not(CHARACTER.is_on_floor()):
		scale_multiplier = IN_AIR_SCALE_MULTIPLY
	
	var lerp_step = (round(delta * 100) / 100) * LERP_SPEED
	anchor_offset = lerp(anchor_offset, current_scale_target * scale_multiplier, lerp_step)
	offset_left = -anchor_offset
	offset_top = -anchor_offset
	offset_right = anchor_offset
	offset_bottom = anchor_offset
	modulate.a = lerp(modulate.a, current_alpha_target,lerp_step)
	
	
