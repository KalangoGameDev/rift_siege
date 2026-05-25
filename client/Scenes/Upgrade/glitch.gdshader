shader_type canvas_item;

uniform float cell_size = 16.0;
uniform float dot_size : hint_range(0.0, 1.0) = 0.15;
uniform vec4 background_color : source_color = vec4(0.1, 0.1, 0.1, 1.0);
uniform vec4 dot_color : source_color = vec4(0.5, 0.5, 0.5, 1.0);
uniform vec2 offset = vec2(0.0, 0.0);
uniform float smoothness = 1.0;

void fragment() {
    // Use FRAGCOORD directly in pixel space
    vec2 pos = FRAGCOORD.xy + offset;
    
    // Scale by cell_size to get grid coordinates
    vec2 grid_pos = pos / cell_size;
    
    // Find nearest grid point
    vec2 nearest_grid_point = round(grid_pos) * cell_size;
    
    // Distance from current pixel to nearest grid point
    float dist = length(pos - nearest_grid_point);
    
    // Radius of the dot in pixels
    float radius = dot_size * cell_size;
    
    // Smooth transition at the edge
    float alpha = smoothstep(radius - smoothness, radius + smoothness, dist);
    
    // Mix colors based on distance
    COLOR = mix(dot_color, background_color, alpha);
}