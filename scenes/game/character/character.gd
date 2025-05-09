# Moviment Controller estratto da
# https://godotengine.org/asset-library/asset/2418

#  <(o )___     QUESTA PAPERELLA È QUI PER MANGIARE I BUG
#    ( ._> /    TOCCA LA PAPERELLA E LA PRENDO SUL PERSONALE >:|

extends CharacterBody3D
class_name Character

#region State Machine Export
@export_category("State Machine")
@onready var SM: SM_Character = $"StateMachine"

#region Character Export

## The settings for the character's movement and feel.
@export_category("Character")
## The speed that the character moves at without crouching or sprinting.
@export var BASE_SPEED: float = 6.0
## The speed that the character moves at when sprinting.
@export var SPRINT_SPEED: float = 9.0
## The speed that the character moves at when crouching.
@export var CROUCH_SPEED: float = 3.0
## How high the player jumps.
@export var JUMP_VELOCITY: float = 10.0
## How fast the character speeds up and slows down when Motion Smoothing is on.
@export var ACCELLERATION: float = 10.0
## Max velocity
@export var MAX_VELOCITY: float = 20

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
@export var CONTROLS: Dictionary = {
	LEFT = "m_left",
	RIGHT = "m_right",
	FORWARD = "m_forward",
	BACKWARD = "m_backward",
	JUMP = "m_jump",
	CROUCH = "m_crouch",
	SPRINT = "m_sprint",
	DASH = "m_dash",
	PAUSE = "ui_cancel"
}

#endregion

#region Feature Settings Export Group

@export_group("Feature Settings")
## This determines wether the player can use the pause button, not wether the game will actually pause.
@export var PAUSING_ENABLED: bool = true
## If your game changes the gravity value during gameplay, check this property to allow the player to experience the change in gravity.

#endregion


#region Custon Node Export Group

@export_group("Custom Nodes")

@export var WEAPON: Node3D
@export var DEFEND_ZONE: Area3D

#endregion

#region Member Variable Initialization
# These are variables used in this script that don't need to be exposed in the editor.

var low_ceiling: bool = false # This is for when the ceiling is too low and the player needs to crouch.
var was_on_floor: bool = true # Was the player on the floor last frame (for landing animation)

# Get the gravity from the project settings to be synced with RigidBody nodes

var speed = BASE_SPEED

var GRAVITY: float = ProjectSettings.get_setting("physics/3d/default_gravity") # Don't set this as a const, see the gravity section in _physics_process

var gravity_enabled: bool = true
func use_gravity(value: bool):
	gravity_enabled = value

var accelleration_enabled: bool = true
func use_accelleration(value: bool):
	accelleration_enabled = value

# Stores mouse input for rotating the camera in the physics process
var mouseInput: Vector2 = Vector2.ZERO
var input_map: Vector2 = Vector2.ZERO
var last_direction: String = ''
#endregion

#region Main Control Flow

@onready var MOVIMENT_CONTROLS: Dictionary = {
	LEFT = CONTROLS.LEFT,
	RIGHT = CONTROLS.RIGHT,
	FORWARD = CONTROLS.FORWARD,
	BACKWARD = CONTROLS.BACKWARD,
}


func _ready():
	#It is safe to comment this line if your game doesn't start with the mouse captured
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	DEFEND_ZONE.area_entered.connect(on_frontal_attack)
	
	# If the controller is rotated in a certain direction for game design purposes, redirect this rotation into the head.
	HEAD.rotation.y = rotation.y
	rotation.y = 0
	
	set_floor_max_angle(PI / 6)
	initialize_animations()

	
func _process(_delta):
	if PAUSING_ENABLED:
		handle_pausing()


func _physics_process(delta): # Most things happen here.
	if GRAVITY and gravity_enabled:
		velocity.y -= GRAVITY * delta

	move_and_slide()
	
	input_map = Vector2.ZERO
	if not IMMOBILE:
		input_map = Input.get_vector(CONTROLS.LEFT, CONTROLS.RIGHT, CONTROLS.FORWARD, CONTROLS.BACKWARD)
	
	handle_movement(delta, input_map)
	
	handle_head_rotation()

	# The player is not able to stand up if the ceiling is too low
	low_ceiling = $CrouchCeilingDetection.is_colliding()

	was_on_floor = is_on_floor() # This must always be at the end of physics_process

#endregion

#region Input Handling

func get_facing_direction() -> Vector3:
	return -CAMERA.get_global_transform().basis.z.normalized()

var direction: Vector3
func handle_movement(delta, input_map):
	direction = calc_input_direction()
	
	
	var target_velocity = direction * speed
	target_velocity.y = velocity.y
	
	if accelleration_enabled:
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

	mouseInput = Vector2(0, 0)
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

#endregion

#region Debug Menu
func _unhandled_input(event: InputEvent):
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

func is_dash_just_pressed():
	if Input.is_action_just_pressed("m_dash"):
		for k_action: String in MOVIMENT_CONTROLS:
			var action = MOVIMENT_CONTROLS[k_action]
			if Input.is_action_pressed(action):
				last_direction = action
				return true
	return false

#endregion

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
		

func calc_input_direction() -> Vector3:
	var dir = input_map.rotated(-HEAD.rotation.y)
	return Vector3(dir.x, 0, dir.y)

func get_input_direction() -> Vector3:
	return direction
	
func get_input_moviment() -> Vector2:
	return input_map

func under_low_ceiling() -> bool:
	return low_ceiling
