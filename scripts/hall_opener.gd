extends Button

# Reference to the panel container
var hall

func _ready():
	# Find the Hall panel container node
	hall = get_node("../Hall")

	# Connect the button's "pressed" signal to the _on_BurguerOpener_pressed() method
	connect("pressed", Callable(self, "_on_BurguerOpener_pressed"))

func _on_BurguerOpener_pressed():
	# Toggle the visibility of the Hall panel container
	hall.visible = not hall.visible
