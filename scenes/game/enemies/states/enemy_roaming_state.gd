extends State

## This value will be set by the state machine
var OWNER: Enemy
var SM: SM_Enemy
var CHARACTER: Character
var C_SM: SM_Character
var sm_name: SM_Enemy.States
var readable_name: String

var is_char_in_area_big: bool  = false
var is_char_in_area_small: bool = false

func _ready() -> void:
	super()

	

func _physics_process(_delta: float) -> void:
	check_trigger_areas()


func enter_state():
	OWNER.MESH.mesh.material.albedo_color = Color(0, 256, 0, 0)	#DEBUG : Cambia colore alla mesh
	
func exit_state():
	pass

	
#### Funzione che controlla le aree di trigger dell'aggro dei nemici. 
## Area grande -> Si attiva solo quando si corre o si salta
## Area piccola -> Si attiva anche quando si cammina non accovacciati
func check_trigger_areas():
	if is_char_in_area_big and OWNER.is_player_hearble():	# Se il nemico è in area ed è udibile
		if is_char_in_area_small:	# Se si trova nell'area piccola
			on_char_in_small_area()
		on_char_in_big_area()



#### Controlla se i suoni emessi (stati o actions) dal giocatore sono Weak 
func on_char_in_small_area():
	if C_SM.is_current_in_group(C_SM.SG_SOUND_WEAK) or C_SM.did_action_lately_in_group(C_SM.AG_SOUND_WEAK):
		SM.switch(SM.States.FOLLOWING)


#### Controlla se i suoni emessi (stati o actions) dal giocatore sono LOUD 
func on_char_in_big_area():
	if C_SM.is_current_in_group(C_SM.SG_SOUND_LOUD) or C_SM.did_action_lately_in_group(C_SM.AG_SOUND_LOUD):
		SM.switch(SM.States.FOLLOWING)

#region Area3dSignals
func on_body_enter_area_small(body: Node3D):
	if body.is_in_group("player"):
		is_char_in_area_small = true

func on_body_exit_area_small(body: Node3D):
	if body.is_in_group("player"):
		is_char_in_area_small = false

func on_body_enter_area_big(body: Node3D):
	if body.is_in_group("player"):
		is_char_in_area_big = true

func on_body_exit_area_big(body: Node3D):
	if body.is_in_group("player"):
		is_char_in_area_big = false
