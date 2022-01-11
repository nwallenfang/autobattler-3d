shader_type spatial;

uniform float uNearClipPlane = 1.0;
uniform vec2  uPerspToOrtho = vec2( 0.0 );

void vertex()
{    
//	PROJECTION_MATRIX
    // Calculate view space position.
    vec4 view = MODELVIEW_MATRIX * vec4(VERTEX, 1.0);

    // Scale x&y to 'undo' perspective projection.
    view.x = mix( view.x, view.x * ( -view.z / uNearClipPlane ), uPerspToOrtho.x );
    view.y = mix( view.y, view.y * ( -view.z / uNearClipPlane ), uPerspToOrtho.y );

    // Output clip space coordinate.
	
	vec4 vertex_position_hom = PROJECTION_MATRIX * view;
    VERTEX = (vertex_position_hom/vertex_position_hom.w).xyz;
}

void fragment() {
	ALBEDO = COLOR.rgb;
}