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


# for vec2 parameters where x and y should be set to the same value
var grass_mat: ShaderMaterial
func shader_param_helper(value: float):
	grass_mat.set_shader_param("perspective_to_ortho", Vector2(value, value))

func _on_Button_pressed() -> void:
	# I tried to interpolate the perspective projection to orthogonal smoothly 
	# using a vertex shader
	# I stil think it's possible but it's too hard for now
	
	# so instead of doing that, just switch from perspective to orthogonal
	$CamPivot/Camera.projection = Camera.PROJECTION_ORTHOGONAL
#	grass_mat = $Ground/GrassTexture.get_active_material(0)
#	grass_mat.set_shader_param("perspective_to_ortho", 1.0)
#	grass_mat.shader = GrassDisplacementShader
#	$Tween.reset_all()
#	$Tween.interpolate_method(self, "shader_param_helper", 0.0, 1.0, 2.0)
#	$Tween.start()
