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
var touch_points: Dictionary = {}
var first_finger_pos: Vector2 = Vector2.ZERO
var second_finger_pos: Vector2 = Vector2.ZERO
var is_pinching: bool = false
var pinch_start_distance: float = -1

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
		else:
			touch_points.erase(event.index)
			if touch_points.size() < 2:
				reset_pinch_state()

	if event is InputEventScreenDrag:
		if touch_points.has(event.index):
			touch_points[event.index] = event.position

		if not is_pinching and touch_points.size() == 2:
			var positions: Array = touch_points.values()
			first_finger_pos = positions[0]
			second_finger_pos = positions[1]
			pinch_start_distance = first_finger_pos.distance_to(second_finger_pos)
			is_pinching = true

	if is_pinching and touch_points.size() == 2:
		var positions: Array = touch_points.values()
		first_finger_pos = positions[0]
		second_finger_pos = positions[1]
		var current_distance = first_finger_pos.distance_to(second_finger_pos)
		
		# Define a sensitivity scaling factor (smaller values = less sensitivity)
		var sensitivity_scale = 0.01  # Adjust this value as needed for desired sensitivity

		# Adjust the pinch factor calculation with the sensitivity scaling
		var pinch_factor = 1 + ((pinch_start_distance / current_distance - 1) * sensitivity_scale)


		if use_orbit_camera:
			distance *= pinch_factor
			distance = clamp(distance, 5, 100)
		else:
			top_down_height *= pinch_factor
			top_down_height = clamp(top_down_height, 10, 1000)

		if use_orbit_camera:
			update_orbit_camera_position()
		else:
			update_top_down_camera_position()

	if touch_points.size() < 2:
		reset_pinch_state()


func reset_pinch_state():
	is_pinching = false
	pinch_start_distance = -1
	first_finger_pos = Vector2.ZERO
	second_finger_pos = Vector2.ZERO
	# No need to clear touch_points here as it's managed in _input


	
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

