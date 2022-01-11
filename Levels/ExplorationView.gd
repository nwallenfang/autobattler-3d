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
	var target_transform = $Camera.transform.translated(50 * Vector3.UP)
	# TODO transition still needs to be fixed, interpolate is already done
	# when weight is like 0.5
	$Camera.start_transition_translate(target_transform)
	yield($Camera, "transition_completed")
	# spawn a battle grid 
	var battle_grid = BattleGrid.instance()
	battle_grid.translation = $Camera.translation
	add_child(battle_grid)
	# translate current camera to the location of the orthogonal camera
	# (the camera in BattleGrid scene)
	var pivot_to_camera: Vector3 = battle_grid.get_node("CamPivot/Camera").global_transform.origin - battle_grid.get_node("CamPivot").global_transform.origin
	var origin_to_pivot = battle_grid.get_node("CamPivot").transform.origin
	# TODO rotate current camera to rotation of orthogonal camera
	# TODO I'd like to interpolate smoothly between the perspective and the orthogonal view
	# don't know if it's feasible
	battle_grid.transform = battle_grid.transform.translated(-pivot_to_camera-origin_to_pivot)
