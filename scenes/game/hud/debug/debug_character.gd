extends "./debug_menu.gd"

# FOGLIO UTILIZZABILE COME DEMO PER ESTENDERE IL MENU DI DEBUG
# 1 ) IN EXTEND NON METTERE LO STESSO RIFERIMENTO, FAI RIFERIMENTO A QUESTO FOGLIO E CONTINUA A CASCATA
# 2 ) USA IN EXPORT IL NODO DA CUI ESTRARRE I DATI E FAI UN CONTROLLO IN CASO SIA VUOTO
# 3 ) INSERISCI IN PROPERTIES_TO_DISPLAY CON MERGE() LE PROPRIETÀ CHE VUOI AGGIUNGERE
# 4 ) CHIAMA SUPER() IN MODO CHE VENGA CHIAMATO IL _READY() DELLA CLASSE SUPERIORE
# 5 ) HAI FINITO
# 6 ) ABBI FEDE NELLE PAPERE

## Reference to the char where you want to take the data
@export var CHARACTER: CharacterBody3D;

func _ready():
	if CHARACTER == null:
		print('[DEBUG] disabled character debug, no export given')
		return
		
	properties_to_display.merge({
		'CHARACTER': null, # SARÀ SEMPRE FERMO E COLORATO DI GIALLO, IN QUESTO CASO UTILIZZATO COME TITOLO
		'state': func(): return CHARACTER.state, # funzione lambda
		'in air': func(): return not(CHARACTER.is_on_floor()), # funzione lambda
		'velocity': func(): return CHARACTER.velocity,
		'weapon state': func(): return CHARACTER.WEAPON.state,
		'DASH': null,
		'DASH COOLDOWN': func(): return CHARACTER.DASH.COOLDOWN_TIMER.time_left,
		'DASH COOLDOWN TIME': func(): return CHARACTER.DASH.COOLDOWN_TIMER.wait_time,
		'AIR DASHES': func(): return CHARACTER.DASH.air_dashes,
		'CAN DASH': func(): return CHARACTER.DASH.can_dash(),
		'AIR JUMP': null,
		'air jumps': func(): return CHARACTER.AIR_JUMP.air_jumps,
		'air jump cooldown': func(): return CHARACTER.AIR_JUMP.COOLDOWN_TIMER.time_left
			
		
		})
	
	super()
