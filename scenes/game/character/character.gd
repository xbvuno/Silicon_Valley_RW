# Moviment Controller estratto da
# https://godotengine.org/asset-library/asset/2418

#  <(o )___     QUESTA PAPERELLA È QUI PER MANGIARE I BUG
#    ( ._> /    TOCCA LA PAPERELLA E LA PRENDO SUL PERSONALE >:|

extends CharacterBody3D
class_name Character

#region State Machine Export
@export_category("State Machine")
@export var state_machine: StateMachine

#region Character Export

## The settings for the character's movement and feel.
@export_category("Character")
## The speed that the character moves at without crouching or sprinting.
@export var BASE_SPEED : float = 6.0
## The speed that the character moves at when sprinting.
@export var SPRINT_SPEED : float = 9.0
## The speed that the character moves at when crouching.
@export var CROUCH_SPEED : float = 3.0
## How high the player jumps.
@export var JUMP_VELOCITY : float = 10.0
## How fast the character speeds up and slows down when Motion Smoothing is on.
@export var ACCELLERATION : float = 10.0

## How far the player turns when the mouse is moved.
@export var MOUSE_SENSIBILITY : float = 0.1
## Invert the X axis input for the camera.
@export var INVERT_CAMERA_X_AXIS : bool = false
## Invert the Y axis input for the camera.
@export var INVERT_CAMERA_Y_AXIS : bool = false
## Whether the player can use movement inputs. Does not stop outside forces or jumping. See Jumping Enabled.
@export var IMMOBILE : bool = false

#endregion

#region Nodes Export

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

#region Controls Export

# We are using UI controls because they are built into Godot Engine so they can be used right away
@export_group("Controls")
## Use the Input Map to map a mouse/keyboard input to an action and add a reference to it to this dictionary to be used in the script.
@export var CONTROLS : Dictionary = {
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
@export var jumping_enabled : bool = true
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
## Enables the view bobbing animation.
@export var view_bobbing : bool = true
## This determines wether the player can use the pause button, not wether the game will actually pause.
@export var PAUSING_ENABLED : bool = true
## If your game changes the gravity value during gameplay, check this property to allow the player to experience the change in gravity.

#endregion

#region Custom Settings Export Group

@export_group("Custom Settings")
@export var DOUBLE_JUMP_ENABLED: bool = true
@export var MAX_VELOCITY: float = 20
@export var DOUBLE_JUMP_BOOST: float = 1.4

#endregion

#region Dash Settings

@export_group("Dash Settings")
## Dash enabled.
@export var ENABLED: bool = true
## Speed of the dash.
@export var SPEED: float = 20
## Duration of the dash in seconds: How fast the dash will be.
@export var DURATION_SEC: float = 0.3
## Cooldown of the dash in seconds: How long until the dash can be used again.
@export var COOLDOWN_SEC: float = 1.0
## Double tap time in seconds: The arc of time in which the dash can be activated by double tapping.
@export var DOUBLE_TAP_SEC: float = 0.2
## Max number of dashes in air you can do before touching ground
@export var MAX_AIR_DASHES: int =  1

#endregion


#region Custon Node Export Group

@export_group("Custom Nodes")

@export var WEAPON: Node3D
@export var DEFEND_ZONE: Area3D

#endregion

#region Member Variable Initialization
# These are variables used in this script that don't need to be exposed in the editor.
var speed : float = BASE_SPEED
var current_speed : float = 0.0
# States: normal, crouching, sprinting
var state : String = "normal"
var low_ceiling : bool = false # This is for when the ceiling is too low and the player needs to crouch.
var was_on_floor : bool = true # Was the player on the floor last frame (for landing animation)

# Get the gravity from the project settings to be synced with RigidBody nodes
var GRAVITY : float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process

# Stores mouse input for rotating the camera in the physics process
var mouseInput : Vector2 = Vector2.ZERO
var input_dir : Vector2 = Vector2.ZERO
var DOUBLE_TAP_TIMER: Timer
var last_action_tap: String = ''
var is_double_tap: bool = false
#endregion

#region Main Control Flow

@onready var MOVIMENT_CONTROLS: Dictionary = {
	LEFT = CONTROLS.LEFT,
	RIGHT = CONTROLS.RIGHT,
	FORWARD = CONTROLS.FORWARD,
	BACKWARD = CONTROLS.BACKWARD,
}

@onready var DASH: Node = $StateMachine/DashState


func _ready():
	#It is safe to comment this line if your game doesn't start with the mouse captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DOUBLE_TAP_TIMER = Utils.timer_from_time(DOUBLE_TAP_SEC, true, self)
	DEFEND_ZONE.area_entered.connect(on_frontal_attack)
	
	# If the controller is rotated in a certain direction for game design purposes, redirect this rotation into the head.
	HEAD.rotation.y = rotation.y
	rotation.y = 0
	
	set_floor_max_angle(PI / 6)
	initialize_animations()
	speed = BASE_SPEED

	
func _process(_delta):
	if PAUSING_ENABLED:
		handle_pausing()

func on_frontal_attack(area: Area3D):
	if not area.is_in_group("weapons"): # se non è un arma esci
		return
	
	var weapon_attacking = area.get_parent()
	if weapon_attacking == WEAPON: # se è la mia stessa arma a colpirmi esci
		return

	if WEAPON.state == 'defend':
		WEAPON.did_defend = true
		weapon_attacking.get_parent().get_parent().got_parried()
	else:
		print('hai preso tutto il danno')
		
		

func _physics_process(delta): # Most things happen here.

	if GRAVITY and not DASH.is_dashing():
		velocity.y -= GRAVITY * delta


	input_dir = Vector2.ZERO

	if not IMMOBILE:
		input_dir = Input.get_vector(CONTROLS.LEFT, CONTROLS.RIGHT, CONTROLS.FORWARD, CONTROLS.BACKWARD)

	is_double_tap = double_tapped()

	handle_movement(delta, input_dir)
	
	handle_head_rotation()

	# The player is not able to stand up if the ceiling is too low
	low_ceiling = $CrouchCeilingDetection.is_colliding()

	if view_bobbing:
		play_headbob_animation(input_dir)

	WEAPON.handle_input()
		

	was_on_floor = is_on_floor() # This must always be at the end of physics_process

#endregion

#region Input Handling

func get_facing_direction() -> Vector3:
	return -CAMERA.get_global_transform().basis.z.normalized()

var can_do_another_jump: bool = true;

func handle_movement(delta, input_dir):
	var direction = input_dir.rotated(-HEAD.rotation.y)
	direction = Vector3(direction.x, 0, direction.y)
	
	move_and_slide()

	var target_velocity = direction * speed
	target_velocity.y = velocity.y

	if not DASH.is_dashing():
		velocity = velocity.lerp(target_velocity, ACCELLERATION * delta)
	else:
		velocity = target_velocity
		
	velocity = velocity.clamp(Vector3.ONE * -MAX_VELOCITY, Vector3.ONE * MAX_VELOCITY)


func handle_head_rotation():
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


# Any enter state function should only be called once when you want to enter that state, not every frame.

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
func handle_pausing():
	if Input.is_action_just_pressed(CONTROLS.PAUSE):
		# You may want another node to handle pausing, because this player may get paused too.
		match Input.mouse_mode:
			Input.MOUSE_MODE_CAPTURED:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				#get_tree().paused = false
			Input.MOUSE_MODE_VISIBLE:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
				#get_tree().paused = false

func is_in_air(): # Funzione inutile, solo per leggibilità, abbiate la stessa filosofia :D
	return not is_on_floor()

func double_tapped():
	for k_action in MOVIMENT_CONTROLS: # tutti le possibili action di movimento
		var action = MOVIMENT_CONTROLS[k_action]
		if Input.is_action_just_pressed(action):
			if DOUBLE_TAP_TIMER.is_stopped() or last_action_tap != action: # Se il tempo per attivare il double tap è finito oppure se
				last_action_tap = action
				DOUBLE_TAP_TIMER.start()
			else:
				return true
	return false

#endregion
