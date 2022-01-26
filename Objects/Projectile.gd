extends Spatial

var target_fighter

signal projectile_has_hit

func _on_Tween_tween_all_completed() -> void:
	emit_signal("projectile_has_hit", target_fighter)
	# trigger hit particles
	$MeshInstance.visible = false
	$Particles.restart()
	yield(get_tree().create_timer($Particles.lifetime), "timeout")
	queue_free()
