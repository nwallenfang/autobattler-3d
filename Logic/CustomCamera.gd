extends Camera


var previous_camera: Camera

var velocity: float = 50.0
var angular_velocity: float = 50.0
var transitioning := false
var own_q: Quat
var target_q: Quat

signal transition_completed

func _ready() -> void:
	pass # Replace with function body.



# this function is called by the Tween
var target_transform: Transform
func interpolate_transform(weight: float):
	self.transform = self.transform.interpolate_with(target_transform, 2.0 * weight)


#func start_transition_rotate(target_transform: Transform):
#	previous_camera = self.duplicate()
#	var own_transform = self.transform
#	own_q = Quat(own_transform.basis)
#	target_q = Quat(target_transform.basis)
#	var duration = rad2deg(PI) / angular_velocity  
#	$Tween.interpolate_method(self, "interpolate_rotation", 0.0, 1.0, duration)
#	$Tween.start()
#	transitioning = true
	
	
func transition_to_transform(target_transform_arg: Transform):
	# maybe these two methods can be combined / are interchangable with the new
	# transform.interpolate_with call
	previous_camera = self.duplicate()
	self.target_transform = target_transform_arg
	var duration = transform.origin.distance_to(target_transform_arg.origin) / velocity
	print("c'est dur ça", duration)
	$Tween.reset_all()  
	$Tween.interpolate_method(self, "interpolate_transform", 0.0, 1.0, 1.2)
	$Tween.start()
	transitioning = true
		


func transition_back_from_transform():
	# check if previous camera is not None
	previous_camera.current = true
	# TODO

func _on_Tween_tween_all_completed() -> void:
	emit_signal("transition_completed")
	
