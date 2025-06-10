extends Node
class_name AttackComponent

@export_group("Parameters")
@export var DAMAGE : float = 10.0

@onready var OWNER : Node3D  = get_parent()

