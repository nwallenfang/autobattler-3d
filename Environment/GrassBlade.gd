extends Spatial

# go down the horrible depths of this auto-imported hierarchy
onready var mesh_instance: MeshInstance = get_node("RootNode (gltf orientation matrix)/RootNode (model correction matrix)/Collada visual scene group/blade10/defaultMaterial")
onready var material: ShaderMaterial = mesh_instance.get_active_material(0)

func _on_PlayerDetection_body_entered(body):
	material.set_shader_param("player_near", true)
	print('mmh yello')
	


func _on_PlayerDetection_body_exited(body: Node) -> void:
	print('mmh bye')
	material.set_shader_param("player_near", false)
