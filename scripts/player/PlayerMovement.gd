extends CharacterBody3D

@export var speed = 0.5

@onready var camera = $Camera3D

@onready var tile_manager = get_parent().get_node("TileManager")

signal player_moved

func _ready():
	pass

func _physics_process(_delta):
	var direction = Vector3.ZERO

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
	
	emit_signal("player_moved", global_transform.origin)

	direction.y = 0
	direction = direction.normalized() * speed

	move_and_collide(direction)
	update_tiles_around_player()

func update_tiles_around_player():
	var tile_coords = Utils.world_to_tile(global_transform.origin)
	tile_manager.render_chunks(tile_coords)

