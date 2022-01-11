extends Camera


var previous_camera: Camera

var velocity: float = 35.0
var angular_velocity: float = 50.0
var transitioning := false

signal transition_completed

func _ready() -> void:
	pass # Replace with function body.

# this function is called by the Tween
var target_transform: Transform
func interpolate_transform(weight: float):
	self.transform = self.transform.interpolate_with(target_transform, weight)
	
func transition_to_transform(target_transform_arg: Transform, target_fov: float):
	# maybe these two methods can be combined / are interchangable with the new
	# transform.interpolate_with call
	previous_camera = self.duplicate()
	self.target_transform = target_transform_arg
	var distance: float = transform.origin.distance_to(target_transform_arg.origin)
	print("DISTANCE: ", distance)
	var duration = distance / velocity
	print("DUR: ", duration)

	$Tween.reset_all()  
	$Tween.interpolate_method(self, "interpolate_transform", 0.0, 1.0, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	print("go from ", self.fov, " to ", target_fov)
	$Tween.interpolate_property(self, "fov", self.fov, target_fov, duration)
	$Tween.start()
	transitioning = true

func _on_Tween_tween_all_completed() -> void:
	emit_signal("transition_completed")
	
