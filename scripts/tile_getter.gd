extends HTTPRequest

# Signal emitted when an image is successfully loaded
# Passes the image texture along with the tile coordinates
signal image_loaded(texture, tile_coords)

# Dictionary to track ongoing requests
var ongoing_requests := {}

func request_image(tile_coords: Vector2):
	var key := str(tile_coords)
	# Check if a request for these coordinates is already ongoing
	if key in ongoing_requests:
		return

	var url := "https://kryeit.com/images/tiles/15/%s_%s.png" % [tile_coords.x, tile_coords.y]

	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	set_meta("tile_coords", tile_coords)  # Store tile_coords for later retrieval
	
	var error := http_request.request(url)
	if error != OK:
		print("HTTPRequest error: ", error)
	else:
		print("Request made for tile: ", tile_coords)
		ongoing_requests[key] = true  # Mark this tile as having an ongoing request

# Callback when the HTTP request is completed
func _http_request_completed(status: int, response_code: int, headers: PackedStringArray, body: PackedByteArray):
	var tile_coords := get_meta("tile_coords") as Vector2
	var key := str(tile_coords)
	
	print("Request completed for tile: ", tile_coords)

	if status == OK and response_code == 200:
		var image := Image.new()
		var error := image.load_png_from_buffer(body)
		if error == OK:
			var texture := ImageTexture.create_from_image(image)
			
			emit_signal("image_loaded", texture, tile_coords)
			print("Image loaded for tile: ", tile_coords)
		else:
			print("Failed to load image from buffer.")
	else:
		print("HTTPRequest failed with response code: ", response_code)
	
	# Remove from ongoing_requests regardless of success or failure
	ongoing_requests.erase(key)
