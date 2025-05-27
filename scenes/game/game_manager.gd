extends Control
class_name GameManager
@export var GAME_FATHER : Node
@export var HUD : Control
@export var PLAYER : Character

@onready var actual_scene : Node = null
@onready var actual_scene_id:String =''
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.GAME_MANAGER = self
	HUD.change_scene.connect(change_scene)
	change_scene("main_menu_background")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func change_scene(scene_id):
	if actual_scene_id == scene_id:
		return
	if actual_scene != null:
		actual_scene.queue_free()
	var scene_path:String = Global.scenes[scene_id]
	var scene = load(scene_path).instantiate()
	GAME_FATHER.add_child(scene)
	actual_scene = scene
	actual_scene_id = scene_id
	var spawn_point = scene.find_child("PlayerSpawnPoint")
	if spawn_point != null:
		PLAYER.global_position = spawn_point.global_position
		#PLAYER.rotation = spawn_point.rotation
	
