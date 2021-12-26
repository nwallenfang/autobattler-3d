extends Spatial


func _ready():
	Game.player = $Player
	camera_to_player = $Player.transform.origin.direction_to($Camera.transform.origin)

const ZOOM_SPEED = 3.5
var camera_to_player: Vector3
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == BUTTON_WHEEL_UP:
				$Camera.translate(-ZOOM_SPEED * camera_to_player)
			# zoom out
			if event.button_index == BUTTON_WHEEL_DOWN:
				$Camera.translate(ZOOM_SPEED * camera_to_player)

func _process(delta: float) -> void:
	# move camera according to player
	# TODO maybe do something similar to the snap in 2D
	$Camera.translation.x = $Player.translation.x

func _on_CollectDetection_body_entered(body: Node) -> void:
	# first combat level
	$FunkySphere.queue_free()
	transition_to_combat()
	
	
func transition_to_combat():
	# duplicate camera
	$Camera.transition_to_combat()	
	# I want to smoothly interpolate between
	

	# make duplicate current
	# move along curve 3d
	# move combat view to location
	# alpha blend combat view
	pass
