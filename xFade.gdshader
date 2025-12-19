shader_type canvas_item;


void fragment() {
	COLOR.a = pow((1.0-(abs(UV.x-0.5f)*2.0)),2.0)*COLOR.a;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
