extends Node

signal mesh_ready_to_add(mesh_instance)

var active_requests = {}
var request_queue = []
var max_concurrent_requests = 3
var thread_pool = []
var mutex = Mutex.new()
var tile_size = Utils.tile_size
var stop_threads = false

func _init():
	for i in range(max_concurrent_requests):
		thread_pool.append(Thread.new())

func _process(_delta):
	# Process queued tile requests if there's capacity
	for thread in thread_pool:
		if thread.is_started():
			thread.wait_to_finish()
	if active_requests.size() < max_concurrent_requests and request_queue.size() > 0:
		mutex.lock()
		var tile_coords = request_queue.pop_front()
		mutex.unlock()
		_request_tile(tile_coords)

func queue_tile(tile_coords: Vector2):
	mutex.lock()
	if active_requests.size() >= max_concurrent_requests:
		request_queue.push_back(tile_coords)  # Queue the request
	else:
		_request_tile(tile_coords)
	mutex.unlock()

func _request_tile(tile_coords: Vector2):
	var url = "https://kryeit.com/images/tiles/17/%s_%s.png" % [tile_coords.x, tile_coords.y]
	var http_request = HTTPRequest.new()
	add_child(http_request)
	# Use original Callable as requested
	http_request.connect("request_completed", Callable(self, "_http_request_completed").bind(tile_coords))
	http_request.request(url)
	mutex.lock()
	active_requests[tile_coords] = http_request
	mutex.unlock()

func _http_request_completed(status: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray, tile_coords):
	mutex.lock()
	if active_requests.has(tile_coords):
		active_requests[tile_coords].queue_free()
		active_requests.erase(tile_coords)
	mutex.unlock()

	if status == OK and response_code == 200:
		var image = Image.new()
		if image.load_png_from_buffer(body) == OK:
			_process_image_in_thread(image, tile_coords)

func _process_image_in_thread(image: Image, tile_coords: Vector2):
	for thread in thread_pool:
		if not thread.is_started():
			thread.start(Callable(self, "_create_mesh_with_texture").bind(image, tile_coords))
			break

func _create_mesh_with_texture(image: Image, tile_coords: Vector2) -> void:
	var texture = ImageTexture.create_from_image(image)

	var key = str(tile_coords)
	if not Utils.loaded_meshes.has(key):
		var mesh_instance = create_mesh_instance_with_texture(texture, tile_coords)
		Utils.loaded_meshes[key] = mesh_instance
		Utils.loaded_tiles[tile_coords] = mesh_instance
	
		
func create_mesh_instance_with_texture(texture: Texture, tile_coords: Vector2) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = tile_size
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	mesh_instance.mesh = plane_mesh
	mesh_instance.material_override = material

	call_deferred_thread_group("set_mesh_origin", mesh_instance, tile_coords)
	call_deferred_thread_group("emit_signal", "mesh_ready_to_add", mesh_instance)

	return mesh_instance

func set_mesh_origin(mesh_instance, tile_coords):
	# Calculate the position of the tile relative to the origin tile
	var tile_offset = Vector3((tile_coords.x - Utils.origin_tile.x) * Utils.tile_size.x, 0, (tile_coords.y - Utils.origin_tile.y) * Utils.tile_size.y)

	# Calculate the absolute world position of the origin tile
	var origin_world_position = Utils.tile_to_world(Utils.origin_tile.x, Utils.origin_tile.y)

	# Combine the origin world position with the tile offset to get the final grid position
	var grid_position = origin_world_position + tile_offset

	# Set the mesh instance's origin to the calculated grid position
	mesh_instance.transform.origin = grid_position
