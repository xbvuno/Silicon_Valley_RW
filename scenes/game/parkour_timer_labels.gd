extends GridContainer
class_name ParkourTimerLabels

@onready var BEST_TIME_L: Label = $VarBestTime
@onready var CURRENT_TIME_L: Label = $VarCurrentTime

func _ready():
	ParkourTimer.LABELS = self

func set_best(time: float):
	BEST_TIME_L.text = format_time(time)
	
func set_current(time: float):
	CURRENT_TIME_L.text = format_time(time)

func format_time(time: float) -> String:
	var t = int(time)
	var ms = int((time - t) * 1000)
	return "%02d:%02d.%03d" % [t / 60, t % 60, ms]
