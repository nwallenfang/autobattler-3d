extends Sprite3D

func _ready() -> void:
	material_override.albedo_texture = $Viewport.get_texture()
