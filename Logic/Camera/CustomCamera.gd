extends Camera

var velocity: float = 33.0
var angular_velocity: float = 50.0
var transitioning := false

signal transition_completed

# this function is called by the Tween
var start_transform: Transform
var target_transform: Transform
func interpolate_transform(weight: float):
	self.transform = start_transform.interpolate_with(target_transform, weight)
	
func move_to_transform(target_transform_arg: Transform, target_fov: float):
	# maybe these two methods can be combined / are interchangable with the new
	# transform.interpolate_with call
	self.target_transform = target_transform_arg
	# back up current transform as starting point for interpolation
	self.start_transform = Transform(transform)
	
	var distance: float = transform.origin.distance_to(target_transform_arg.origin)
	var duration = distance / velocity

	$Tween.reset_all()  
	$Tween.interpolate_method(self, "interpolate_transform", 0.0, 1.0, duration, Tween.TRANS_LINEAR)
	$Tween.interpolate_property(self, "fov", self.fov, target_fov, duration)
	$Tween.start()

func _on_Tween_tween_all_completed() -> void:
	emit_signal("transition_completed")
	
