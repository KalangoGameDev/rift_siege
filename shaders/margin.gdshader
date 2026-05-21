shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

uniform vec2 rect_size_px = vec2(40.0, 40.0);
uniform float border_thickness_px = 2.0;
uniform float gap_between_corners_px = 14.0;
uniform float min_corner_px = 4.0;
uniform float feather_px = 0.0;

void fragment() {
	vec2 px = UV * rect_size_px;

	float w = rect_size_px.x;
	float h = rect_size_px.y;
	float t = border_thickness_px;
	float f = feather_px;
	float corner_len_x = max((w - gap_between_corners_px) * 0.5, min_corner_px);
	float corner_len_y = max((h - gap_between_corners_px) * 0.5, min_corner_px);

	corner_len_x = min(corner_len_x, w * 0.5);
	corner_len_y = min(corner_len_y, h * 0.5);

	float left   = 1.0 - smoothstep(t, t + f + 0.0001, px.x);
	float right  = 1.0 - smoothstep(t, t + f + 0.0001, w - px.x);
	float top    = 1.0 - smoothstep(t, t + f + 0.0001, px.y);
	float bottom = 1.0 - smoothstep(t, t + f + 0.0001, h - px.y);

	float top_allowed = step(px.x, corner_len_x) + step(w - corner_len_x, px.x);
	float bottom_allowed = top_allowed;

	float left_allowed = step(px.y, corner_len_y) + step(h - corner_len_y, px.y);
	float right_allowed = left_allowed;

	top_allowed = clamp(top_allowed, 0.0, 1.0);
	bottom_allowed = clamp(bottom_allowed, 0.0, 1.0);
	left_allowed = clamp(left_allowed, 0.0, 1.0);
	right_allowed = clamp(right_allowed, 0.0, 1.0);

	float alpha = 0.0;
	alpha = max(alpha, top * top_allowed);
	alpha = max(alpha, bottom * bottom_allowed);
	alpha = max(alpha, left * left_allowed);
	alpha = max(alpha, right * right_allowed);

	COLOR = vec4(border_color.rgb, border_color.a * alpha);
}