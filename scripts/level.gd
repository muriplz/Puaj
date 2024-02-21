extends Node3D

var closestCity: String = ""
var trash_cans = []  # Array to store references to trash can objects

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Function to add a trash can to the list
func add_trash_can(trash_can):
	trash_cans.append(trash_can)

# Function to remove a trash can from the list
func remove_trash_can(trash_can):
	trash_cans.erase(trash_cans.find(trash_can))
	
func get_closest_city() -> String:
	return closestCity

func set_closest_city(city: String) -> void:
	closestCity = city
