extends Spatial
class_name BattleGrid

# with (0, 0) being top-left
export var number_of_rows = 8  # z in 3D
export var number_of_cols = 8 # x in 3D

# total dimensions of the grid
onready var total_dim: Vector2
onready var grass_aabb: AABB
# top_left_corner of the ground
onready var ground_top_left: Vector3
onready	var grass_mesh = $Ground/GrassTexture.mesh

const GrassDisplacementShader = preload("res://Shaders/GrassDisplacement.tres")

func _ready() -> void:

	
	grass_aabb = $Ground/GrassTexture.get_aabb()
	
	total_dim = Vector2(grass_aabb.size.z, grass_aabb.size.x)
	ground_top_left = grass_aabb.position - grass_aabb.size/2
	
	
func _process(_delta: float) -> void:
	# TODO color selected square differently
	# will probably be implemented with quads and shader magic
	pass

func get_grid_coordinates(position: Vector3) -> Vector2:
	# x == row_index, y == col_index
	return Vector2(int(position.z / total_dim.x * number_of_rows) + 1, int(position.x / total_dim.y * number_of_cols) + 1)

func _on_ClickArea_input_event(_camera: Node, event: InputEvent, position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var mouse_position_local = to_local(position)
			$Gizmo.transform.origin = mouse_position_local
#			"working": $Gizmo.transform.origin = grass_aabb.position + mouse_position_local
#			$Gizmo.global_transform.origin = mouse_position_local + grass_aabb.position
			
			print(get_grid_coordinates(mouse_position_local))

func _on_Button_pressed() -> void:
	# go back (if there is somewhere to go back)
	# cant use type because of cyclic dependencies lol
	if get_parent().name == 'ExplorationView':
		get_parent().transition_to_exploration()
