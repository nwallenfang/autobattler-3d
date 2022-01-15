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
	
	# TODO scale fighter to make AABB be a 1x2x1 Box
	var aabb: AABB = $Mesh.mesh.get_aabb()
