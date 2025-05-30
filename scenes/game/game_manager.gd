extends Control
class_name GameManager
@export var GAME_FATHER : Node
@export var HUD : Control
@export var PLAYER : Character

@onready var actual_scene : Node 
@onready var actual_scene_id : String = ""
@onready var actual_spawn_point : Vector3 = Vector3(0,0,0)
func _enter_tree() -> void:
	Global.GAME_MANAGER = self
	Global.PLAYER = PLAYER

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	HUD.change_scene.connect(change_scene)
	#change_scene("main_menu_background")
	



func change_scene(scene_id):
	
	if actual_scene_id == scene_id:
		return
	else:
		actual_scene_id = scene_id
		
	if actual_scene != null:
		actual_scene.queue_free()
	
	var scene_path:String = Global.scenes[scene_id]
	var scene = load(scene_path)
	actual_scene = scene.instantiate()
	GAME_FATHER.add_child(actual_scene)
	#actual_scene_id = scene_id
	
	
	
	var spawn_point = actual_scene.find_child("PlayerSpawnPoint")
	if spawn_point != null:
		actual_spawn_point = spawn_point.global_position
		PLAYER.global_position = actual_spawn_point
		#PLAYER.rotation = spawn_point.rotation
