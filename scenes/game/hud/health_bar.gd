extends Control

@export_group("Nodes")
@export var PROGRESS_BAR: ProgressBar
@export var HUD : Control

@onready var character_health :HealthComponent = HUD.CHARACTER.find_child("Health")

func _ready():
	character_health.healed.connect(update_progress_bar.unbind(1))
	character_health.damage_taken.connect(update_progress_bar.unbind(1))
	update_progress_bar()

func update_progress_bar():
	PROGRESS_BAR.value = character_health.health/character_health.max_health *PROGRESS_BAR.max_value
