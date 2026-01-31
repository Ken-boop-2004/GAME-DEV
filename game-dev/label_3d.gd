extends Label3D

# Movement variables
var speed = 2.0
var direction = Vector3(1, 0.5, 0.3).normalized()

# Rotation variables
var rotation_speed_y = 2.0  # Spin around Y axis
var rotation_speed_x = 1.0  # Tilt rotation
var rotation_speed_z = 0.5  # Roll rotation

# Scale animation variables
var scale_time = 0.0
var scale_speed = 2.0
var scale_min = 0.8
var scale_max = 1.5

# Color animation variables
var color_time = 0.0
var color_speed = 1.5

func _ready():
	position = Vector3(0, 0, 0)
	modulate = Color.WHITE

func _process(delta):
	# === MOVEMENT ===
	position += direction * speed * delta
	
	# Bounce off boundaries
	var boundary = 3.0
	
	if abs(position.x) >= boundary:
		direction.x *= -1
	
	if abs(position.y) >= boundary:
		direction.y *= -1
	
	if abs(position.z) >= boundary:
		direction.z *= -1
		position.z = clamp(position.z, -2, 2)
	
	# === ROTATION (Multi-axis) ===
	rotation.y += rotation_speed_y * delta  # Main spin
	rotation.x += rotation_speed_x * delta  # Tilt
	rotation.z += rotation_speed_z * delta  # Roll
	
	# === PULSING SCALE ANIMATION ===
	scale_time += scale_speed * delta
	var scale_value = scale_min + (scale_max - scale_min) * (sin(scale_time) * 0.5 + 0.5)
	scale = Vector3(scale_value, scale_value, scale_value)
	
	# === DARK VOID COLOR ANIMATION ===
	color_time += color_speed * delta
	
	# Dark void colors: Purple → Dark Blue → Black
	var void_pulse = sin(color_time / 5.0) * 0.5 + 0.5
	var void_color
	
	if void_pulse < 0.5:
		# Deep purple to dark
		var darkness = void_pulse / 0.5
		void_color = Color(0.3 * darkness, 0.0, 0.5 * darkness)
	else:
		# Dark to dark blue
		var t = (void_pulse - 0.5) / 0.5
		void_color = Color(0.1 * t, 0.0, 0.4 + t * 0.3)
	
	modulate = void_color
