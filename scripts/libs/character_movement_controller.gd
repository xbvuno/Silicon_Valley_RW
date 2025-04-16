# Moviment Controller extract from
# https://godotengine.org/asset-library/asset/2418

# [xbvuno] ho rimosso l'interfaccia, debug menù e reticle, questo script ora si occuperà solo del movimento
# ho anche un signal state_changed :D

# COPYRIGHT Colormatic Studios
# MIT license
# Quality Godot First Person Controller v2

extends CharacterBody3D
class_name CharacterMovementController

#region Character Export Group

## The settings for the character's movement and feel.
@export_category("Character")
## The speed that the character moves at without crouching or sprinting.
@export var base_speed : float = 3.0
## The speed that the character moves at when sprinting.
@export var sprint_speed : float = 6.0
## The speed that the character moves at when crouching.
@export var crouch_speed : float = 1.0

## How fast the character speeds up and slows down when Motion Smoothing is on.
@export var acceleration : float = 10.0
## How high the player jumps.
@export var jump_velocity : float = 4.5
## How far the player turns when the mouse is moved.
@export var mouse_sensitivity : float = 0.1
## Invert the X axis input for the camera.
@export var invert_camera_x_axis : bool = false
## Invert the Y axis input for the camera.
@export var invert_camera_y_axis : bool = false
## Whether the player can use movement inputs. Does not stop outside forces or jumping. See Jumping Enabled.
@export var immobile : bool = false
## The reticle file to import at runtime. By default are in res://addons/fpc/reticles/. Set to an empty string to remove.

#endregion

#region Nodes Export Group

@export_group("Nodes")
## A reference to the camera for use in the character script. This is the parent node to the camera and is rotated instead of the camera for mouse input.
@export var HEAD : Node3D
## A reference to the camera for use in the character script.
@export var CAMERA : Camera3D
## A reference to the headbob animation for use in the character script.
@export var HEADBOB_ANIMATION : AnimationPlayer
## A reference to the jump animation for use in the character script.
@export var JUMP_ANIMATION : AnimationPlayer
## A reference to the crouch animation for use in the character script.
@export var CROUCH_ANIMATION : AnimationPlayer
## A reference to the the player's collision shape for use in the character script.
@export var COLLISION_MESH : CollisionShape3D

#endregion

#region Controls Export Group

# We are using UI controls because they are built into Godot Engine so they can be used right away
@export_group("Controls")
## Use the Input Map to map a mouse/keyboard input to an action and add a reference to it to this dictionary to be used in the script.
@export var controls : Dictionary = {
	LEFT = "ui_left",
	RIGHT = "ui_right",
	FORWARD = "ui_up",
	BACKWARD = "ui_down",
	JUMP = "ui_accept",
	CROUCH = "crouch",
	SPRINT = "sprint",
	PAUSE = "ui_cancel"
	}
@export_subgroup("Controller Specific")
## This only affects how the camera is handled, the rest should be covered by adding controller inputs to the existing actions in the Input Map.
@export var controller_support : bool = false
## Use the Input Map to map a controller input to an action and add a reference to it to this dictionary to be used in the script.
@export var controller_controls : Dictionary = {
	LOOK_LEFT = "look_left",
	LOOK_RIGHT = "look_right",
	LOOK_UP = "look_up",
	LOOK_DOWN = "look_down"
	}
## The sensitivity of the analog stick that controls camera rotation. Lower is less sensitive and higher is more sensitive.
@export_range(0.001, 1, 0.001) var look_sensitivity : float = 0.035

#endregion

#region Feature Settings Export Group

@export_group("Feature Settings")
## Enable or disable jumping. Useful for restrictive storytelling environments.
@export var jumping_enabled : bool = true
## Whether the player can move in the air or not.
@export var in_air_momentum : bool = true
## Smooths the feel of walking.
@export var motion_smoothing : bool = true
## Enables or disables sprinting.
@export var sprint_enabled : bool = true
## Toggles the sprinting state when button is pressed or requires the player to hold the button down to remain sprinting.
@export_enum("Hold to Sprint", "Toggle Sprint") var sprint_mode : int = 0
## Enables or disables crouching.
@export var crouch_enabled : bool = true
## Toggles the crouch state when button is pressed or requires the player to hold the button down to remain crouched.
@export_enum("Hold to Crouch", "Toggle Crouch") var crouch_mode : int = 0
## Wether sprinting should effect FOV.
@export var dynamic_fov : bool = true
## If the player holds down the jump button, should the player keep hopping.
@export var continuous_jumping : bool = true
## Enables the view bobbing animation.
@export var view_bobbing : bool = true
## Enables an immersive animation when the player jumps and hits the ground.
@export var jump_animation : bool = true
## This determines wether the player can use the pause button, not wether the game will actually pause.
@export var pausing_enabled : bool = true
## Use with caution.
@export var gravity_enabled : bool = true
## If your game changes the gravity value during gameplay, check this property to allow the player to experience the change in gravity.
@export var dynamic_gravity : bool = false

#endregion

#region Custom Settings Export Group

@export var DOUBLE_JUMP_ENABLED: bool = false
@export var DASH_ENABLED: bool = false
@export var DASH_SPEED: float = 10
@export var DASH_DURATION_SEC: float = 0.3
@export var MAX_VELOCITY: float = 20

@export var DOUBLE_JUMP_BOOST: float = 1.2

#endregion

#region Custon Node Export Group

@export var DOUBLE_TAP_TIMER: Timer
@export var DASH_COOLDOWN : Timer
@export var WEAPON: Node3D
@export var DEFEND_ZONE: Area3D

#endregion

#region Member Variable Initialization


signal state_changed(old_state, new_state)

# These are variables used in this script that don't need to be exposed in the editor.
var speed : float = base_speed
var current_speed : float = 0.0
# States: normal, crouching, sprinting
var state : String = "normal"
var low_ceiling : bool = false # This is for when the ceiling is too low and the player needs to crouch.
var was_on_floor : bool = true # Was the player on the floor last frame (for landing animation)

# The reticle should always have a Control node as the root
var RETICLE : Control

# Get the gravity from the project settings to be synced with RigidBody nodes
var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process

# Stores mouse input for rotating the camera in the physics process
var mouseInput : Vector2 = Vector2(0,0)

#endregion

#region Main Control Flow

var DASH_DURATION: Timer 

func _ready():
	#It is safe to comment this line if your game doesn't start with the mouse captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	
	DASH_DURATION = Timer.new()
	DASH_DURATION.wait_time = DASH_DURATION_SEC
	DASH_DURATION.one_shot = true
	DASH_DURATION.timeout.connect((func(): is_dashing = false).call)
	add_child(DASH_DURATION)
	
	DEFEND_ZONE.area_entered.connect(on_frontal_attack)
	
	
	# If the controller is rotated in a certain direction for game design purposes, redirect this rotation into the head.
	HEAD.rotation.y = rotation.y
	rotation.y = 0

	initialize_animations()
	check_controls()
	enter_normal_state()


func _process(_delta):
	if pausing_enabled:
		handle_pausing()

func on_frontal_attack(area: Area3D):
	if not area.is_in_group("weapons"): # se non è un arma esci
		return
	
	var weapon_attacking = area.get_parent()
	if weapon_attacking == WEAPON: # se è la mia stessa arma a colpirmi esci
		return

	if WEAPON.state == 'defend':
		print('hai subito danno mentre difendevi')
		if WEAPON.can_parry:
			print('hai fatto un parry!')
	else:
		print('hai preso tutto il danno')
		
		

func _physics_process(delta): # Most things happen here.
	# Gravity
	if dynamic_gravity:
		gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	if not is_on_floor() and gravity and gravity_enabled and not is_dashing:
		velocity.y -= gravity * delta

	handle_jumping()

	var input_dir = Vector2.ZERO

	if not immobile: # Immobility works by interrupting user input, so other forces can still be applied to the player
		input_dir = Input.get_vector(controls.LEFT, controls.RIGHT, controls.FORWARD, controls.BACKWARD)
		
	handle_movement(delta, input_dir)

	if DASH_ENABLED and DASH_COOLDOWN.is_stopped():
			handle_double_tap()

	handle_head_rotation()

	# The player is not able to stand up if the ceiling is too low
	low_ceiling = $CrouchCeilingDetection.is_colliding()

	handle_state(input_dir)
	if dynamic_fov: # This may be changed to an AnimationPlayer
		update_camera_fov()

	if view_bobbing:
		play_headbob_animation(input_dir)

	if jump_animation:
		play_jump_animation()
		
	WEAPON.handle_input()
		

	was_on_floor = is_on_floor() # This must always be at the end of physics_process

#endregion

#region Input Handling

var dash_multiply: float = 1

var is_dashing: bool = false;


func dash(action):
	var front = -CAMERA.get_global_transform().basis.z.normalized()
	var right = front.cross(Vector3.UP).normalized()
	
	var directions = {
		controls.FORWARD: front,
		controls.LEFT: -right,
		controls.BACKWARD: -front,
		controls.RIGHT: right
	}
	
	var direction = directions[action]
	direction.y = 0
	var tw: Tween = get_tree().create_tween()
	tw.tween_property(self, "velocity", direction * DASH_SPEED, DASH_DURATION_SEC)
	DASH_COOLDOWN.start()
	DASH_DURATION.start()
	is_dashing = true;


var last_direction_tap: String = ''
func handle_double_tap():
	if state == 'crouching':
		return
	for m_action in [last_direction_tap, controls.FORWARD, controls.LEFT,  controls.BACKWARD, controls.RIGHT]: # tutti le possibili action di movimento, dando priorità a quella già premuta c[]
		if m_action and Input.is_action_just_pressed(m_action):
			if DOUBLE_TAP_TIMER.is_stopped() or last_direction_tap != m_action: # Se il tempo per attivare il double tap è finito oppure se 
				last_direction_tap = m_action
				DOUBLE_TAP_TIMER.start()
			else:
				dash(m_action)
				last_direction_tap = ''
				

var can_do_another_jump: bool = true;

func handle_jumping():
	if jumping_enabled:
		if continuous_jumping: # Hold down the jump button
			if Input.is_action_pressed(controls.JUMP) and is_on_floor() and !low_ceiling:
				if jump_animation:
					JUMP_ANIMATION.play("jump", 0.25)
				velocity.y += jump_velocity # Adding instead of setting so jumping on slopes works properly
		else:
			if Input.is_action_just_pressed(controls.JUMP) and (is_on_floor() or (DOUBLE_JUMP_ENABLED and can_do_another_jump)) and !low_ceiling:
				var multiply = 1
				if can_do_another_jump:
					multiply = DOUBLE_JUMP_BOOST
					can_do_another_jump = false;
					
				if jump_animation:
					JUMP_ANIMATION.play("jump", 0.25)
				#velocity.y += jump_velocity
				var tw: Tween = get_tree().create_tween()
				tw.tween_property(self, "velocity", Vector3.UP * jump_velocity * multiply, 0.01) #####
	
	if is_on_floor():
		can_do_another_jump = true; ## da fare update con un timer, ora mi scoccia ;b
		


func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	
	move_and_slide()

	var target_velocity = direction * max(speed, dash_multiply)

	if in_air_momentum and not(is_on_floor()): # air momentum attivo e in aria
		return

	if motion_smoothing and not is_dashing:
		velocity.x = lerp(velocity.x, target_velocity.x, acceleration * delta)
		velocity.z = lerp(velocity.z, target_velocity.z, acceleration * delta)
	else:
		velocity.x = target_velocity.x
		velocity.z = target_velocity.y
		
	velocity = velocity.clamp(Vector3.ONE * -MAX_VELOCITY, Vector3.ONE * MAX_VELOCITY)


func handle_head_rotation():
	if invert_camera_x_axis:
		HEAD.rotation_degrees.y -= mouseInput.x * mouse_sensitivity * -1
	else:
		HEAD.rotation_degrees.y -= mouseInput.x * mouse_sensitivity

	if invert_camera_y_axis:
		HEAD.rotation_degrees.x -= mouseInput.y * mouse_sensitivity * -1
	else:
		HEAD.rotation_degrees.x -= mouseInput.y * mouse_sensitivity

	if controller_support:
		var controller_view_rotation = Input.get_vector(controller_controls.LOOK_DOWN, controller_controls.LOOK_UP, controller_controls.LOOK_RIGHT, controller_controls.LOOK_LEFT) * look_sensitivity # These are inverted because of the nature of 3D rotation.
		if invert_camera_x_axis:
			HEAD.rotation.x += controller_view_rotation.x * -1
		else:
			HEAD.rotation.x += controller_view_rotation.x

		if invert_camera_y_axis:
			HEAD.rotation.y += controller_view_rotation.y * -1
		else:
			HEAD.rotation.y += controller_view_rotation.y

	mouseInput = Vector2(0,0)
	HEAD.rotation.x = clamp(HEAD.rotation.x, deg_to_rad(-90), deg_to_rad(90))


func check_controls(): # If you add a control, you might want to add a check for it here.
	# The actions are being disabled so the engine doesn't halt the entire project in debug mode
	if !InputMap.has_action(controls.JUMP):
		push_error("No control mapped for jumping. Please add an input map control. Disabling jump.")
		jumping_enabled = false
	if !InputMap.has_action(controls.LEFT):
		push_error("No control mapped for move left. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(controls.RIGHT):
		push_error("No control mapped for move right. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(controls.FORWARD):
		push_error("No control mapped for move forward. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(controls.BACKWARD):
		push_error("No control mapped for move backward. Please add an input map control. Disabling movement.")
		immobile = true
	if !InputMap.has_action(controls.PAUSE):
		push_error("No control mapped for pause. Please add an input map control. Disabling pausing.")
		pausing_enabled = false
	if !InputMap.has_action(controls.CROUCH):
		push_error("No control mapped for crouch. Please add an input map control. Disabling crouching.")
		crouch_enabled = false
	if !InputMap.has_action(controls.SPRINT):
		push_error("No control mapped for sprint. Please add an input map control. Disabling sprinting.")
		sprint_enabled = false

#endregion

#region State Handling

func handle_state(moving):
	if sprint_enabled:
		if sprint_mode == 0:
			if Input.is_action_pressed(controls.SPRINT) and state != "crouching":
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
				if Input.is_action_pressed(controls.SPRINT) and state == "normal":
					enter_sprint_state()
				if Input.is_action_just_pressed(controls.SPRINT):
					match state:
						"normal":
							enter_sprint_state()
						"sprinting":
							enter_normal_state()
			elif state == "sprinting":
				enter_normal_state()

	if crouch_enabled:
		if crouch_mode == 0:
			if Input.is_action_pressed(controls.CROUCH) and state != "sprinting" and is_on_floor():
				if state != "crouching":
					enter_crouch_state()
			elif state == "crouching" and !$CrouchCeilingDetection.is_colliding():
				enter_normal_state()
		elif crouch_mode == 1:
			if Input.is_action_just_pressed(controls.CROUCH):
				match state:
					"normal":
						enter_crouch_state()
					"crouching":
						if !$CrouchCeilingDetection.is_colliding():
							enter_normal_state()





# Any enter state function should only be called once when you want to enter that state, not every frame.
func enter_normal_state():
	#print("entering normal state")
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "normal"
	speed = base_speed
	state_changed.emit(prev_state, state)

func enter_crouch_state():
	#print("entering crouch state")
	state_changed.emit(state, "crouching")
	state = "crouching"
	speed = crouch_speed
	CROUCH_ANIMATION.play("crouch")

func enter_sprint_state():
	#print("entering sprint state")
	var prev_state = state
	if prev_state == "crouching":
		CROUCH_ANIMATION.play_backwards("crouch")
	state = "sprinting"
	speed = sprint_speed
	state_changed.emit(prev_state, state)

#endregion

#region Animation Handling

func initialize_animations():
	# Reset the camera position
	# If you want to change the default head height, change these animations.
	HEADBOB_ANIMATION.play("RESET")
	JUMP_ANIMATION.play("RESET")
	CROUCH_ANIMATION.play("RESET")

func play_headbob_animation(moving):
	if moving and is_on_floor():
		var use_headbob_animation : String
		match state:
			"normal","crouching":
				use_headbob_animation = "walk"
			"sprinting":
				use_headbob_animation = "sprint"

		var was_playing : bool = false
		if HEADBOB_ANIMATION.current_animation == use_headbob_animation:
			was_playing = true

		HEADBOB_ANIMATION.play(use_headbob_animation, 0.25)
		HEADBOB_ANIMATION.speed_scale = (current_speed / base_speed) * 1.75
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

func play_jump_animation():
	if !was_on_floor and is_on_floor(): # The player just landed
		var facing_direction : Vector3 = CAMERA.get_global_transform().basis.x
		var facing_direction_2D : Vector2 = Vector2(facing_direction.x, facing_direction.z).normalized()
		var velocity_2D : Vector2 = Vector2(velocity.x, velocity.z).normalized()

		# Compares velocity direction against the camera direction (via dot product) to determine which landing animation to play.
		var side_landed : int = round(velocity_2D.dot(facing_direction_2D))

		if side_landed > 0:
			JUMP_ANIMATION.play("land_right", 0.25)
		elif side_landed < 0:
			JUMP_ANIMATION.play("land_left", 0.25)
		else:
			JUMP_ANIMATION.play("land_center", 0.25)

#endregion

#region Debug Menu



func _unhandled_input(event : InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		mouseInput.x += event.relative.x
		mouseInput.y += event.relative.y
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_F2:
			global_position = Vector3.ZERO

#endregion

#region Misc Functions

func update_camera_fov():
	if state == "sprinting":
		CAMERA.fov = lerp(CAMERA.fov, 85.0, 0.3)
	else:
		CAMERA.fov = lerp(CAMERA.fov, 75.0, 0.3)

func handle_pausing():
	if Input.is_action_just_pressed(controls.PAUSE):
		# You may want another node to handle pausing, because this player may get paused too.
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				#get_tree().paused = false
			Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				#get_tree().paused = false


#endregion
