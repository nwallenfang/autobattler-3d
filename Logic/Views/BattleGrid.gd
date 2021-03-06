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
	Friendly, Enemy, Empty
}

# indexed (row,col) like a true mathematician
onready var grid_size: Vector2
# dimensions of a single cell of the grid, indexed (row,col) (== (z, x) in world-space)
onready var cell_dim: Vector2


onready var data: BoardData
class BoardData:
	# class containing both the logical data of the board state (which fighters
	# are where etc.) and the sizes of the board in world coordinates.
	
	var types: Array  # 2d matrix of types
	var fighters: Array # 2d matrix of references to the fighters
	
	var cache_valid := false
	
	# these are cached lists of the last result for memoization
	var _friendly_fighters = []
	var _enemy_fighters = []
	var _all_fighters = []
	
	# with (0, 0) being top-left
	var number_of_rows: int # z in 3D
	var number_of_cols: int # x in 3D
	
	func _init(rows: int, cols:int) -> void:
		self.number_of_rows = rows
		self.number_of_cols = cols
		
		for row in range(rows):
			types.append([])
			fighters.append([])
			for _col in range(cols):
				types[row].append(Type.Empty)
				fighters[row].append(null)

	
	func prepare_all_fighter_lists():
		# reset the lists
		_enemy_fighters = []
		_friendly_fighters = []
		
		for row in range(number_of_rows):
			for col in range(number_of_cols):
				if types[row][col] == Type.Enemy:
					_enemy_fighters.append(fighters[row][col])
				elif types[row][col] == Type.Friendly:
					_friendly_fighters.append(fighters[row][col])
				# copy "calculated" list for next time
		_all_fighters = _friendly_fighters.duplicate()
		_all_fighters.append_array(_enemy_fighters)
		cache_valid = true


	# these access methods will all be in quadratic time which sucks but is fine for our board size.
	# if this class is one day used for managing data of an epic grid-based RTS you might want to
	# change the underlying data structure.
	func get_enemy_fighters() -> Array:
		if cache_valid:
			return _enemy_fighters
		else:
			prepare_all_fighter_lists()
			return _enemy_fighters
	
	func get_all_fighters() -> Array:
		if cache_valid:
			return _all_fighters
		else:
			prepare_all_fighter_lists()
			return _all_fighters
		
	func get_friendly_fighters():
		if cache_valid:
			return _friendly_fighters
		else:
			prepare_all_fighter_lists()
			return _friendly_fighters
			
	func get_closest_fighter(row: int, col: int, type: int):
		# Find the fighter belonging to the team specified in type that is closest
		# to (row, col) (euclidean distance)
		if not cache_valid:
			prepare_all_fighter_lists()
		var search_fighters: Array
		if type == Type.Friendly:
			search_fighters = _enemy_fighters
		elif type == Type.Enemy:
			search_fighters = _friendly_fighters
		else:
			push_error("invalid type argument passed")
		
		var closest_fighter: Fighter
		var distance: float
		# vector of argument row and col index
		var own_vector: Vector2 = Vector2(row, col)
		var fighter_vector: Vector2
		var shortest_dist_so_far := 1.79769e308
		
		for fighter in search_fighters:
			fighter_vector = Vector2(fighter.row, fighter.col)
			distance = own_vector.distance_to(fighter_vector)
			
			if distance < shortest_dist_so_far:
				shortest_dist_so_far = distance
				closest_fighter = fighter
				
		
		
		return closest_fighter
		
	func register_fighter(fighter: Fighter, row: int, col: int):
		if types[row][col] != Type.Empty:
			push_error("Tried to add fighter to occupied space (%s, %s)" % [row, col])
			
		fighters[row][col] = fighter
		types[row][col] = fighter.team
		cache_valid = false
		
	func is_occupied(row: int, col: int) -> bool:
		return types[row][col] != Type.Empty
		
		
	func clear(row: int, col: int):
		cache_valid = false
		types[row][col] = Type.Empty
		fighters[row][col] = null
	
	func print_state():
		for row in range(number_of_rows):
			for col in range(number_of_cols):
				if types[row][col] != Type.Empty:
					var team_name
					if types[row][col] == Type.Friendly:
						team_name = "Friendly"
					else:
						team_name = "Enemy"
					var fighter = fighters[row][col]
					print("(%s|%s) %s (%s|%s)" % [row, col, team_name,
					fighter.row, fighter.col])


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
		# pipe resource data into Fighter instance
		fighter.init(self, fighter_resource)
		$Board.add_child(fighter)

		
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
		if not data.is_occupied(fighter_resource.row_index, fighter_resource.col_index):
			data.register_fighter(fighter, fighter_resource.row_index, fighter_resource.col_index)

func match_state():
	match state:
		State.COMBAT:
			pass
		State.PREPARATION:
			pass

func state_combat():
	pass

func _process(_delta: float) -> void:
	# TODO color selected square differently
	# will probably be implemented with quads and shader magic
	match_state()

func get_grid_coordinates(position: Vector3) -> Dictionary:
	# position are local coordinates relative to BattleGrid/Ground
	# returns dictionary with 'row' and 'col' as keys
	# row == row_index, col == col_index
	return {
		"row": int(position.z / grid_size.x * data.number_of_rows), 
		"col": int(position.x / grid_size.y * data.number_of_cols)
	}


func add_fighter_to_tree(fighter_resource: FighterResource) -> Fighter:
	return add_fighter_to_tree_with_pos(fighter_resource, fighter_resource.row_index, fighter_resource.col_index)

	
func add_fighter_to_tree_with_pos(fighter_resource: FighterResource, row: int, col: int):
	var fighter = FighterScene.instance()
	fighter.init(self, fighter_resource)
	fighter.row = row
	fighter.col = col
	$Board.add_child(fighter)
	data.register_fighter(fighter, row, col)
	return fighter	


func stop_fighting():
	for fighter in data.get_all_fighters():
		(fighter as Fighter).is_fighting = false

# magically connected to died signal in Fighter
func fighter_died(coords: Dictionary):
	data.clear(coords["row"], coords["col"])
	
	# see if game is over
	if data.get_enemy_fighters().empty():
		state = State.PREPARATION
		$CanvasLayer/RichTextLabel.visible = true
		$CanvasLayer/RichTextLabel.text = "You won! :)"
		stop_fighting()
		
	if data.get_friendly_fighters().empty():
		state = State.PREPARATION
		$CanvasLayer/RichTextLabel.visible = true
		$CanvasLayer/RichTextLabel.text = "You lost! :("
		stop_fighting()

# magically connected to target_fighter_invalid in Fighter	
func target_fighter_invalid(fighter: Fighter):
	# looks stupid but I just need to figure out where thsi BUG is
	var args = {"row": fighter.row, "col": fighter.col, "team": fighter.team}
	fighter.current_target = data.get_closest_fighter(args.row, args.col, args.team)
	

func _on_ClickArea_input_event(_camera: Node, event: InputEvent, mouse_position_global: Vector3, _normal: Vector3, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var mouse_position_local = to_local(mouse_position_global)
			# gizmo only used for debugging purposes
#			var gizmo = GizmoScene.instance()
#			gizmo.transform.origin = mouse_position_local
#			$Board.add_child(gizmo)			
			var grid_position: Dictionary = get_grid_coordinates(mouse_position_local)
			
			# if the position is empty, spawn a fighter there
			# else reduce the target fighter health just for debugging purposes
			# spawn friendly fighter at mouse position 
			# if there is no enemy standing there
			if not data.is_occupied(grid_position.row, grid_position.col):
				var fighter = add_fighter_to_tree_with_pos(friendly_fighter_resource, grid_position.row, grid_position.col)
				# move fighter to center of cell
				var position := Vector3(
					(grid_position.col + 0.5) * cell_dim.y,
					0.0,
					(grid_position.row + 0.5) * cell_dim.x
				)
				fighter.transform.origin = position
				
			else:
				# there is a fighter at this position
				# reduce it's health to test
				var fighter: Fighter = data.fighters[grid_position.row][grid_position.col]
				fighter.health -= 1


func _on_Button_pressed() -> void:
	# go back (if there is somewhere to go back to)
	# cant use type because of cyclic dependencies lol
	if get_parent().name == 'ExplorationView':
		get_parent().transition_to_exploration()


func _on_StartButton_pressed() -> void:
	self.state = State.COMBAT
	
	for fighter in data.get_all_fighters():
		# find target fighter that this one will attack
		(fighter as Fighter).is_fighting = true
	


func _on_StartButton2_pressed() -> void:
	var packed_scene = PackedScene.new()
	packed_scene.pack(self)
	var blu = ResourceSaver.save("res://Test/TestGrid.tscn", packed_scene)
