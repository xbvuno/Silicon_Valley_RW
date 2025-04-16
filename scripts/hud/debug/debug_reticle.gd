extends "res://scripts/hud/debug/debug_character.gd"


## Reference to the char where you want to take the data
@export var RETICLE: Control;

func _ready():
	if RETICLE == null:
		print('[DEBUG] disabled reticle debug, no export given')
		return
		
	properties_to_display.merge({
		'RETICLE': null, # SARÀ SEMPRE FERMO E COLORATO DI GIALLO, IN QUESTO CASO UTILIZZATO COME TITOLO
		'scale': func(): return RETICLE.scale, # funzione lambda
		'alpha': func(): return RETICLE.modulate.a, # funzione lambda
		'pos': func(): return RETICLE.position,
		'size': func(): return RETICLE.size,
		'offset': func(): return RETICLE.anchor_offset
		
		})
	
	super()
