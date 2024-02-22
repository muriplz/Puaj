extends Node

var gridmap: GridMap
var player: CharacterBody3D # Reference to your player node
var tile_size = Vector3(10, 0.1, 10) # Size of each tile
var render_distance = 3 # Number of tiles from the player to load in each direction

func _ready():
	gridmap = $GridMap # Assign your GridMap node here
	player = $Player # Assign your player node here

func _process(delta):
	update_tiles()

func update_tiles():
	var player_tile = world_to_tile(player.translation)
	for x in range(-render_distance, render_distance + 1):
		for z in range(-render_distance, render_distance + 1):
			var current_tile = player_tile + Vector3(x, 0, z)
			load_tile(current_tile)

func world_to_tile(world_position: Vector3) -> Vector3:
	# Convert the world position to tile grid coordinates
	var tile_x = int(world_position.x / tile_size.x)
	var tile_z = int(world_position.z / tile_size.z)
	return Vector3(tile_x, 0, tile_z)

func load_tile(tile_coords: Vector3):
	# Check if the tile is already loaded
	if gridmap.get_cell_item(tile_coords) == -1:
		var tile_index = 0 # Assuming your mesh library has a single mesh
		gridmap.set_cell_item(tile_coords, tile_index, -1) # -1 clears the cell
		var tile_path = get_tile_path_from_coords(tile_coords)
		var texture = ResourceLoader.load(tile_path) # Load the tile texture
		var material = StandardMaterial3D.new()
		material.albedo_texture = texture
		# Assuming you have a way to assign this material to the GridMap's material or shader

func get_tile_path_from_coords(tile_coords: Vector3) -> String:
	# Construct the URL path to the tile texture based on its coordinates
	var tile_x = int(tile_coords.x)
	var tile_z = int(tile_coords.z)
	return "https://kryeit.com/images/tiles/15/%s_%s.png" % [tile_x, tile_z]
