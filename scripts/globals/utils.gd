extends Node

## This file contains utility functions for the game.

## Non so veramente come si descrivano i parametri :C
## fixate nel caso

## Utility function to create a timer with a specified wait time and optional callback.
##  `time_sec`: The wait time in seconds.
##  `one_shot`: If true, the timer will only run once.
##  `add_child_to`: The node to which the timer will be added as a child (default = null).
##  `on_timeout`: The function to call when the timer times out (leave empty if none required)
func timer_from_time(
		time_sec: float,
		one_shot, 
		add_child_to: Variant = null, 
		on_timeout: Callable = Callable()
	) -> Timer:
		
	var timer = Timer.new()
	timer.wait_time = time_sec
	timer.one_shot = one_shot
	if not (on_timeout.is_null()):
		timer.timeout.connect(on_timeout)
	
	if add_child_to != null:
		add_child_to.add_child(timer)
	return timer

func get_body_in_front_of_camera(camera: Camera3D,space_state:PhysicsDirectSpaceState3D, max_distance := 1000.0, collision_mask:int=4294967295) -> CollisionObject3D:
	var from := camera.global_transform.origin
	var to := from + (-camera.global_transform.basis.z) * max_distance

	# var space_state := get_world_3d().direct_space_state
	var query := PhysicsRayQueryParameters3D.create(from, to)

	var result :Dictionary = space_state.intersect_ray(query)
	if result.has("collider"):
		return result["collider"] as CollisionObject3D

	return null
