extends Camera3D

# Player reference
var player: Node3D

# Orbit control variables
var is_dragging = false
var horizontal_angle = 0.0
# Start with a slightly upward angle; adjust as needed
var vertical_angle = 0.3 # Adjust this value to set the initial downward angle
var orbit_speed = 0.005

var distance = 5.0  # Initial distance from the player to the camera

func _ready():
	player = get_parent()

	# Adjust the initial camera setup to start from a better angle
	var initial_direction = Vector3(
		sin(horizontal_angle) * cos(vertical_angle),
		sin(vertical_angle),
		cos(horizontal_angle) * cos(vertical_angle)
	).normalized()
	look_at_from_position(player.global_transform.origin + initial_direction * distance, player.global_transform.origin, Vector3.UP)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed

	if event is InputEventMouseMotion and is_dragging:
		horizontal_angle -= event.relative.x * orbit_speed
		vertical_angle += event.relative.y * orbit_speed
		# Ensure the camera does not flip over
		vertical_angle = clamp(vertical_angle, PI / 12, PI / 2)

	# Adjusting zoom by changing distance
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			distance = max(distance - 1, 5) # Zoom in, minimum distance 5
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			distance = min(distance + 1, 20) # Zoom out, maximum distance 20

func _process(_delta):
	if player == null:
		return

	# Calculate new camera position based on orbit angles
	var direction = Vector3(
		sin(horizontal_angle) * cos(vertical_angle),
		sin(vertical_angle),
		cos(horizontal_angle) * cos(vertical_angle)
	).normalized()

	var new_position = player.global_transform.origin + direction * distance

	# Update camera position and orientation
	global_transform.origin = new_position
	look_at(player.global_transform.origin, Vector3.UP)
