# Moviment Controller estratto da
# https://godotengine.org/asset-library/asset/2418

#  <(o )___     QUESTA PAPERELLA È QUI PER MANGIARE I BUG
#    ( ._> /    TOCCA LA PAPERELLA E LA PRENDO SUL PERSONALE >:|

extends CharacterBody3D

#region Character Export

## The settings for the character's movement and feel.
@export_category("Character")
## The speed that the character moves at without crouching or sprinting.
@export var BASE_SPEED: float = 3.0
## The speed that the character moves at when sprinting.
@export var SPRINT_SPEED: float = 6.0
## The speed that the character moves at when crouching.
@export var CROUCH_SPEED: float = 1.0
## How high the player jumps.
@export var JUMP_VELOCITY: float = 8.0
## How fast the character speeds up and slows down when Motion Smoothing is on.
@export var ACCELLERATION: float = 10.0

## How far the player turns when the mouse is moved.
@export var MOUSE_SENSIBILITY: float = 0.1
## Invert the X axis input for the camera.
@export var INVERT_CAMERA_X_AXIS: bool = false
## Invert the Y axis input for the camera.
@export var INVERT_CAMERA_Y_AXIS: bool = false
## Whether the player can use movement inputs. Does not stop outside forces or jumping. See Jumping Enabled.
@export var IMMOBILE: bool = false

#endregion

#region Nodes Export

@export_group("Nodes")
## A reference to the camera for use in the character script. This is the parent node to the camera and is rotated instead of the camera for mouse input.
@export var HEAD: Node3D
## A reference to the camera for use in the character script.
@export var CAMERA: Camera3D
## A reference to the headbob animation for use in the character script.
@export var HEADBOB_ANIMATION: AnimationPlayer
## A reference to the jump animation for use in the character script.
@export var JUMP_ANIMATION: AnimationPlayer
## A reference to the crouch animation for use in the character script.
@export var CROUCH_ANIMATION: AnimationPlayer
## A reference to the the player's collision shape for use in the character script.
@export var COLLISION_MESH: CollisionShape3D

#endregion

#region Controls Export

# We are using UI controls because they are built into Godot Engine so they can be used right away
@export_group("Controls")
## Use the Input Map to map a mouse/keyboard input to an action and add a reference to it to this dictionary to be used in the script.
@export var CONTROLS: Dictionary[Variant, String] = {
	LEFT = "m_left",
	RIGHT = "m_right",
	FORWARD = "m_forward",
	BACKWARD = "m_backward",
	JUMP = "m_jump",
	CROUCH = "m_crouch",
	SPRINT = "m_sprint",
	PAUSE = "ui_cancel"
}

#endregion

#region Feature Settings Export Group

@export_group("Feature Settings")
## Enable or disable jumping. Useful for restrictive storytelling environments.
@export var jumping_enabled: bool = true
## Enables or disables sprinting.
@export var sprint_enabled: bool = true
## Toggles the sprinting state when button is pressed or requires the player to hold the button down to remain sprinting.
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode: int = 0
## Enables or disables crouching.
@export var crouch_enabled: bool = true
## Toggles the crouch state when button is pressed or requires the player to hold the button down to remain crouched.
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode: int = 0
## Wether sprinting should effect FOV.
@export var dynamic_fov: bool = true
## Enables the view bobbing animation.
@export var view_bobbing: bool = true
## This determines wether the player can use the pause button, not wether the game will actually pause.
@export var PAUSING_ENABLED: bool = true
## If your game changes the gravity value during gameplay, check this property to allow the player to experience the change in gravity.

#endregion

#region Custom Settings Export Group

@export_group("Custom Settings")
@export var DOUBLE_JUMP_ENABLED: bool = false

@export var MAX_VELOCITY: float = 20

@export var DOUBLE_JUMP_BOOST: float = 1.4

#endregion

#region Custon Node Export Group

@export_group("Custom Nodes")

@export var WEAPON: Node3D = null
@export var DEFEND_ZONE: Area3D = null

#endregion

#region Member Variable Initialization

signal state_changed(old_state: String, new_state: String)

# These are variables used in this script that don't need to be exposed in the editor.
var speed: float = BASE_SPEED
var current_speed: float = 0.0
# States: normal, crouching, sprinting
var state: String = "normal"
var low_ceiling: bool = false # This is for when the ceiling is too low and the player needs to crouch.
var was_on_floor: bool = true # Was the player on the floor last frame (for landing animation)

# Get the gravity from the project settings to be synced with RigidBody nodes
var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process

# Stores mouse input for rotating the camera in the physics process
var mouseInput: Vector2 = Vector2(0,0)

#endregion

#region Main Control Flow

var MOVIMENT_CONTROLS: Dictionary[Variant, String] = {
	LEFT = CONTROLS.LEFT,
	RIGHT = CONTROLS.RIGHT,
	FORWARD = CONTROLS.FORWARD,
	BACKWARD = CONTROLS.BACKWARD,
}

@onready var DASH: Node = $Dash
@onready var AIR_JUMP: Node = $AirJump

func _ready() -> void:
	#It is safe to comment this line if your game doesn't start with the mouse captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	DEFEND_ZONE.area_entered.connect(on_frontal_attack)
	
	# If the controller is rotated in a certain direction for game design purposes, redirect this rotation into the head.
	HEAD.rotation.y = rotation.y
	rotation.y = 0
	
	set_floor_max_angle(PI / 6)
	initialize_animations()
	enter_normal_state()


func _process(_delta: float) -> void:
	if PAUSING_ENABLED:
		handle_pausing()

func on_frontal_attack(area: Area3D) -> void:
	if !area.is_in_group("weapons"): # se non è un arma esci
		return
	
	var weapon_attacking: Node3D = area.get_parent()
	if weapon_attacking == WEAPON: # se è la mia stessa arma a colpirmi esci
		return
	
	if WEAPON.state == 'defend':
		WEAPON.did_defend = true
		weapon_attacking.get_parent().get_parent().got_parried()
	else:
		print('hai preso tutto il danno')
		
		

func _physics_process(delta: float) -> void: # Most things happen here.

	if GRAVITY && !DASH.is_dashing():
		velocity.y -= GRAVITY * delta
	
	handle_jumping()
	
	var input_dir: Vector2 = Vector2.ZERO
	
	if !IMMOBILE:
		input_dir = Input.get_vector(CONTROLS.LEFT, CONTROLS.RIGHT, CONTROLS.FORWARD, CONTROLS.BACKWARD)
	
	handle_movement(delta, input_dir)
	
	if state != "crouching" and DASH.can_dash() and DASH.did_double_tap():
		DASH.do_dash(get_facing_direction())
	
	
	
	handle_head_rotation()
	
	# The player is not able to stand up if the ceiling is too low
	low_ceiling = $CrouchCeilingDetection.is_colliding()
	
	handle_state(input_dir)
	if dynamic_fov: # This may be changed to an AnimationPlayer
		update_camera_fov()
	
	if view_bobbing:
		play_headbob_animation(input_dir)
	
	
	if !was_on_floor and is_on_floor(): # The player just landed
		play_jump_animation()
	
	WEAPON.handle_input()
	
	
	was_on_floor = is_on_floor() # This must always be at the end of physics_process

#endregion

#region Input Handling

func get_facing_direction() -> Vector3:
	return -CAMERA.get_global_transform().basis.z.normalized()

var can_do_another_jump: bool = true;

func handle_jumping() -> void:
	if !Input.is_action_just_pressed(CONTROLS.JUMP) and !low_ceiling:
		return
	
	var multiply: int = 1
	if is_in_air():
		if AIR_JUMP.can_air_jump():
			multiply = AIR_JUMP.get_multiply()
		else:
			return
	else:
		AIR_JUMP.start_timer()
		AIR_JUMP.reset()
	
	JUMP_ANIMATION.play("jump", 0.25)
	velocity.y += JUMP_VELOCITY * multiply


func handle_movement(delta: float, input_dir: Vector2) -> void:
	var direction_temp: Vector2 = input_dir.rotated(-HEAD.rotation.y)
	var direction: Vector3 = Vector3(direction_temp.x, 0, direction_temp.y)
	
	move_and_slide()

	var target_velocity: Vector3 = direction * speed
	target_velocity.y = velocity.y

	if !DASH.is_dashing():
		velocity = velocity.lerp(target_velocity, ACCELLERATION * delta)
	else:
		velocity = target_velocity
		
	velocity = velocity.clamp(Vector3.ONE * -MAX_VELOCITY, Vector3.ONE * MAX_VELOCITY)


func handle_head_rotation() -> void:
	if INVERT_CAMERA_X_AXIS:
		HEAD.rotation_degrees.y -= mouseInput.x * MOUSE_SENSIBILITY * -1
	else:
		HEAD.rotation_degrees.y -= mouseInput.x * MOUSE_SENSIBILITY

	if INVERT_CAMERA_Y_AXIS:
		HEAD.rotation_degrees.x -= mouseInput.y * MOUSE_SENSIBILITY * -1
	else:
		HEAD.rotation_degrees.x -= mouseInput.y * MOUSE_SENSIBILITY

	mouseInput = Vector2(0,0)
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))

#endregion

#region State Handling

func handle_state(moving: Vector2) -> void:
	if sprint_enabled:
		if sprint_mode == 0:
			if Input.is_action_pressed(CONTROLS.SPRINT) && state != "crouching":
				if moving:
					if state != "sprinting":
						enter_sprint_state()
				else:
					if state == "sprinting":
						enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()
		elif sprint_mode == 1:
			if moving:
				# If the player is holding sprint before moving, handle that scenario
				if Input.is_action_pressed(CONTROLS.SPRINT) && state == "normal":
					enter_sprint_state()
				if Input.is_action_just_pressed(CONTROLS.SPRINT):
					match state:
						"normal":
							enter_sprint_state()
						"sprinting":
							enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()

	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed(CONTROLS.CROUCH) && state != "sprinting" && is_on_floor():
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" && !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed(CONTROLS.CROUCH):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()

# Any enter state function should only be called once when you want to enter that state, not every frame.
func enter_normal_state() -> void:
	#print("entering normal state")
	var prev_state: String = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "normal"
	speed = BASE_SPEED
	state_changed.emit(prev_state, state)

func enter_crouch_state() -> void:
	#print("entering crouch state")
	state_changed.emit(state, "crouching")
	state = "crouching"
	speed = CROUCH_SPEED
	CROUCH_ANIMATION.play("crouch")

func enter_sprint_state() -> void:
	#print("entering sprint state")
	var prev_state: String = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "sprinting"
	speed = SPRINT_SPEED
	state_changed.emit(prev_state, state)

#endregion

#region Animation Handling

func initialize_animations() -> void:
	# Reset the camera position
	# If you want to change the default head height, change these animations.
	HEADBOB_ANIMATION.play("RESET")
	JUMP_ANIMATION.play("RESET")
	CROUCH_ANIMATION.play("RESET")

func play_headbob_animation(moving: Vector2) -> void:
	if moving && is_on_floor():
		var use_headbob_animation: String
		match state:
			"normal","crouching":
				use_headbob_animation = "walk"
			"sprinting":
				use_headbob_animation = "sprint"

		var was_playing: bool = false
		if HEADBOB_ANIMATION.current_animation == use_headbob_animation:
			was_playing = true

		HEADBOB_ANIMATION.play(use_headbob_animation, 0.25)
		HEADBOB_ANIMATION.speed_scale = (current_speed / BASE_SPEED) * 1.75
		if !was_playing:
			HEADBOB_ANIMATION.seek(float(randi() % 2)) # Randomize the initial headbob direction
			# Let me explain that piece of code because it looks like it does the opposite of what it actually does.
			# The headbob animation has two starting positions. One is at 0 and the other is at 1.
			# randi() % 2 returns either 0 or 1, and so the animation randomly starts at one of the starting positions.
			# This code is extremely performant but it makes no sense.

	else:
		if HEADBOB_ANIMATION.current_animation == "sprint" or HEADBOB_ANIMATION.current_animation == "walk":
			HEADBOB_ANIMATION.speed_scale = 1
			HEADBOB_ANIMATION.play("RESET", 1)

func play_jump_animation() -> void:
	var facing_direction: Vector3 = CAMERA.get_global_transform().basis.x
	var facing_direction_2D: Vector2 = Vector2(facing_direction.x, facing_direction.z).normalized()
	var velocity_2D: Vector2 = Vector2(velocity.x, velocity.z).normalized()

	# Compares velocity direction against the camera direction (via dot product) to determine which landing animation to play.
	var side_landed: int = round(velocity_2D.dot(facing_direction_2D))

	if side_landed > 0:
		JUMP_ANIMATION.play("land_right", 0.25)
	elif side_landed < 0:
		JUMP_ANIMATION.play("land_left", 0.25)
	else:
		JUMP_ANIMATION.play("land_center", 0.25)

#endregion

#region Debug Menu



func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion && Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouseInput.x += event.relative.x
		mouseInput.y += event.relative.y
	if event is InputEventKey && event.pressed and not event.echo:
		if event.keycode == KEY_F2:
			global_position = Vector3.ZERO

#endregion

#region Misc Functions

func update_camera_fov() -> void:
	if state == "sprinting":
		CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.3)

func handle_pausing() -> void:
	if Input.is_action_just_pressed(CONTROLS.PAUSE):
		# You may want another node to handle pausing, because this player may get paused too.
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				#get_tree().paused = false
			Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				#get_tree().paused = false


func is_in_air() -> bool: # Funzione inutile, solo per leggibilità, abbiate la stessa filosofia :D
	return !is_on_floor()

#endregion
