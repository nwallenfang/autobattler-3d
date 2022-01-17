extends Spatial

func _ready():
	$Viewport.set_clear_mode(Viewport.CLEAR_MODE_ONLY_NEXT_FRAME)
	# Let two frames pass to make sure the viewport is captured.
	yield(get_tree(), "idle_frame")
	yield(get_tree(), "idle_frame")
	var spatial_mat: SpatialMaterial = $QuadMesh.mesh.surface_get_material(0)
	
	# load viewport texture at run time (won't be ready at build time)
	# this means we need to use load and not preload
	var viewport_texture: ViewportTexture = $Viewport.get_texture()
	spatial_mat.albedo_texture = viewport_texture
	
