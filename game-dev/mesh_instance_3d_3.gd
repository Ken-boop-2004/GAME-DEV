extends MeshInstance3D

var glow_time = 0.0
var glow_speed = 4.0

var material_obj = null

func _ready():
	# Static position just below the text
	position = Vector3(0, -0.2, 0)
	
	material_obj = StandardMaterial3D.new()
	material_obj.emission_enabled = true
	material_obj.emission_energy_multiplier = 2.0
	set_surface_override_material(0, material_obj)

func _process(delta):
	# Slow reverse rotation (ominous)
	rotation.y -= 0.5 * delta
	
	# === VOID AURA ===
	glow_time += glow_speed * delta
	
	# Unstable flickering
	var chaos = sin(glow_time * 7.0) * cos(glow_time * 4.3)
	var glow_intensity = 2.0 + abs(chaos) * 4.0
	material_obj.emission_energy_multiplier = glow_intensity
	
	# Dark energies
	var void_pulse = sin(glow_time * 0.4) * 0.5 + 0.5
	var aura_color
	
	if void_pulse < 0.5:
		var darkness = void_pulse / 0.5
		aura_color = Color(0.3 * darkness, 0.0, 0.5 * darkness)
	else:
		var t = (void_pulse - 0.5) / 0.5
		aura_color = Color(0.1 * t, 0.0, 0.4 + t * 0.3)
	
	material_obj.albedo_color = aura_color
	material_obj.emission = aura_color
