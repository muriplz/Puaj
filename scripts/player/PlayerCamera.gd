extends Camera3D

# Player reference
var player: Node3D
@onready var tile_manager = $"../../TileManager"

# Orbit control variables
var is_dragging = false
var horizontal_angle = 0.0
var vertical_angle = 0.3
var orbit_speed = 0.005

var distance = 5.0

# Variables for top-down camera
var top_down_height = 50.0
var top_down_position = Vector2.ZERO

# Switch between orbit and top-down camera modes
var use_orbit_camera = true

# Multitouch zooming
var is_pinching := false
var initial_pinch_distance := -1.0
var last_scale_factor := 1.0
var touch_points: Dictionary = {}

func _ready():
	player = get_parent()
	set_initial_camera_position()

func set_initial_camera_position():
	if use_orbit_camera:
		update_orbit_camera_position()
	else:
		update_top_down_camera_position()
		

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_dragging = event.pressed

	if use_orbit_camera and is_dragging:
		if event is InputEventMouseMotion:
			horizontal_angle -= event.relative.x * orbit_speed
			vertical_angle += event.relative.y * orbit_speed
			vertical_angle = clamp(vertical_angle, PI / 48, PI / 2)

	# Handle zoom with mouse wheel
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			if use_orbit_camera:
				distance = max(distance - 1, 5)
			else:
				top_down_height = max(top_down_height - 5, 50)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			if use_orbit_camera:
				distance = min(distance + 1, 100)
			else:
				top_down_height = min(top_down_height + 5, 1000)

	# Handle mouse button for dragging
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_dragging = event.pressed

	
	# Delegate multitouch handling to the handle_multitouch method
	handle_multitouch(event)

func handle_multitouch(event):
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_points[event.index] = event.position
			# Reset for a new pinch gesture if two fingers are down
			if touch_points.size() == 2:
				var touch_positions = Array(touch_points.values())
				initial_pinch_distance = touch_positions[0].distance_to(touch_positions[1])
				last_scale_factor = 1.0
				is_pinching = true
		else:
			touch_points.erase(event.index)
			if touch_points.size() < 2:
				is_pinching = false

	elif event is InputEventScreenDrag and is_pinching:
		if touch_points.size() == 2:
			if touch_points.has(event.index):
				touch_points[event.index] = event.position

			var touch_positions = Array(touch_points.values())
			var current_distance = touch_positions[0].distance_to(touch_positions[1])
			var current_scale_factor = current_distance / initial_pinch_distance

		# Calculate change in scale from the last frame to this frame
			var scale_change = current_scale_factor / last_scale_factor
			last_scale_factor = current_scale_factor  # Update last_scale_factor for the next frame

		# Correctly apply the change in scale to the camera for intended zoom direction
			if use_orbit_camera:
				distance /= scale_change  # Invert the zoom direction
				distance = clamp(distance, 5, 100)
			else:
				top_down_height /= scale_change  # Invert the zoom direction
				top_down_height = clamp(top_down_height, 10, 1000)

		# Update camera position
		if use_orbit_camera:
			update_orbit_camera_position()
		else:
			update_top_down_camera_position()

	
func _process(delta):
	if player:
		if use_orbit_camera:
			var tile_coords = Utils.world_to_tile(player.global_transform.origin)
			tile_manager.render_chunks(tile_coords)
			update_orbit_camera_position()
		else:
			var tile_coords = Utils.world_to_tile(global_transform.origin)
			tile_manager.render_chunks(tile_coords)
			update_top_down_camera_position()

func update_orbit_camera_position():
	# Ensure vertical_angle does not cause look_at() to fail
	vertical_angle = clamp(vertical_angle, -PI / 2 + 0.01, PI / 2 - 0.01)

	var direction = Vector3(
		sin(horizontal_angle) * cos(vertical_angle),
		sin(vertical_angle),
		cos(horizontal_angle) * cos(vertical_angle)
	).normalized()
	var new_position = player.global_transform.origin + direction * distance
	global_transform.origin = new_position
	look_at(player.global_transform.origin, Vector3.UP)


func update_top_down_camera_position():
	# Update the camera's global position
	global_transform.origin = Vector3(top_down_position.x, top_down_height, top_down_position.y)
	
	# Correctly make the camera look straight down. The key is setting the target directly below, and adjusting the up direction if needed
	look_at(global_transform.origin + Vector3(0, -1, 0), Vector3(0, 0, -1))

func _on_view_mode_toggled(toggled_on):
	use_orbit_camera = !toggled_on
	if use_orbit_camera:
		set_initial_camera_position()
	else:
		top_down_height = 50.0
		top_down_position = Vector2.ZERO
		update_top_down_camera_position()

func _unhandled_input(event):
	if not use_orbit_camera and is_dragging:
		if event is InputEventMouseMotion:
			# Calculate the movement factor based on the camera's current height
			var movement_factor = top_down_height / 50.0  # Adjust 50.0 based on the default height for 1:1 movement

			# Apply the movement factor to make the drag proportional to the zoom level
			top_down_position -= event.relative * 0.1 * movement_factor
			update_top_down_camera_position()

