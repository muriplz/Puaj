extends Node

func _ready():
	var player_scene = preload("res://scenes/player.tscn")
	var player = player_scene.instantiate()
	add_child(player)
	var tile_manager = $TileManager
	player.set_tile_manager(tile_manager)
