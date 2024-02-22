extends HTTPRequest

# Signal to indicate an image has been loaded successfully
signal image_loaded(tile_coords, image)

func get_image(tile_coords: Vector3):
	print("TileGetter: Requesting image for tile coordinates: %s" % [tile_coords])
	var url = "https://kryeit.com/images/tiles/15/%s_%s.png" % [tile_coords.x, tile_coords.z]
	print("TileGetter: Requesting URL: %s" % url)
	var error = request(url)
	if error == OK:
		set_meta("tile_coords", tile_coords)
		print("TileGetter: Request sent successfully.")
	else:
		print("TileGetter: Error initiating request: %s")

func _on_request_completed(result, response_code, body):
	print("TileGetter: Request completed with response code: %d" % response_code)
	if result != RESULT_SUCCESS:
		print("TileGetter: Request failed with result: %s" % result)
		return
	if response_code != 200:
		print("TileGetter: HTTP request failed with response code: %d" % response_code)
		return
	
	var tile_coords = get_meta("tile_coords")
	print("TileGetter: Processing image buffer for tile coordinates: %s" % [tile_coords])
	var image = Image.new()
	var error = image.load_png_from_buffer(body)
	if error == OK:
		emit_signal("image_loaded", tile_coords, image)
		print("TileGetter: Image loaded and signal emitted for tile coordinates: %s" % [tile_coords])
	else:
		print("TileGetter: Failed to load image from buffer. Error: %s")
