// NOTE: Shader automatically converted from Godot Engine 3.4.stable's SpatialMaterial.

shader_type spatial;
render_mode blend_mix,depth_draw_opaque,cull_back,diffuse_burley,specular_schlick_ggx,shadows_disabled;
uniform vec4 albedo : hint_color;
uniform sampler2D texture_albedo : hint_albedo;
uniform float specular;
uniform float metallic;
uniform float alpha_scissor_threshold;
uniform float roughness : hint_range(0,1);
uniform float point_size : hint_range(0,128);
uniform vec3 uv1_scale;
uniform vec3 uv1_offset;
uniform vec3 uv2_scale;
uniform vec3 uv2_offset;

// stuff for the grid
uniform float columns = 10.0;
uniform float rows = 10.0;
uniform float border_width = 0.05;
uniform vec4 border_color : hint_color;


void vertex() {
	UV=UV*uv1_scale.xy+uv1_offset.xy;
}


void fragment() {
	vec2 base_uv = UV;
	vec4 albedo_tex = texture(texture_albedo,base_uv);
	vec2 grid = fract(vec2(UV.x * columns, UV.y * rows));
	vec2 bottom_left = step(vec2(border_width), grid);
	vec2 top_right = step(vec2(border_width), 1.0 - grid);
	vec4 color = border_color - (bottom_left.x * bottom_left.y * top_right.x * top_right.y);
	ALBEDO = color.rgb;
	
	METALLIC = metallic;
	ROUGHNESS = roughness;
	SPECULAR = specular;
	ALPHA = color.a;
	ALPHA_SCISSOR=alpha_scissor_threshold;
}
