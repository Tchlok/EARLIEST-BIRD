shader_type canvas_item;
uniform vec4 colA;
uniform vec4 colB;
uniform sampler2D noise;
uniform vec2 noiseOffset;

void fragment() {
	COLOR.a=texture(TEXTURE,UV).a;
	COLOR.rgb=vec3(0.0,0.0,0.0);
	float selected = step(texture(noise,(UV+noiseOffset)*0.5).r,0.4);
	COLOR.rgb+=colA.rgb*selected;
	COLOR.rgb+=colB.rgb*(1.0-selected);
	
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
