extends Control

## Enlarge reticle based on player speed
@export var CHARACTER: CharacterBody3D

const SCALE_TARGETS = {
	'normal': 32.,
	'sprinting': 64.,
	'crouching': 32.
}

const IN_AIR_SCALE_MULTIPLY = 1.5
const DASH_SCALE_MULTIPLY = 3

var current_scale_target = SCALE_TARGETS['normal']

const LERP_SPEED = 10.

const ALPHA_COLOR_TARGETS = {
	'normal': 1.,
	'sprinting': 1.,
	'crouching': 0.2
}

var current_alpha_target: float = ALPHA_COLOR_TARGETS['normal'];

var anchor_offset: float;

@onready var target_fov: float = CHARACTER.CAMERA.fov;

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
	if CHARACTER.is_in_air():
		scale_multiplier *= IN_AIR_SCALE_MULTIPLY * (1 + CHARACTER.AIR_JUMP.air_jumps * 0.4)
	if CHARACTER.DASH.is_dashing():
		scale_multiplier *= DASH_SCALE_MULTIPLY
	
	var lerp_step: float = (round(delta * 100) / 100) * LERP_SPEED
	
	anchor_offset = lerp(anchor_offset, clamp(current_scale_target * scale_multiplier * 0.8, 1, 128.), lerp_step)
	
	target_fov = lerp(target_fov, anchor_offset * 0.95, lerp_step)
	
	CHARACTER.CAMERA.fov = max(CHARACTER.CAMERA.fov,target_fov)
	
	offset_left = -anchor_offset
	offset_top = -anchor_offset
	offset_right = anchor_offset
	offset_bottom = anchor_offset
	
	modulate.a = lerp(modulate.a, current_alpha_target,lerp_step)
	
	
