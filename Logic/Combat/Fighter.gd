extends Spatial

class_name Fighter

var health: int setget set_health
var max_health: int
var damage: int
var attack_speed: float

var team = Type.ENEMY

onready var healthbar: Healthbar = $Healthbar as Healthbar

# fighter shouldn't have this information because we will use the fighter
# independelty from the grid. But I don't know how to handle the access
# in get_closest_fighter() (BattleGrid.gd) more elegantly without this.
# ¯\_(ツ)_/¯
var row: int
var col: int

enum Type {
	FRIENDLY, ENEMY
}

func _ready() -> void:
	# we expect init to be called once the fighter has entered the tree!!
	healthbar.update_max_health(max_health)
	healthbar.update_health(health)

func init(resource: FighterResource) -> void:
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
	# save fighter to have a look at it in the editor
#	var packed_scene = PackedScene.new()
#	packed_scene.pack(self)
#	ResourceSaver.save("res://Test/TestFighter.tscn", packed_scene)

func set_health(new_health: int):
	health = new_health
	$Healthbar.update_health(new_health)
