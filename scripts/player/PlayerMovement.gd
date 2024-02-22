extends CharacterBody3D

@export var speed = 0.1

@onready var camera = $Camera3D

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
	
	# Update the tiles depending on render distance
	update_tiles()

func update_tiles():
	var player_position = global_transform.origin
	var player_tile_coords = Utils.world_to_tile(player_position)
	emit_signal("request_tile_update", player_tile_coords)
	
