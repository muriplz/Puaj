extends Node

var gridmap: GridMap
var loaded_tiles = {}
var tile_size = Vector2(10, 10)  # Adjust this as needed
var render_distance = 2  # Adjust this as needed
var tile_getter

func _ready():
	gridmap = get_parent().get_node("GridMap")
	tile_getter = get_node("TileGetter")
	print(gridmap)
	print("TileManager is ready and connected to TileGetter.")

func is_tile_loaded(tile_coords: Vector2) -> bool:
	return str(tile_coords) in loaded_tiles

func request_load_tile(tile_coords: Vector2):
	if not is_tile_loaded(tile_coords):
		print("Requesting tile at: %s" % [tile_coords])
		tile_getter.request_image(tile_coords)
		loaded_tiles[str(tile_coords)] = null

func apply_texture_to_tile(tile_coords: Vector2, texture: Texture):
	var mesh_instance = MeshInstance3D.new()
	mesh_instance.translation = tile_size
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	mesh_instance.material_override = material
	add_child(mesh_instance)
	loaded_tiles[str(tile_coords)] = mesh_instance
	print("Created mesh instance for tile coordinates: %s" % [tile_coords])

func create_mesh_for_tile(tile_coords: Vector2) -> MeshInstance3D:
	var mesh_instance = MeshInstance3D.new()
	# Convert Vector2 tile_coords to Vector3 for positioning, assuming y=0 for the height
	var position = Vector3(tile_size.x, 0, tile_size.y)
	mesh_instance.transform.origin = position
	add_child(mesh_instance)
	print("Created mesh instance for tile coordinates: %s" % tile_coords)
	return mesh_instance


func apply_texture_to_mesh(mesh_instance: MeshInstance3D, texture: Texture):
	var material = StandardMaterial3D.new()
	material.albedo_texture = texture
	mesh_instance.material_override = material
	print("Applied texture to mesh")

func update_tiles_around(center_tile: Vector2):
	var start_x = int(center_tile.x) - render_distance
	var end_x = int(center_tile.x) + render_distance
	var start_z = int(center_tile.y) - render_distance
	var end_z = int(center_tile.y) + render_distance

	for x in range(start_x, end_x + 1):
		for z in range(start_z, end_z + 1):
			var tile_coords = Vector2(x, z)
			request_load_tile(tile_coords)

func unload_tiles_outside_render_distance(center_tile: Vector2):
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
