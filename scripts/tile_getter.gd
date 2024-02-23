extends Node

signal image_loaded(texture, tile_coords)

var thread_pool = []
var active_requests = {}
var request_queue = []
var max_concurrent_requests = 3  # Adjust based on performance testing on target device

func _ready():
	for i in range(max_concurrent_requests):
		var thread = Thread.new()
		thread_pool.append(thread)

func queue_tile(tile_coords: Vector2):
	if active_requests.size() >= max_concurrent_requests:
		# If maximum concurrent requests are reached, queue additional requests
		request_queue.append(tile_coords)
		return
	# Directly initiate tile loading if under the limit
	_process_tile_request(tile_coords)

func _process_tile_request(tile_coords: Vector2):
	var url = "https://kryeit.com/images/tiles/17/%s_%s.png" % [tile_coords.x, tile_coords.y]
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_https_request_completed)
	http_request.request(url)

	active_requests[tile_coords] = http_request

func _https_request_completed(status: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):

	# TODO
	# I want to get the HTTPRequest that has been completed here, or the tile_coords
	if active_requests.has(tile_coords):
		var http_request_node = active_requests[tile_coords]
		http_request_node.queue_free()
		active_requests.erase(tile_coords)

	if status == OK and response_code == 200:
		var image = Image.new()
		if image.load_png_from_buffer(body) == OK:
			var texture = ImageTexture.create_from_image(image)
			emit_signal("image_loaded", texture, tile_coords)

	# Process next request in the queue if available
	if not request_queue.empty():
		var next_tile_coords = request_queue.pop_front()
		_process_tile_request(next_tile_coords)
