shader_type particles;


void vertex() {
	if(RESTART) {
		uint base_number = NUMBER;
		uint alt_seed = hash(base_number + uint(1) + RANDOM_SEED);
		float in_plane_displacement = 0.5 * rand_from_seed_m1_p1(alt_seed);
//		TRANSFORM[3][0] += in_plane_displacement;
//		TRANSFORM[3][2] += in_plane_displacement;
	}
	
	
	// pass time-dependent COLOR to mesh shader
	// from dark grey to lighter grey
	COLOR += vec4(color_step, 0.0);
	// pass percentage of lifetime to mesh shader
	// this determines the dissolve parameter

//	CUSTOM.x = 0.5;

	// TODO add small constant upward movement
}