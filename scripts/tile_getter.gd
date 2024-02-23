extends Node

signal image_loaded(texture, tile_coords)

var active_requests = {}
var max_concurrent_requests = 1

func queue_tile(tile_coords: Vector2):
	if active_requests.size() >= max_concurrent_requests:
		return
	var url = "https://kryeit.com/images/tiles/17/%s_%s.png" % [tile_coords.x, tile_coords.y]
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	http_request.request(url)
	set_meta("tile_coords", tile_coords)
	active_requests[tile_coords] = http_request

func _http_request_completed(status: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var tile_coords = get_meta("tile_coords")
	if active_requests.has(tile_coords):
		active_requests[tile_coords].queue_free()
		active_requests.erase(tile_coords)

	if status == OK and response_code == 200:
		var image = Image.new()
		if image.load_png_from_buffer(body) == OK:
			var texture = ImageTexture.create_from_image(image)
			emit_signal("image_loaded", texture, tile_coords)