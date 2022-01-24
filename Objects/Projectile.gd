extends Spatial


signal projectile_has_hit

func move_projectile(_from: Vector3, _to: Vector3):
	pass

func _on_Tween_tween_all_completed() -> void:
	emit_signal("projectile_has_hit")
	# trigger hit particles
	$MeshInstance.visible = false
	$Particles.restart()
	yield(get_tree().create_timer($Particles.lifetime), "timeout")
	queue_free()
