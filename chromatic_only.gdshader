shader_type canvas_item;

uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform bool should_animate = false;
uniform float time_multiplayer = 5.0;

void fragment(){
	float time = TIME * time_multiplayer;
	vec2 r_offset = vec2(0.0);
	vec2 g_offset = vec2(0.0);
	vec2 b_offset = vec2(0.0);
	if(should_animate){
	    // Calculate time-based variations for displacement
	   	r_offset = vec2(sin(time * 5.0) * 3.0, cos(time * 7.0)) * 0.5; // Adjust speed and intensity
	    g_offset = vec2(sin(time * 4.0), cos(time * 6.0)) * 0.5;
	    b_offset = vec2(sin(time * 6.0) * 6.0, cos(time * 5.0)) * 0.5;
	}
    
    // Apply displacement with time-based variations
    float r = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * (r_displacement + r_offset)), 0.0).r;
    float g = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * (g_displacement + g_offset)), 0.0).g;
    float b = texture(SCREEN_TEXTURE, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * (b_displacement + b_offset)), 0.0).b;

    COLOR = vec4(r, g, b, 1.0);
}
