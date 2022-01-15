extends Spatial
class_name BattleGrid

# with (0, 0) being top-left
onready var number_of_rows # z in 3D
onready var number_of_cols # x in 3D

# total dimensions of the grid, indexed (row,col) like a true mathematician
onready var total_dim: Vector2
# dimensions of a single cell of the grid, indexed (row,col) (== (z, x) in world-space)
onready var cell_dim: Vector2
onready	var grass_mesh = $Board/GrassTexture.mesh
onready var grid_material: ShaderMaterial = $Board/GridQuad.get_active_material(0) as ShaderMaterial

const FighterScene: PackedScene = preload("res://Logic/Combat/Fighter.tscn")
const GizmoScene: PackedScene = preload("res://UI/Gizmo.tscn")
const test_level: LevelResource = preload("res://Resources/Level1.tres")


func _ready() -> void:
	# total dim works under the premise that no scaling shenanigans are going on after
	# the board has been initialized
	var grass_aabb = $Board/GrassTexture.get_aabb()
	total_dim = Vector2(grass_aabb.size.z, grass_aabb.size.x)
	# load test level, can be overridden when picking up a CombatOrb
	load_level(test_level)
	

func set_dimensions(rows: int, cols: int) -> void:
	number_of_rows = rows
	number_of_cols = cols
	
	grid_material.set_shader_param("rows", number_of_rows)
	grid_material.set_shader_param("columns", number_of_cols)
	
	cell_dim = Vector2(total_dim.x/number_of_rows, total_dim.y/number_of_cols)
	

func load_level(level: LevelResource):
	set_dimensions(level.number_of_rows, level.number_of_columns)
	
	for fighter_resource in level.enemy_fighters:
		# type-cast to our custom resource
		fighter_resource = fighter_resource as FighterResource

		if fighter_resource == null:
			# fighter resource has wrong type
			print("error creating fighter, fighter resource has wrong type")
			return
		# create a new fighter node
		var fighter: Fighter = FighterScene.instance()
		$Board.add_child(fighter)
		# pipe resource data into Fighter instance
		fighter.init(fighter_resource)
		
		# TODO scale fighter to fit cell exactly or like 80% of cell's size
		
		# with x being the column and z being the row
		# (and with the column being the y coordinate of our Vector2)
		# (it's confusing I know)
		# move to center of cell
		var position := Vector3(
							(fighter_resource.col_index + 0.5) * cell_dim.y,
							0.0,
							(fighter_resource.row_index + 0.5) * cell_dim.x
						)

		fighter.transform.origin = position


func _process(_delta: float) -> void:
	# TODO color selected square differently
	# will probably be implemented with quads and shader magic
	pass

func get_grid_coordinates(position: Vector3) -> Vector2:
	# position are local coordinates relative to BattleGrid/Ground
	# x == row_index, y == col_index
	return Vector2(int(position.z / total_dim.x * number_of_rows) + 1, int(position.x / total_dim.y * number_of_cols) + 1)

func _on_ClickArea_input_event(_camera: Node, event: InputEvent, position: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var mouse_position_local = to_local(position)
			# gizmo only used for debugging purposes
#			var gizmo = GizmoScene.instance()
#			gizmo.transform.origin = mouse_position_local
#			$Board.add_child(gizmo)			
			print(get_grid_coordinates(mouse_position_local))

func _on_Button_pressed() -> void:
	# go back (if there is somewhere to go back)
	# cant use type because of cyclic dependencies lol
	if get_parent().name == 'ExplorationView':
		get_parent().transition_to_exploration()
