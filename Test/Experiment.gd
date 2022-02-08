extends Spatial

onready var target = $Target
onready var fighter = $Fighter
onready var start_transform: Transform = Transform($Fighter.transform)

func _on_look_towards_pressed() -> void:
	# use look at while ignoring y coordinate
	var target_proj = Vector3(target.transform.origin.x, 
							  fighter.transform.origin.y, 
							  target.transform.origin.z)
	fighter.look_at(target_proj, Vector3.UP)
	
	yield(get_tree().create_timer(1.0), "timeout")
	tilt_towards_target()


func tilt_towards_target():
	# assuming that we're already looking at the target
	fighter.rotate_object_local(Vector3(1.0, 0.0, 0.0), deg2rad(-45))
	yield(get_tree().create_timer(0.5), "timeout")
	fighter.rotate_object_local(Vector3(1.0, 0.0, 0.0), deg2rad(+45))

func _on_reset_pressed() -> void:
	fighter.transform = start_transform
