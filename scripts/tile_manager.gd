extends Node

# Reference to the TileGetter node
@onready var tile_getter = $TileGetter
# Dictionary to keep track of loaded tiles
var loaded_tiles = {}
var loaded_meshes = {}
var tile_size = Utils.tile_size  # Size in pixels

# Slot for the image_loaded signal
func _on_image_loaded(texture: Texture, tile_coords: Vector2):
	if not loaded_tiles.has(tile_coords):
		# Load the tile using TextureRect
		load_tile(tile_coords, texture)

func load_tile(tile_coords: Vector2, texture: Texture):
	if not loaded_meshes.has(tile_coords):
		var mesh_instance := create_mesh_instance_with_texture(texture, tile_coords)
		loaded_meshes[tile_coords] = mesh_instance
		loaded_tiles[tile_coords] = tile_coords


func unload_tile(tile_coords: Vector2):
	if loaded_tiles.has(tile_coords):
		unload_mesh(tile_coords)
		loaded_tiles.erase(tile_coords)

# Functionality to request a tile image based on its coordinates
func request_tile_image(tile_coords: Vector2):
	if not loaded_tiles.has(tile_coords):
		tile_getter.queue_tile(tile_coords)  # Assumes TileGetter has a request_image method

func render_chunks(tile_coords: Vector2):
	var render_distance = Utils.render_distance
	var tiles_to_keep = []

	# Calculate which tiles should be loaded
	for x in range(-render_distance, render_distance + 1):
		for z in range(-render_distance, render_distance + 1):
			var current_tile = tile_coords + Vector2(x, z)
			request_tile_image(current_tile)
			tiles_to_keep.append(current_tile)

	# Determine which tiles should be unloaded
	var loaded_tiles_keys = loaded_tiles.keys()  # Use keys() to iterate over tile coordinates
	for key in loaded_tiles_keys:
		if not tiles_to_keep.has(Vector2(key.x, key.y)):
			unload_tile(Vector2(key.x, key.y))

func create_mesh_instance_with_texture(texture: Texture, tile_coords: Vector2) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = tile_size
	
	var material := StandardMaterial3D.new()
	material.albedo_texture = texture
	mesh_instance.mesh = plane_mesh
	mesh_instance.material_override = material

	# Calculate the position to place the MeshInstance3D at the center of the grid cell
	var grid_position := Utils.tile_to_world(tile_coords.x, tile_coords.y)
	
	# Set the position using transform.origin in Godot 4.0 and later
	mesh_instance.transform.origin = grid_position
	

	# Add the MeshInstance3D to the scene
	add_child(mesh_instance)

	return mesh_instance

func unload_mesh(tile_coords: Vector2):
	if loaded_meshes.has(tile_coords):
		# Explicitly cast the retrieved value to MeshInstance3D
		var mesh_instance := loaded_meshes[tile_coords] as MeshInstance3D
		if mesh_instance:
			mesh_instance.queue_free() # Remove the mesh instance from the scene
			loaded_meshes.erase(tile_coords) # Remove the reference from the dictionary
			print("Mesh unloaded at: ", tile_coords)
		else:
			print("Failed to cast to MeshInstance3D or mesh_instance is null for key: ", tile_coords)
