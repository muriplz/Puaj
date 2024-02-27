# Level.gd
extends Node3D

# Assuming the player node is a direct child of the level and named "Player"
func _ready():
	var player = get_node("Player")
	if player:
		player.player_moved.connect(Callable(self, "_on_player_move"))
	else:
		print("Player node not found.")

func _on_player_move(player_position):
	pass
	# Additional logic to be executed when the player moves.
