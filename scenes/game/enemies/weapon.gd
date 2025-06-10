extends Node3D
class_name Weapon
@export_group("Nodes")
@export var OWNER : Enemy
@export var ATTACK_ANIMATION : AnimationPlayer
@export var MESH : MeshInstance3D
@export var area : Area3D
@export var attack_component : AttackComponent
@export var DEBUG_SPHERE : CSGSphere3D

@export var can_damage : bool = false
@export var can_be_parried : bool = false

@export var parried : bool = false

func _process(delta: float) -> void:
	pass


func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and can_damage and not parried:
		var healt_component :HealthComponent= body.find_child("Health")
		healt_component.take_damage(attack_component)
		print(healt_component.health)
		

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		pass

func got_parried():
	parried = true
	OWNER.SM.switch(OWNER.SM.States.STUNNED)
	print("parry")
