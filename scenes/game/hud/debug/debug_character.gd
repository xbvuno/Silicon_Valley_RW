extends "./debug_menu.gd"

# FOGLIO UTILIZZABILE COME DEMO PER ESTENDERE IL MENU DI DEBUG
# 1 ) IN EXTEND NON METTERE LO STESSO RIFERIMENTO, FAI RIFERIMENTO A QUESTO FOGLIO E CONTINUA A CASCATA
# 2 ) USA IN EXPORT IL NODO DA CUI ESTRARRE I DATI E FAI UN CONTROLLO IN CASO SIA VUOTO
# 3 ) INSERISCI IN PROPERTIES_TO_DISPLAY CON MERGE() LE PROPRIETÀ CHE VUOI AGGIUNGERE
# 4 ) CHIAMA SUPER() IN MODO CHE VENGA CHIAMATO IL _READY() DELLA CLASSE SUPERIORE
# 5 ) HAI FINITO
# 6 ) ABBI FEDE NELLE PAPERE

## Reference to the char where you want to take the data
@onready var CHARACTER: Character = %Character;
@onready var C_SM: SM_Character = %Character/StateMachine
@onready var W_SM: SM_Weapon = %Character/Head/CurrentWeapon/StateMachine

func _ready():
	if CHARACTER == null:
		print('[DEBUG] disabled character debug, no export given')
		return
		
	properties_to_display.merge({
		'CHARACTER': null, # SARÀ SEMPRE FERMO E COLORATO DI GIALLO, IN QUESTO CASO UTILIZZATO COME TITOLO
		'C.State': func(): return C_SM.current_state.readable_name,
		'can dash': C_SM.STATES[C_SM.S_DASH].can_dash,
		'can air jump': func(): return C_SM.ACTIONS[C_SM.A_JUMP].can_jump(true),
		'WEAPON': null,
		'W.State': func(): return W_SM.current_state.readable_name,
		})
		#'state_movement': func(): return CHARACTER.state_machine.current_movement, # funzione lambda
		#'state_action': func(): return CHARACTER.state_machine.current_action,
		#'in air': func(): return not(CHARACTER.is_on_floor()), # funzione lambda
		#'velocity': func(): return CHARACTER.velocity,
		#'weapon state': func(): return CHARACTER.WEAPON.state,
		#'DASH': null,
		#'DASH COOLDOWN': func(): return CHARACTER.DASH.COOLDOWN_TIMER.time_left,
		#'DASH COOLDOWN TIME': func(): return CHARACTER.DASH.COOLDOWN_TIMER.wait_time,
		#'AIR DASHES': func(): return CHARACTER.DASH.air_dashes,
		#'CAN DASH': func(): return CHARACTER.DASH.can_dash(),
		#'AIR JUMP': null,
		#'FOV': func(): return CHARACTER.CAMERA.fov,
		##'air jumps': func(): return CHARACTER.AIR_JUMP.air_jumps,
		##'air jump cooldown': func(): return CHARACTER.AIR_JUMP.COOLDOWN_TIMER.time_left
		#'CAN AIR JUMP': func(): return %Character/StateMachine/AirJumpState.can_air_jump(),
		#'AIR JUMPS ': func(): return %Character/StateMachine/AirJumpState.air_jumps
		#})
	
	super()
