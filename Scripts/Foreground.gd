extends Node2D
@export var grass : Sprite2D
@export var ground : Sprite2D

func _ready():
    grass.position.x=int(MathS.RandSigned()*75)
    ground.position.x=int(MathS.RandSigned()*75)
    grass.flip_h=randf()>0.5
    ground.flip_h=randf()>0.5
