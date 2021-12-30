extends Spatial


const BattleGrid = preload("res://Levels/BattleGrid.tscn")

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

func _process(_delta: float) -> void:
	# move camera according to player
	# TODO maybe do something similar to the snap in 2D
	$Camera.translation.x = $Player.translation.x

func _on_CollectDetection_body_entered(_body: Node) -> void:
	# first combat level
	$Collectibles/FunkySphere.queue_free()
	transition_to_combat()
	
	
func transition_to_combat():
	var old_target_transform = $Camera.transform.rotated($Camera.transform.basis.y, PI)
	var target_transform = $Camera.transform.translated(50 * Vector3.UP)
	$Camera.start_transition_translate(target_transform)
	
	
	yield($Camera, "transition_completed")
	# spawn a battle grid at the target transform
	print("pantantan")
	var battle_grid = BattleGrid.instance()
	add_child(battle_grid)
	battle_grid.transform = target_transform.translated(Vector3.FORWARD * 10)

	# move along curve 3d
	# move combat view to location
	# alpha blend combat view
	pass
