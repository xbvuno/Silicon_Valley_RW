extends Node
class_name HealthComponent
@export_group("Parameters")
@export var max_health : float = 100


const BASE_HEALTH : float = 99999999.0


@onready var health : float = max_health
signal damage_taken(should_died:bool)
signal healed()
#signal should_die()

func take_damage(attack :AttackComponent):
	if attack.DAMAGE >= health:
		damage_taken.emit(true)
		health = 0
		return
	health-=attack.DAMAGE
	damage_taken.emit(false)

func heal(value):
	health+=value
	if health >= max_health:
		health= max_health
	healed.emit()
