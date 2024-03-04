extends Button

# Reference to the panel container
@onready var ui = $"../UI"

func _ready():
	# Find the Hall panel container node
	ui.visible = false
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed():
	ui.visible = !ui.visible
