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
var current_target: Fighter

var team = Type.ENEMY

onready var healthbar: Healthbar = $Healthbar as Healthbar

var base_transform: Transform

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
#	base_transform = 
	
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
	if not is_instance_valid(current_target):
		# current target has been destroyed before we even started shooting.
		# unfortunate.
		# just reset the timer and find a new target.
		# or it could be possible the fight is over so check for that as well
		# before finding a new target.
		if self.is_fighting:
			$StartAttackTimer.start()
		return
	if current_target == null:
		push_error("current_target is null in attack Timer, what does this mean?")
	var projectile = ProjectileScene.instance()
	var board = get_parent() as Spatial
	board.add_child(projectile)
	projectile.global_transform.origin = board.global_transform.origin
	projectile.target_fighter = current_target
	projectile.translate(self.translation)
	projectile.translate(Vector3(0.0, PROJECTILE_HEIGHT, 0.0))
	projectile.connect("projectile_has_hit", self, "projectile_has_hit")
	
	# tween projectile in direction
	var start_position = projectile.translation
	var target_position = Vector3(current_target.translation)
	target_position.y = start_position.y
	var projectile_tween = projectile.get_node("Tween") as Tween
	projectile_tween.interpolate_property(projectile, "translation", start_position, target_position, projectile_duration)
	projectile_tween.start()


func projectile_has_hit(target_fighter: Fighter):
	# target_fighter will be invalid if the fighter this projectile was shot towards
	# is already dead
	if is_instance_valid(target_fighter):
		if not target_fighter == null:
			target_fighter.receive_attack(self.damage)
		else:
			push_error("target is null, unexpected behavior in projectile_has_hit")


# basically this is a queue of 3 actions
# 1. attack animation
# 2. shoot projectile
# 3. hit with projectile
# the only I parameter I should have to define is the time between attack_animations
# everything should be triggered from there. This means that I should only need a single timer.

# what I don't like about timing the attack *animation*, is that the animation is purely visual and
# should have no bearing on the game logic. (this is important if we want to simulate / speed up fights)
# we could time the shooting of the projectile instead. Then the question becomes how to trigger
# the pre-attack animation.


# transforms are pain
# I hope this could be simplified with more knowledge
func look_towards_target_old():
	# IM so stuck here I DONT UNDERSTAND THIS
	var start_position = self.translation
	var target_position = to_local(current_target.translation)
	var direction = (target_position - start_position).normalized()
	var target_in_plane_direction = Vector2(direction.x, direction.z).normalized()
	var current_look_direction = Vector2($Mesh.transform.basis.z.x, $Mesh.transform.basis.z.z) 
	
	print("direction to target: ", direction) 
	print("current_look_direction: ", current_look_direction) 
	var angle = current_look_direction.angle_to(target_in_plane_direction)  # + PI/2
	print(angle)
	# $Mesh.rotate_object_local(Vector3(0, 1, 0), angle)
	rotate_object_local(Vector3(0, 1, 0), angle)
	
func look_towards_target():
	# IM so stuck here I DONT UNDERSTAND THIS

#	rotate_object_local(Vector3(0, 1, 0), angle)
	pass
	
func set_mesh_local_rotation_z(angle: float):
#	$Mesh.rotate_object_local(Vector3(0, 0, 1), deg2rad(angle))
	rotate_object_local(Vector3(1, 0, 0), deg2rad(angle))

func _on_StartAttackTimer_timeout() -> void:
	# see if our current target is still valid, else get another one by calling towards the parent
	if not is_instance_valid(current_target):
		# passing yourself as an argument in a signal feels like letting yourself 
		# fall while facing a cliff's edge, just hoping there is some benevolent
		# node listening that will catch you.
		# (your good old grandparent BattleGrid's got you in this case, phew)
		# The dreamy difference being that nothing has happened should you find
		# yourself uncaught at the foot of the mountain.
		emit_signal("target_fighter_invalid", self)
	
	var attack_time = 1.0 / attack_speed
	$StartAttackTimer.wait_time = attack_time

	look_towards_target()

	# start Attack animation, in the animation player shoot_projectile_towards_target will be called
	# TODO rotate towards target
	$AnimationPlayer.play("start_attack")


