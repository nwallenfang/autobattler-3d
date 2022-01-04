extends Spatial

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
	
	
	# prepare perspective shader material
	
	
	
func _process(delta: float) -> void:
	# TODO draw grid marker lines
	# TODO color selected square differently
	# both of these will probably be implemented with quads and shader magic
	pass

func get_grid_coordinates(position: Vector3) -> Vector2:
	# x == row_index, y == col_index
	print("total: ", total_dim)
	return Vector2(int(position.z / total_dim.x * number_of_rows) + 1, int(position.x / total_dim.y * number_of_cols) + 1)

func _on_ClickArea_input_event(camera: Node, event: InputEvent, position: Vector3, normal: Vector3, shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			print(position)
			print(get_grid_coordinates(position))


func perspective_to_orthogonal():
	# Give board a vertex shader that distorts it
	pass


func _on_Button_pressed() -> void:
	var grass_mat: ShaderMaterial = $Ground/GrassTexture.get_active_material(0)
	grass_mat.shader = GrassDisplacementShader
