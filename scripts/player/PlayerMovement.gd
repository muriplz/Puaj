extends CharacterBody3D

@export var speed = 0.1

@onready var camera = $Camera3D

var tile_manager

signal request_tile_update(player_tile_coords)


func _physics_process(_delta):
	var direction = Vector3.ZERO

	# Use the camera's global orientation to determine forward and right vectors
	var forward = camera.global_transform.basis.z.normalized()
	var right = camera.global_transform.basis.x.normalized()

	if Input.is_action_pressed("forward"):
		direction -= forward  # Camera's forward vector is negative Z
	if Input.is_action_pressed("backwards"):
		direction += forward
	if Input.is_action_pressed("left"):
		direction -= right
	if Input.is_action_pressed("right"):
		direction += right

	direction.y = 0  # Ensure movement is horizontal
	direction = direction.normalized() * speed

	# Move the character
	move_and_collide(direction)
	
	
	update_tiles_around_player()
	# Update the tiles depending on render distance

func _ready():
	update_tiles_around_player()

func update_tiles_around_player():
	tile_manager = get_parent().get_node("TileManager")
	var tile_coords = Utils.world_to_tile(global_transform.origin)
	tile_manager.update_tiles_around(tile_coords)
		
	#tile_manager.update_tiles_around(player_tile_coords)
		

