vec4 color = 0.0;
color = _surface.position.y > 0 ? vec4(0.0,1.0,0.0,1.0) : vec4(1.0,0.0,0.0,1.0);
_output.color = color;