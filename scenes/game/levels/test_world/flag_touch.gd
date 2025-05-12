extends Area3D

func _ready():
	body_entered.connect(on_touch)

func on_touch(_a):
	if not ParkourTimer.stopped:
		$AudioStreamPlayer3D.play()
		ParkourTimer.reached()
