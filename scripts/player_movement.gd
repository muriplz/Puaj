extends CharacterBody3D

@export var speed = 0.1

@onready var camera = $Camera3D

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
