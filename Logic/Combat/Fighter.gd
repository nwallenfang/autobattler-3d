extends Spatial

class_name Fighter

var health: int
var max_health: int
var damage: int
var attack_speed: float

enum Team {
	PLAYER, ENEMY
}

func init(resource: FighterResource) -> void:
	self.health = resource.max_health
	self.max_health = resource.max_health
	self.damage = resource.damage
	self.attack_speed = resource.attack_speed
	
	$Mesh.mesh = resource.mesh
	

	var aabb: AABB = $Mesh.mesh.get_aabb()
	# scale fighter to make AABB be a 1x2x1 Box
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
