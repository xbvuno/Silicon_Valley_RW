extends Node

var stopped: bool = true
var time_elapsed: float = 0.0
var best_time: float = 0.0
var resetted: bool = true

var LABELS: ParkourTimerLabels
var CHARACTER : Character
var death_sound : AudioStreamPlayer
func _ready() -> void:
	death_sound = AudioStreamPlayer.new()
	death_sound.stream = AudioStreamOggVorbis.load_from_file("res://assets/audio/sfx/weapon/temp_audio/failed_parry.ogg")
	add_child(death_sound)
	
func _input(__input):
	if not resetted or not stopped:
		return
	if ["m_left", "m_right", "m_forward", "m_backward"].any(Input.is_action_pressed):
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
	#CHARACTER.AUDIO_MANAGER.create_3d_audio_at_location(CHARACTER,SoundEffect.SOUND_EFFECT_TYPE.CHARACTER_DEATH)
	death_sound.play()
	resetted = true
	stopped = true
	time_elapsed = 0
	LABELS.set_current(0)
