extends Spatial

class_name Fighter

var health: int setget set_health
var max_health: int
var damage: int
var attack_speed: float

# this is how long before the AttackTimer to 
var projectile_duration := 0.3

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


const ProjectileScene = preload("res://Objects/Projectile.tscn")

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
	
	# pain
	self.row = resource.row_index
	self.col = resource.col_index

	var aabb: AABB = $Mesh.mesh.get_aabb()
	# TODO scale fighter to make AABB be a 1x2x1 Box
	# that means that aabb's x and z should be -0.5, y should be 0.0
	# width and depth should be 1
	# we'll work under the premise for now that x and z dimensions are equal

	var translation: Vector3 = Vector3()
	translation.y = -aabb.position.y
	$Mesh.translate(translation)
	$Mesh.transform = $Mesh.transform.scaled(Vector3(200.0, 200.0, 200.0))
	var _err
	_err = connect("died", signal_handler, "fighter_died")
	_err = connect("target_fighter_invalid", signal_handler, "target_fighter_invalid")
	
	# save fighter to have a look at it in the editor
#	var packed_scene = PackedScene.new()
#	packed_scene.pack(self)
#	ResourceSaver.save("res://Test/TestFighter.tscn", packed_scene)

func set_is_fighting(value: bool):
	if is_fighting:
		if not value:
			is_fighting = false
			$StartAttackTimer.stop()
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
			# The first attack timer will have 1/attack_speed - projectile_duration as duration
			# after that it will trigger every 1/attack_speed 
			# TODO big problems if attack_speeed is too high and attack_time < projectile_duration
			if attack_time < projectile_duration:
				push_error("attack_time < projectile_duration, needs to be implemented")
			$StartAttackTimer.start(attack_time - projectile_duration)

# later a more complex Attack object can be passed
func receive_attack(enemy_damage: int):
	self.health -= enemy_damage

# same for this, this is just a placeholder for more complex behavior
func attack():
	if not is_instance_valid(target_fighter):  # no target to fight
		# passing yourself as an argument in a signal feels like letting yourself 
		# fall while facing a cliff's edge, just hoping there is some benevolent
		# node listening that will catch you.
		# (your good ol' grandparent BattleGrid's got you in this case, phew)
		# The dreamy difference being that nothing has happened when you find
		# yourself uncaught at the foot of the mountain)
		emit_signal("target_fighter_invalid", self)
		
	# target_fighter will be null if there is noone to fight right now
	if target_fighter != null:
		target_fighter.receive_attack(self.damage)

func start_dying():
	emit_signal("died", {"row": self.row, "col": self.col})
	queue_free()

func set_health(new_health: int):
	health = new_health
	$Healthbar.update_health(new_health)
	
	if health <= 0:
		start_dying()

const PROJECTILE_HEIGHT = 2.0
# may also depend on attack speed
#const PROJECTILE_BASE_SPEED = 2.0
func shoot_projectile_towards_target():
	var projectile = ProjectileScene.instance()
	var board = get_parent() as Spatial
	board.add_child(projectile)
	projectile.global_transform.origin = board.global_transform.origin
	projectile.translate(self.translation)
	projectile.translate(Vector3(0.0, PROJECTILE_HEIGHT, 0.0))
	projectile.connect("projectile_has_hit", self, "projectile_has_hit")
	
	# tween projectile in direction
	var start_position = projectile.translation
	var target_position = Vector3(target_fighter.translation)
	target_position.y = start_position.y
	var projectile_tween = projectile.get_node("Tween") as Tween
	
	projectile_tween.interpolate_property(projectile, "translation", start_position, target_position, projectile_duration)
	projectile_tween.start()
	
func projectile_has_hit():
	# this doesn't work if one fighter has multiple projectiles towards different targets active
	attack()


func _on_StartAttackTimer_timeout() -> void:
	var attack_time = 1.0 / attack_speed
	$StartAttackTimer.wait_time = attack_time
	if is_instance_valid(target_fighter):
		if target_fighter != null:
			shoot_projectile_towards_target()
	
#	$HitAttackTimer.start(projectile_duration)


