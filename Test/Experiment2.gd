extends Spatial



func _on_rotate_x_pressed() -> void:
	$Cube.rotate_x(deg2rad(45))


func _on_rotate_y_pressed() -> void:
	$Cube.rotate_y(deg2rad(45))


func _on_rotate_z_pressed() -> void:
	$Cube.rotate_z(deg2rad(45))


func _on_rotate_xl_pressed() -> void:
	$Cube.rotate_object_local(Vector3(1, 0, 0), deg2rad(45))


func _on_rotate_yl_pressed() -> void:
	$Cube.rotate_object_local(Vector3(0, 1, 0), deg2rad(45))


func _on_rotate_zl_pressed() -> void:
	$Cube.rotate_object_local(Vector3(0, 0, 1), deg2rad(45))


func _on_rotate_xl2_pressed() -> void:
	$Cube.rotate_object_local(Vector3(1, 0, 0), deg2rad(-45))
