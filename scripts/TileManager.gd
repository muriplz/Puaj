extends Node

var gridmap: GridMap
var render_distance = 10 # Number of tiles from the player to load
var tile_scale = Vector3(1, 1, 1) # Scale of the tiles
var loaded_tiles = {} # Dictionary to keep track of loaded tiles

func _ready():
	gridmap = $GridMap # Assign your GridMap node here

func update_tiles(player_lat_lon: Vector2):
	var player_tile_coords = Utils.latlon_to_tile(player_lat_lon.x, player_lat_lon.y)
	var tiles_to_load = get_tiles_to_load(player_tile_coords)
	load_tiles(tiles_to_load)
	unload_tiles_outside_distance(player_tile_coords)

func get_tiles_to_load(player_tile_coords: Vector2) -> Array:
	var tiles_to_load = []
	# Calculate which tiles to load based on render_distance
	# Populate tiles_to_load with the tile coordinates to load
	return tiles_to_load

func load_tiles(tiles_to_load: Array):
	for tile_coords in tiles_to_load:
		if not loaded_tiles.has(tile_coords):
			# Load the tile, create a MeshInstance with the tile texture
			# Set the tile's position based on tile_coords and tile_scale
			# Add the MeshInstance as a child of the GridMap
			# Add the tile_coords to loaded_tiles dictionary
			pass

func unload_tiles_outside_distance(player_tile_coords: Vector2):
	# Unload tiles that are outside the render_distance
	for tile_coords in loaded_tiles.keys():
		if tile_coords.distance_to(player_tile_coords) > render_distance:
			# Remove the MeshInstance from the GridMap
			# Remove the tile_coords from loaded_tiles dictionary
			pass

func set_tile_scale(new_scale: Vector3):
	tile_scale = new_scale
	# Optionally update the scale of already loaded tiles

# Player.gd or equivalent script
func move_player_to_lat_lon(lat: float, lon: float):
	var game_world_position = Utils.latlon_to_tile(lat, lon)
