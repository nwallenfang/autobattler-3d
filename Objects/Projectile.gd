extends Spatial



func _on_Tween_tween_all_completed() -> void:
	queue_free()
