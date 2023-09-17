
// film shader with grain effect

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform vec4 base: source_color;
uniform sampler2D grain;
uniform float grain_strength = 0.3;
uniform float fps = 12.0;
uniform float stretch = 0.5;
uniform float flashing = 0.01;

uniform bool is_mono;
uniform sampler2D vignette;
uniform bool is_grain = true;


uniform vec2 r_displacement = vec2(3.0, 0.0);
uniform vec2 g_displacement = vec2(0.0, 0.0);
uniform vec2 b_displacement = vec2(-3.0, 0.0);

uniform bool is_chromatic = true;
uniform bool chromatic_should_animate = false;
uniform float chromatic_time_multiplayer = 5.0;

uniform float film_darkness : hint_range(0.0, 1.0) = 0.4;

float make_grain(float time, vec2 uv) {
	vec2 ofs = vec2(sin(41.0 * time * sin(time * 123.0)), sin(27.0 * time * sin(time * 312.0)));
	return texture(grain, (uv + mod(ofs, vec2(1.0, 1.0))) * stretch).r;
}

void fragment() {
	if(is_chromatic){
	float time = TIME * chromatic_time_multiplayer;
	vec2 r_offset = vec2(0.0);
	vec2 g_offset = vec2(0.0);
	vec2 b_offset = vec2(0.0);
	if(chromatic_should_animate){
	    // Calculate time-based variations for displacement
	   	r_offset = vec2(sin(time * 5.0) * 3.0, cos(time * 7.0)) * 0.5; // Adjust speed and intensity
	    g_offset = vec2(sin(time * 4.0), cos(time * 6.0)) * 0.5;
	    b_offset = vec2(sin(time * 6.0) * 6.0, cos(time * 5.0)) * 0.5;
	}
    
    // Apply displacement with time-based variations
    float c_r = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * (r_displacement + r_offset)), 0.0).r;
    float c_g = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * (g_displacement + g_offset)), 0.0).g;
    float c_b = texture(screen_texture, SCREEN_UV + vec2(SCREEN_PIXEL_SIZE * (b_displacement + b_offset)), 0.0).b;

    COLOR = vec4(c_r, c_g, c_b, 1.0);
	} else {
		COLOR = texture(screen_texture, SCREEN_UV);
	}
	
	if(is_grain){
	vec3 c = COLOR.rgb; //textureLod(screen_texture, SCREEN_UV, 0.0).rgb;
	//float v = max(c.r, max(c.g, c.b));
	float v = dot(c, vec3(0.33333, 0.33333, 0.33333));
	v = sqrt(v);
	//v *= v;

	float f = 1.0 / fps;
	float g = make_grain(TIME - mod(TIME, f), UV);
	g = max(g, make_grain(TIME - mod(TIME, f) + f, UV) * 0.5);
	g = max(g, make_grain(TIME - mod(TIME, f) + f * 2.0, UV) * 0.25);

	if(is_mono){
		COLOR.rgb = base.rgb * v - vec3(g) * grain_strength;
	} else {
		COLOR.rgb = c * v - vec3(g) * grain_strength;
	}
	float ft = TIME * 0.002;
	COLOR.rgb *= texture(vignette, UV).r; // for vignette effect
	COLOR.rgb += vec3(sin(75.0 * ft * sin(ft * 123.0))) * flashing + film_darkness;
	}
}