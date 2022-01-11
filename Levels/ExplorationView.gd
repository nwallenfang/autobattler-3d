extends Spatial


const BattleGrid = preload("res://Levels/BattleGrid.tscn")

func _ready():
	Game.player = $Player
	CameraManager.set_initial_current($Camera)
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
	# spawn a battle grid 
	var battle_grid: BattleGrid = BattleGrid.instance() 
	var ortho_cam: Camera = battle_grid.get_node("CamPivot/OrthoCamera")
	var pivot: Position3D = battle_grid.get_node("CamPivot")
	# but it will only be made visible once the camera movement is done
	
	# TODO disable player movement
	
	# target is the camera translated up
	var target_transform: Transform = $Camera.transform.translated(50 * Vector3.UP)
	target_transform.basis = battle_grid.get_node("CamPivot").transform.basis
	
	# TODO transition still needs to be fixed, interpolate is already done
	# when weight is like 0.5
	$Camera.transition_to_transform(target_transform, ortho_cam.fov)
	# add battle grid to scene
	battle_grid.translation = target_transform.origin
#	battle_grid.translation = $Camera.translation
	add_child(battle_grid)
	# translate current camera to the location of the orthogonal camera
	# (the camera in BattleGrid scene)
	var pivot_to_camera: Vector3 = ortho_cam.global_transform.origin - pivot.global_transform.origin
	var origin_to_pivot = pivot.transform.origin
	battle_grid.global_transform = battle_grid.global_transform.translated(-pivot_to_camera-origin_to_pivot)
	yield($Camera, "transition_completed")
	
	# TODO turn old light off
	CameraManager.transition_to(ortho_cam)
	
