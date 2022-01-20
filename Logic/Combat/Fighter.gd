extends Spatial

class_name Fighter

var health: int setget set_health
var max_health: int
var damage: int
var attack_speed: float

# replace this with a proper state machine later, for now it's either fighting or not
var is_fighting := false setget set_is_fighting
# the fighter this one will attack
var target_fighter: Fighter

var team = Type.ENEMY

onready var healthbar: Healthbar = $Healthbar as Healthbar

# fighter shouldn't have this information because we will use the fighter
# independelty from the grid. But I don't know how to handle the access
# in get_closest_fighter() (BattleGrid.gd) more elegantly without this.
# ¯\_(ツ)_/¯
var row: int
var col: int

signal died
signal target_fighter_invalid


enum Type {
	FRIENDLY, ENEMY
}

func _ready() -> void:
	# we expect init to be called once the fighter has entered the tree!!
	healthbar.update_max_health(max_health)
	healthbar.update_health(health)

func init(signal_handler: Node, resource: FighterResource) -> void:
	self.health = resource.max_health
	self.max_health = resource.max_health
	self.damage = resource.damage
	self.attack_speed = resource.attack_speed
	# enums are the same between this class and the resource
	self.team = resource.team
	$Mesh.mesh = resource.mesh
	

	var aabb: AABB = $Mesh.mesh.get_aabb()
	# TODO scale fighter to make AABB be a 1x2x1 Box
	# that means that aabb's x and z should be -0.5, y should be 0.0
	# width and depth should be 1
	# we'll work under the premise for now that x and z dimensions are equal

	var translation: Vector3 = Vector3()
	translation.y = -aabb.position.y
	$Mesh.translate(translation)
	$Mesh.transform = $Mesh.transform.scaled(Vector3(200.0, 200.0, 200.0))
	
	connect("died", signal_handler, "fighter_died")
	connect("target_fighter_invalid", signal_handler, "target_fighter_invalid")
	
	# save fighter to have a look at it in the editor
#	var packed_scene = PackedScene.new()
#	packed_scene.pack(self)
#	ResourceSaver.save("res://Test/TestFighter.tscn", packed_scene)

func set_is_fighting(value: bool):
	if is_fighting:
		if not value:
			is_fighting = false
			$AttackTimer.stop()
		else:
			# no change
			pass
	else: # not is_fighting
		if not value:
			# no change
			pass
		else:
			is_fighting = true
			var attack_time = 1.0 / attack_speed
			$AttackTimer.start(attack_time)

# later a more complex Attack object can be passed
func receive_attack(enemy_damage: int):
	self.health -= enemy_damage

# same for this, this is just a placeholder for more complex behavior
func attack():
	if not is_instance_valid(target_fighter):
		# will return null if there is noone to fight right now
		emit_signal("target_fighter_invalid", {row: self.row, col: self.col})
		var battle_grid = get_parent().get_parent()
		target_fighter = battle_grid.get_new_target(self)
	
	if target_fighter != null:
		target_fighter.receive_attack(self.damage)

func start_dying():
	emit_signal("died", {row: self.row, col: self.col})
	queue_free()

func set_health(new_health: int):
	health = new_health
	$Healthbar.update_health(new_health)
	
	if health <= 0:
		start_dying()


func _on_AttackTimer_timeout() -> void:
	attack()
