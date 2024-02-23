extends Node

# Reference to the TileGetter node
@onready var tile_getter = $TileGetter
# Dictionary to keep track of loaded tiles
var loaded_tiles = {}
var loaded_meshes = {}
var tile_size = Vector2(10, 10)  # Size in pixels

func _ready():
	# Connect to the TileGetter's image_loaded signal
	tile_getter.image_loaded.connect(Callable(self, "_on_image_loaded"))

# Slot for the image_loaded signal
func _on_image_loaded(texture: Texture, tile_coords: Vector2):
	print("WAHOO")
	if not loaded_tiles.has(tile_coords):
		# Load the tile using TextureRect
		load_tile(tile_coords, texture)

func load_tile(tile_coords: Vector2, texture: Texture):
	var key := str(tile_coords)
	if not loaded_meshes.has(key):
		var mesh_instance := create_mesh_instance_with_texture(texture, tile_coords)
		# Store the mesh instance using tile coordinates as the key
		loaded_meshes[key] = mesh_instance
		print("Mesh loaded at: ", tile_coords)
		# Store the reference to the TextureRect for possible future use
		loaded_tiles[tile_coords] = tile_coords
		print("Tile loaded at: ", tile_coords)

func unload_tile(tile_coords: Vector2):
	if loaded_tiles.has(tile_coords):
		pass

# Functionality to request a tile image based on its coordinates
func request_tile_image(tile_coords: Vector2):
	if not loaded_tiles.has(tile_coords):
		tile_getter.request_image(tile_coords)  # Assumes TileGetter has a request_image method

func create_mesh_instance_with_texture(texture: Texture, tile_coords: Vector2) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var plane_mesh := PlaneMesh.new()
	plane_mesh.size = tile_size # Size of the plane, adjust as needed

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
	var key := str(tile_coords)
	if loaded_meshes.has(key):
		# Explicitly cast the retrieved value to MeshInstance3D
		var mesh_instance := loaded_meshes[key] as MeshInstance3D
		if mesh_instance:
			mesh_instance.queue_free() # Remove the mesh instance from the scene
			loaded_meshes.erase(key) # Remove the reference from the dictionary
			print("Mesh unloaded at: ", tile_coords)
		else:
			print("Failed to cast to MeshInstance3D or mesh_instance is null for key: ", key)
