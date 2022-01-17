extends Spatial
class_name BattleGrid


onready	var grass_mesh = $Board/GrassTexture.mesh
onready var grid_material: ShaderMaterial = $Board/GridQuad.get_active_material(0) as ShaderMaterial

const FighterScene: PackedScene = preload("res://Logic/Combat/Fighter.tscn")
const friendly_fighter_resource: FighterResource = preload("res://Resources/SimpleFriendlyFighter.tres")
const GizmoScene: PackedScene = preload("res://UI/Gizmo.tscn")
const test_level: LevelResource = preload("res://Resources/Level1.tres")

var state = State.PREPARATION

enum State {
	PREPARATION,
	COMBAT
}

enum Type {
	Empty, Friendly, Enemy
}

# indexed (row,col) like a true mathematician
onready var grid_size: Vector2
# dimensions of a single cell of the grid, indexed (row,col) (== (z, x) in world-space)
onready var cell_dim: Vector2

var type = Type.Enemy


onready var data: BoardData
class BoardData:
	# class containing both the logical data of the board state (which fighters
	# are where etc.) and the sizes of the board in world coordinates.
	
	var types: Array  # 2d matrix of types
	var fighters: Array # 2d matrix of references to the fighters
	
	# with (0, 0) being top-left
	var number_of_rows: int # z in 3D
	var number_of_cols: int # x in 3D
	
	func _init(rows: int, cols:int) -> void:
		self.number_of_rows = rows
		self.number_of_cols = cols
		
		for row in range(rows):
			types.append([])
			fighters.append([])
			for col in range(cols):
				# TODO !!!!!!!!!!!!!!!!
				print(col)
				types[row].append(Type.Empty)
				fighters[row].append(null)
	
	# these access methods will all be in quadratic time which sucks but is fine for our board size.
	# if this class is one day used for managing data of an epic grid-based RTS you might want to
	# change the underlying data structure.
	func get_all_enemy_fighters() -> Array:
		# TODO invalidate memoization
		var enemy_fighters := []
		for row in range(number_of_rows):
			## TODO row is not used !!!
			print(row)
			types.append([])
			fighters.append([])
			for col in range(number_of_cols):
				print(col)
				# TODO
				pass
		return enemy_fighters
		
	func get_all_fighters() -> Array:
		return []
		
	func get_all_friendly_fighters():
		pass


func _ready() -> void:
	# total dim works under the premise that no scaling shenanigans are going on after
	# the board has been initialized
	# load test level, can be overridden when picking up a CombatOrb
	load_level(test_level)
	


func load_level(level: LevelResource) -> void:
	# init BoardData class that hold info on the fighters
	data = BoardData.new(level.number_of_rows, level.number_of_columns)
	
	# make dimension of the board known and calculate grid_sizes
	var grass_aabb = $Board/GrassTexture.get_aabb()
	grid_size = Vector2(grass_aabb.size.z, grass_aabb.size.x)
	grid_material.set_shader_param("rows", level.number_of_rows)
	grid_material.set_shader_param("columns", level.number_of_columns)
	cell_dim = Vector2(grid_size.x/level.number_of_rows, grid_size.y/level.number_of_rows)
	

	
	for fighter_resource in level.enemy_fighters:
		# type-cast to our custom resource
		fighter_resource = fighter_resource as FighterResource

		if fighter_resource == null:
			# fighter resource has wrong type to cast
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
		
		# register fighter to data class
		# (is doing it this way dangerous?)
		data.fighters[fighter_resource.row_index][fighter_resource.col_index] = fighter

func _process(_delta: float) -> void:
	# TODO color selected square differently
	# will probably be implemented with quads and shader magic
	pass

func get_grid_coordinates(position: Vector3) -> Vector2:
	# position are local coordinates relative to BattleGrid/Ground
	# x == row_index, y == col_index
	return Vector2(int(position.z / grid_size.x * data.number_of_rows) + 1, 
				   int(position.x / grid_size.y * data.number_of_cols) + 1)

func _on_ClickArea_input_event(_camera: Node, event: InputEvent, mouse_position_global: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var mouse_position_local = to_local(mouse_position_global)
			# gizmo only used for debugging purposes
#			var gizmo = GizmoScene.instance()
#			gizmo.transform.origin = mouse_position_local
#			$Board.add_child(gizmo)			
			var grid_row_col: Vector2 = get_grid_coordinates(mouse_position_local)
			
			# spawn friendly fighter at mouse position 
			# if there is no enemy standing there
			var friendly_fighter = FighterScene.instance()
#			friendly_fighter.team = Team.friendly_fighter.team = Team.
			friendly_fighter.init(friendly_fighter_resource)
			
			add_child(friendly_fighter)
			var position := Vector3(
					(grid_row_col.y - 0.5) * cell_dim.y,
					0.0,
					(grid_row_col.x - 0.5) * cell_dim.x
			)
			friendly_fighter.transform.origin = position

func _on_Button_pressed() -> void:
	# go back (if there is somewhere to go back to)
	# cant use type because of cyclic dependencies lol
	if get_parent().name == 'ExplorationView':
		get_parent().transition_to_exploration()


func _on_StartButton_pressed() -> void:
	self.state = State.COMBAT
	
	print(data.fighters)
