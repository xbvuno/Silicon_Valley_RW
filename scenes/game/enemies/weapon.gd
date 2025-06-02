extends Node3D
@export_group("Nodes")
@export var area : Area3D
@export var attack_component : AttackComponent

@export var can_damage : bool = false

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and can_damage:
		var healt_component :HealthComponent= body.find_child("Health")
		healt_component.take_damage(attack_component)
		print(healt_component.health)

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		pass
