class_name Rock
extends RigidBody2D

@export var rockColors : Array[Color]
@export var shaker : Shaker
@export var main : Sprite2D

func _enter_tree():
	var shaderMat : ShaderMaterial = main.material
	var remainingRockCol : Array[Color] = Array(rockColors)
	var colA : Color = remainingRockCol.pick_random()
	remainingRockCol.erase(colA)
	var colB : Color = remainingRockCol.pick_random()
	
	shaderMat.set_shader_parameter("colA",colA)
	shaderMat.set_shader_parameter("colB",colB)
	shaderMat.set_shader_parameter("noiseOffset",Vector2(randf(),randf()))

func hit():
	shaker.Trigger(Shaker.Small)
