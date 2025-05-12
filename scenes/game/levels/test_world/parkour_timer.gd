extends Node

var stopped: bool = true
var time_elapsed: float = 0.0
var best_time: float = 0.0
var resetted: bool = true

@onready var CHARACTER: Character = %Character

var LABELS: ParkourTimerLabels

func _input(_input):
	if not resetted or not stopped:
		return
	if ["m_left", "m_right", "m_forward", "m_backward"].any(Input.is_action_just_pressed):
		stopped = false
		time_elapsed = 0
				
func _process(delta: float) -> void:
	if not stopped:
		time_elapsed += delta
		LABELS.set_current(time_elapsed)
		
func reached():
	stopped = true
	resetted = false
	if time_elapsed < best_time or best_time == 0:
		best_time = time_elapsed
		LABELS.set_best(best_time)

func reset():
	resetted = true
	stopped = true
	time_elapsed = 0
	LABELS.set_current(0)
