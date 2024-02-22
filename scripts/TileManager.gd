extends Node

var gridmap: GridMap
var loaded_tiles = {}
var tile_size = Vector3(10, 0.1, 10)  # Adjust this as needed
var render_distance = 3  # Adjust this as needed

func _ready():
	gridmap = get_parent().get_node("GridMap")  # Make sure this is the correct path to your GridMap node
	var tile_getter = get_node("TileGetter")  # Make sure this is the correct path to your TileGetter node
	tile_getter.image_loaded.connect(self._on_image_downloaded)
	print("TileManager is ready and connected to TileGetter.")

func is_tile_loaded(tile_coords: Vector3) -> bool:
	return str(tile_coords) in loaded_tiles

func request_load_tile(tile_coords: Vector3):
	if not is_tile_loaded(tile_coords):
		print("Requesting tile at: %s" % [tile_coords])
		var tile_getter = get_node("TileGetter")
		tile_getter.get_image(tile_coords)
		loaded_tiles[str(tile_coords)] = null

func _on_image_downloaded(tile_coords: Vector3, image: Image):
	print("Image downloaded for tile coordinates: %s" % [tile_coords])
	var texture = ImageTexture.create_from_image(image)
	apply_texture_to_tile(tile_coords, texture)

func apply_texture_to_tile(tile_coords: Vector3, texture: Texture):
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.translation = tile_coords * tile_size
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	mesh_instance.material_override = material
	add_child(mesh_instance)
	loaded_tiles[str(tile_coords)] = mesh_instance
	print("Created mesh instance for tile coordinates: %s" % [tile_coords])

func update_tiles_around(center_tile: Vector3):
	print("Updating tiles around center: %s" % [center_tile])
	var start_x = int(center_tile.x) - render_distance
	var end_x = int(center_tile.x) + render_distance
	var start_z = int(center_tile.z) - render_distance
	var end_z = int(center_tile.z) + render_distance

	for x in range(start_x, end_x + 1):
		for z in range(start_z, end_z + 1):
			var tile_coords = Vector3(x, 0, z)
			request_load_tile(tile_coords)

func unload_tiles_outside_render_distance(center_tile: Vector3):
	print("Unloading tiles outside render distance from center: %s" % [center_tile])
	var tiles_to_unload = []
	for tile_key in loaded_tiles.keys():
		var mesh_instance = loaded_tiles[tile_key]
		if mesh_instance != null:
			var tile_coords = mesh_instance.translation
			if tile_coords.distance_to(center_tile * tile_size) > render_distance * tile_size.x:
				tiles_to_unload.append(tile_key)

	for tile_key in tiles_to_unload:
		var mesh_instance = loaded_tiles[tile_key]
		mesh_instance.queue_free()
		loaded_tiles.erase(tile_key)
		print("Unloaded tile at coordinates: %s" % [tile_key])
