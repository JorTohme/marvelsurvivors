shader_type canvas_item;

uniform vec4 line_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float line_thickness : hint_range(0, 30) = 0.0;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    
    if (line_thickness <= 0.0) {
        COLOR = color;
    } 
    else {
        vec2 size = TEXTURE_PIXEL_SIZE * line_thickness;
        
        float outline = 0.0;
        
        outline += texture(TEXTURE, UV + vec2(-size.x, 0.0)).a;
        outline += texture(TEXTURE, UV + vec2(0.0, size.y)).a;
        outline += texture(TEXTURE, UV + vec2(size.x, 0.0)).a;
        outline += texture(TEXTURE, UV + vec2(0.0, -size.y)).a;
        
        outline = step(0.01, outline);

        vec4 final_color = mix(color, line_color, outline * (1.0 - color.a));
        COLOR = final_color;
    }
}