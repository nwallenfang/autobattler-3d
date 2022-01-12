extends Spatial
class_name BattleGrid

# with (0, 0) being top-left
export var number_of_rows = 8  # z in 3D
export var number_of_cols = 8  # x in 3D

# total dimensions of the grid
onready var total_dim: Vector2

const GrassDisplacementShader = preload("res://Shaders/GrassDisplacement.tres")

func _ready() -> void:
	var grass_mesh = $Ground/GrassTexture.mesh
	var aabb_size = grass_mesh.get_aabb().size
	total_dim = Vector2(aabb_size.z, aabb_size.x)
	
	
func _process(_delta: float) -> void:
	# TODO color selected square differently
	# will probably be implemented with quads and shader magic
	pass

func get_grid_coordinates(position: Vector3) -> Vector2:
	# x == row_index, y == col_index
	print("total: ", total_dim)
	return Vector2(int(position.z / total_dim.x * number_of_rows) + 1, int(position.x / total_dim.y * number_of_cols) + 1)

func _on_ClickArea_input_event(_camera: Node, event: InputEvent, position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print(position)
			print(get_grid_coordinates(position))



#	if $CamPivot/OrthoCamera.projection == Camera.PROJECTION_PERSPECTIVE:
#		$CamPivot/OrthoCamera.projection = Camera.PROJECTION_ORTHOGONAL
#	else:
#		$CamPivot/OrthoCamera.projection = Camera.PROJECTION_PERSPECTIVE


func _on_Button_pressed() -> void:
	# go back (if there is somewhere to go back)
	# cant use type because of cyclic dependencies lol
#	if get_parent().name == 'ExplorationView':
	get_parent().transition_to_exploration()
