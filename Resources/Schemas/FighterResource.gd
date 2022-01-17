extends Resource
class_name FighterResource

# this resource saves all data that makes a Fighter unique
# and it can easily be saved persistenly on-disk :)

enum Team {
	FRIENDLY, ENEMY
}

export(Team) var team = Team.ENEMY

export(int) var max_health
export(int) var damage
export(float) var attack_speed

export(int) var row_index = 0
export(int) var col_index = 0

export(Mesh) var mesh
