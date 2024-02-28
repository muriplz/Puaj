extends Button

# Reference to the panel container
var hall

func _ready():
	# Find the Hall panel container node
	hall = get_node("../Hall")
	hall.visible = false
	# Connect the button's "pressed" signal to the _on_BurguerOpener_pressed() method
	connect("pressed", Callable(self, "_on_BurguerOpener_pressed"))

func _on_BurguerOpener_pressed():

	# Toggle visibility: Hide the Button, show the Hall
	self.visible = false
	hall.visible = true

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var click_pos = hall.get_local_mouse_position()
		
		# Check if the click is outside the Hall
		if not hall.get_rect().has_point(click_pos):
			# If the Hall is visible and the click is outside, toggle the visibility
			if hall.visible:
				hall.visible = false
				self.visible = true

		# Ensure the input doesn't propagate further if it's handled
