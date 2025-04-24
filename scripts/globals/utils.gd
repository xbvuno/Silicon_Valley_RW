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
		one_shot: bool,
		add_child_to: Variant = null,
		on_timeout: Callable = Callable()
	) -> Timer:
	
	var timer: Timer = Timer.new()
	timer.wait_time = time_sec
	timer.one_shot = one_shot
	if !on_timeout.is_null():
		timer.timeout.connect(on_timeout)
	
	if add_child_to != null:
		add_child_to.add_child(timer)
	return timer
