class_name ScoreDisplay
extends Node2D

@export var label : RichTextLabel
@export var shaker : Shaker
@export var squash : SquashAnchor


func update(score : int):
	var s : String = "000"
	if score<10:
		s="00"+str(score)
	elif score<100:
		s="0"+str(score)
	else:
		s=str(score)
	label.text=s
	squash.TriggerSquash(SquashAnchor.Medium)
	rotation_degrees=MathS.RandSigned()*8

func _ready():
	Score.display=self