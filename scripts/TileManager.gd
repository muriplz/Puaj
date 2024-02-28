extends Node

@onready var tile_getter = $TileGetter

var tile_size = Utils.tile_size

func unload_tile(tile_coords: Vector2):
	if Utils.loaded_tiles.has(tile_coords):
		unload_mesh(tile_coords)
		Utils.loaded_tiles.erase(tile_coords)

# Functionality to request a tile image based on its coordinates
func request_tile_image(tile_coords: Vector2):
	if not Utils.loaded_tiles.has(tile_coords):
		tile_getter.queue_tile(tile_coords)

func render_chunks(tile_coords: Vector2):
	var render_distance = Utils.render_distance
	var tiles_to_keep = []

	for offset in range(render_distance + 1):
		for y in range(-offset, offset + 1):
			for x in range(-offset, offset + 1):
				if x * x + y * y <= render_distance * render_distance:
					var current_tile = tile_coords + Vector2(x, y)
					if not tiles_to_keep.has(current_tile):
						request_tile_image(current_tile)
						tiles_to_keep.append(current_tile)

	var loaded_tiles_keys = Utils.loaded_tiles.keys()
	for key in loaded_tiles_keys:
		if not tiles_to_keep.has(Vector2(key.x, key.y)):
			unload_tile(Vector2(key.x, key.y))

func unload_mesh(tile_coords: Vector2):
	var key := str(tile_coords)
	if Utils.loaded_meshes.has(key):

		var mesh_instance := Utils.loaded_meshes[key] as MeshInstance3D
		if mesh_instance:
			mesh_instance.queue_free() # Remove the mesh instance from the scene
			Utils.loaded_meshes.erase(key) # Remove the reference from the dictionary


func _on_mesh_ready_to_add(mesh_instance):
	add_child(mesh_instance)
