extends Node

# handle multiple cameras to easily return to previous


var camera_stack: Array
var current: Camera

func set_initial_current(cam: Camera):
	self.current = cam

func transition_to(cam: Camera):
	current.current = false
	camera_stack.push_back(current)
	current = cam
	current.current = true
	
func transition_back():
	current.current = false
	current = camera_stack.pop_back()
	current.current = true
