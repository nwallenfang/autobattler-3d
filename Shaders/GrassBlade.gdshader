// NOTE: Shader automatically converted from Godot Engine 3.4.stable's SpatialMaterial.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform sampler2D texture_metallic : hint_white;
uniform vec4 metallic_texture_channel;
uniform sampler2D texture_roughness : hint_white;
uniform vec4 roughness_texture_channel;
uniform sampler2D texture_normal : hint_normal;
uniform float normal_scale : hint_range(-16,16);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

// Custom uniforms :)
uniform bool player_near = false;
// I dont feel like we will be able to afford to update this every frame, maybe every 10 frames or something
uniform float player_distance = 5.0;
uniform vec2 player_direction; // x, z, should be perpendicular to player movement direction
// also the wind shouldn' t affect the grass when player is near

void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
	if(player_near) {
		float magnitude = 0.60 * (1.0 - player_distance/3.0);
		float mask = float(VERTEX.y > -0.95);
		float height = 0.5 * (VERTEX.y + 1.0);
		VERTEX.x += mask * magnitude * player_direction.x * height;
		VERTEX.z += mask * magnitude * player_direction.y * height;
	} else {
		float mask = float(VERTEX.y > -0.8);
		float strength = 1.0;
		float height = 0.5 * (VERTEX.y + 1.0);
		float direction = 0.2 * cos(TIME) * (height);
		float displacement = mask * strength * direction;
		VERTEX.x += displacement;
	}
}




void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	ALBEDO = albedo.rgb * albedo_tex.rgb;
	float metallic_tex = dot(texture(texture_metallic,base_uv),metallic_texture_channel);
	METALLIC = metallic_tex * metallic;
	float roughness_tex = dot(texture(texture_roughness,base_uv),roughness_texture_channel);
	ROUGHNESS = roughness_tex * roughness;
	SPECULAR = specular;
	NORMALMAP = texture(texture_normal,base_uv).rgb;
	NORMALMAP_DEPTH = normal_scale;
}
