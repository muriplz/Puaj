# Level.gd
extends Node3D

@onready var player = $Player

func _ready():
	player.player_moved.connect(Callable(self, "_on_player_move"))

func _on_player_move(player_position):
	pass

