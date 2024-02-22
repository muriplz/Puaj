extends HTTPRequest

# Define a signal that includes both the texture and the tile coordinates
signal image_loaded(texture, tile_coords)

func request_image(tile_coords: Vector2):
	
	
		# Ensure this HTTPRequest node is configured to not be in the tree multiple times.
	if is_inside_tree():
		queue_free()
		
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)
	set_meta("tile_coords", tile_coords)
	var url = "https://kryeit.com/images/tiles/15/%s_%s.png" % [tile_coords.x, tile_coords.y]
	
	var error = http_request.request(url)
	if error != OK:
		print("HTTPRequest error: %s" % [error])
	else:
		http_request.set_meta("tile_coords", tile_coords)
# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var tile_coords = get_meta("tile_coords")
	
	print("Request completed for tile_coords: ", tile_coords)
	
	if result != OK or response_code != 200:
		print("HTTP request failed. Result: ", result, ", Response code: ", response_code)
		return
	
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error == OK:
		var texture = ImageTexture.create_from_image(image)
		# Emit the signal with both texture and tile coordinates
		emit_signal("image_loaded", texture, tile_coords)
	else:
		push_error("Couldn't load the image: ")
