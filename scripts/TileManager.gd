# TileManager.gd
extends Node

var gridmap: GridMap
var loaded_tiles = {}
var tile_size = Vector3(10, 0.1, 10)
var render_distance = 3  # Adjust this as needed

func _ready():
	gridmap = $GridMap  # Assign your GridMap node path
	var tile_getter = $TileGetter  # Assign your TileGetter node path
	tile_getter.image_loaded.connect(self._on_image_downloaded)

# Checks if a tile is already loaded
func is_tile_loaded(tile_coords: Vector3) -> bool:
	return str(tile_coords) in loaded_tiles

# Requests TileGetter to load an image for the tile
func request_load_tile(tile_coords: Vector3):
	if not is_tile_loaded(tile_coords):
		var tile_getter = get_node("../TileManager/TileGetter")  # Correct path to your TileGetter node
		tile_getter.get_image(tile_coords)  # This function should exist in TileGetter and handle the request
		loaded_tiles[str(tile_coords)] = null  # Mark as pending

# Signal callback when TileGetter has downloaded an image
func _on_image_downloaded(tile_coords: Vector3, image: Image):
	var texture = ImageTexture.new()
	texture.create_from_image(image)
	apply_texture_to_tile(tile_coords, texture)

# Applies the downloaded texture to the tile
func apply_texture_to_tile(tile_coords: Vector3, texture: Texture):
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.translation = tile_coords * tile_size
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	mesh_instance.material_override = material
	add_child(mesh_instance)
	loaded_tiles[str(tile_coords)] = mesh_instance

# Update method to be called by PlayerManager
func update_tiles_around(center_tile: Vector3):
	var start_x = int(center_tile.x) - render_distance
	var end_x = int(center_tile.x) + render_distance
	var start_z = int(center_tile.z) - render_distance
	var end_z = int(center_tile.z) + render_distance
	
	for x in range(start_x, end_x + 1):
		for z in range(start_z, end_z + 1):
			var tile_coords = Vector3(x, 0, z)  # Assuming y is up and tiles are on xz-plane
			request_load_tile(tile_coords)

# Removes tiles that are outside the render distance
func unload_tiles_outside_render_distance(center_tile: Vector3):
	var tiles_to_unload = []
	for tile_key in loaded_tiles.keys():
		var tile_coords = loaded_tiles[tile_key].translation
		if tile_coords.distance_to(center_tile) > render_distance * tile_size.x:
			tiles_to_unload.append(tile_key)

	for tile_key in tiles_to_unload:
		var mesh_instance = loaded_tiles[tile_key]
		mesh_instance.queue_free()  # Free the mesh instance
		loaded_tiles.erase(tile_key)  # Remove from the dictionary
