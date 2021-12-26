extends Spatial

var speed = 10.8;


onready var clouds: Array = get_children()
onready var Cloud = preload("res://Environment/Cloud.tscn")

func _process(delta) -> void:
	# TODO move the clouds every frame
	# teleport the clouds once they're far outside of the view
	# (maybe blend them out before that)
	# 
	for child in clouds:
		var cloud = child as Spatial
		cloud.translate(delta * speed * Vector3.RIGHT)
		


