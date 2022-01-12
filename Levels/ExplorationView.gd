extends Spatial
class_name ExplorationView

const ZOOM_SPEED = 3.5
const BattleGrid = preload("res://Levels/BattleGrid.tscn")
const battle_grid_cam_translation: Vector3 = 50 * Vector3.UP

func _ready():
	Game.player = $Player
	CameraManager.set_initial_current($Camera)
	camera_to_player = $Player.transform.origin.direction_to($Camera.transform.origin)


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
	transition_to_battlegrid()
	

var last_camera_position: Transform 
var last_fov: float
func transition_to_battlegrid():
	# spawn a battle grid 
	last_camera_position = Transform($Camera.global_transform)
	last_fov = ($Camera as Camera).fov
	var battle_grid: BattleGrid = BattleGrid.instance() as BattleGrid
	var ortho_cam: Camera = battle_grid.get_node("CamPivot/OrthoCamera") as Camera
	var pivot: Position3D = battle_grid.get_node("CamPivot") as Position3D
	# but it will only be made visible once the camera movement is done
	
	Game.player.CONTROLS_ENABLED = false
	
	# target is the camera translated up
	var target_transform: Transform = $Camera.transform.translated(battle_grid_cam_translation)
	target_transform.basis = battle_grid.get_node("CamPivot").transform.basis
	
	$Camera.transition_to_transform(target_transform, ortho_cam.fov)
	# add battle grid to scene
	battle_grid.translation = target_transform.origin
	add_child(battle_grid)
	# translate current camera to the location of the orthogonal camera
	# (the camera in BattleGrid scene)
	var pivot_to_camera: Vector3 = ortho_cam.global_transform.origin - pivot.global_transform.origin
	var origin_to_pivot = pivot.transform.origin
	battle_grid.global_transform = battle_grid.global_transform.translated(-pivot_to_camera-origin_to_pivot)
	yield($Camera, "transition_completed")
	yield(get_tree().create_timer(1.0), "timeout")
	# TODO turn old light off
	
	CameraManager.transition_to(ortho_cam)

# idea: let's imagine if there were far more than these 2 "views"
# with different kind of transitions
# in that case it would make sense to introduce another "manager" that contains the transition methods

func transition_to_exploration():
	# deconstruct BattleGrid node
	# just a free() for now but maybe use dissolve shader or something else entirely
	
	var battle_grid := $BattleGrid
	battle_grid.queue_free()
	CameraManager.transition_back()
	$Camera.transition_to_transform(last_camera_position, last_fov)
	
	
	# activate movement again
	Game.player.CONTROLS_ENABLED = true
