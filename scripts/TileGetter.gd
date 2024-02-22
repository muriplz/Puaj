extends HTTPRequest

# Signal to indicate an image has been loaded successfully
signal image_loaded(tile_coords, image)

func get_image(tile_coords: Vector3):
	var url = "https://kryeit.com/images/tiles/15/%s_%s.png" % [tile_coords.x, tile_coords.z]
	var error = request(url)
	if error == OK:
		set_meta("tile_coords", tile_coords)
	else:
		print("Error")

func _on_request_completed(result, response_code, headers, body):
	var tile_coords = get_meta("tile_coords")
	if result == RESULT_SUCCESS and response_code == 200:
		var image = Image.new()
		if image.load_png_from_buffer(body) == OK:
			# Image successfully loaded, emit signal with the image
			emit_signal("image_loaded", tile_coords, image)
		else:
			print("Failed to load image from buffer.")
	else:
		print("HTTPRequest failed with response code: %d" % response_code)
