extends Camera


var previous_camera: Camera


var angular_velocity: float = 50.0
var transitioning := false
var own_q: Quat
var target_q: Quat

func _ready() -> void:
	pass # Replace with function body.


# this function is called by the Tween :)
func interpolate_rotation(weight: float):
	# weight from 0 to 1 I think
	var q_out = own_q.slerp(target_q, weight) 
	self.transform.basis = Basis(q_out)


func transition_to_combat():
	previous_camera = self.duplicate()
	var own_transform = self.transform
	# ? is this right?
	var target_transform = own_transform.rotated(own_transform.basis.y, PI)
	own_q = Quat(own_transform.basis)
	target_q = Quat(target_transform.basis)
	var duration = rad2deg(PI) / angular_velocity  
	$Tween.interpolate_method(self, "interpolate_rotation", 0.0, 1.0, duration)
	$Tween.start()
	transitioning = true
	
	
	
func _process(delta: float) -> void:
	pass
