extends Node

func _ready():

	var player = $Player
	playe

func _on_player_request_tile_update(player_tile_coords):
	var tile_manager = $TileManager
	tile_manager.update_tiles_around(player_tile_coords)
