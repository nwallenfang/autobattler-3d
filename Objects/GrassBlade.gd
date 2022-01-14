extends Spatial

# go down the horrible depths of this auto-imported hierarchy
onready var mesh_instance: MeshInstance = get_node("RootNode (gltf orientation matrix)/RootNode (model correction matrix)/Collada visual scene group/blade10/defaultMaterial")
onready var material: ShaderMaterial = mesh_instance.get_active_material(0)

var player: Player

func _on_PlayerDetection_body_entered(body):
	if body is Player:
		player = body as Player
		var distance := self.translation.distance_to(player.translation)
		var direction: Vector3 = self.translation.direction_to(player.translation)
		material.set_shader_param("player_near", true)
		material.set_shader_param("player_distance", distance)
		material.set_shader_param("player_direction", Vector2(direction.x, direction.z).rotated(PI))
		$UpdateTimer.start()

func _on_PlayerDetection_body_exited(_body: Node) -> void:
	material.set_shader_param("player_near", false)
	$UpdateTimer.stop()

func _on_UpdateTimer_timeout() -> void:
	var distance := self.translation.distance_to(player.translation)
	var direction: Vector3 = self.translation.direction_to(player.translation)
	material.set_shader_param("player_distance", distance)
	material.set_shader_param("player_direction", Vector2(direction.x, direction.z).rotated(PI))
