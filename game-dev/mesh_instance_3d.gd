extends MeshInstance3D

# Movement variables
var speed = 3.5
var direction = Vector3(-1, 0.8, -0.5).normalized()

# Bounce variables
var bounce_time = 0.0
var bounce_height = 0.0

# Rotation variables
var spin_speed = 4.0

# Scale pulse
var scale_time = 0.0
var scale_speed = 3.0

# Color
var color_time = 0.0

# Material for color changes
var material_override_obj = null

func _ready():
	position = Vector3(2, 0, 0)
	
	# Create material so we can change color
	material_override_obj = StandardMaterial3D.new()
	material_override_obj.emission_enabled = true
	material_override_obj.emission_energy_multiplier = 2.0
	set_surface_override_material(0, material_override_obj)

func _process(delta):
	# === MOVEMENT ===
	position += direction * speed * delta
	
	# Bounce off boundaries
	var boundary = 4.0
	
	if abs(position.x) >= boundary:
		direction.x *= -1
		create_bounce_effect()
	
	if abs(position.y) >= boundary:
		direction.y *= -1
		create_bounce_effect()
	
	if abs(position.z) >= boundary:
		direction.z *= -1
		create_bounce_effect()
	
	# === ROTATION ===
	rotation.y += spin_speed * delta
	rotation.x += spin_speed * 0.5 * delta
	
	# === SCALE PULSE ===
	scale_time += scale_speed * delta
	var scale_value = 1.0 + sin(scale_time) * 0.3
	scale = Vector3(scale_value, scale_value, scale_value)
	
	# === DARK VOID COLOR ANIMATION ===
	color_time += delta
	
	# Dark void colors cycling
	var void_pulse = sin(color_time * 0.3) * 0.5 + 0.5
	var void_color
	
	if void_pulse < 0.5:
		# Deep purple to dark
		var darkness = void_pulse / 0.5
		void_color = Color(0.3 * darkness, 0.0, 0.5 * darkness)
	else:
		# Dark to dark blue
		var t = (void_pulse - 0.5) / 0.5
		void_color = Color(0.1 * t, 0.0, 0.4 + t * 0.3)
	
	material_override_obj.albedo_color = void_color
	material_override_obj.emission = void_color

func create_bounce_effect():
	# Quick flash effect on bounce
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector3(1.5, 1.5, 1.5), 0.1)
	tween.tween_property(self, "scale", Vector3(1.0, 1.0, 1.0), 0.1)
