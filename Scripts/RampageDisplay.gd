class_name RampageDisplay
extends Node2D

@export var label : RichTextLabel
@export var shaker : Shaker
@export var squash : SquashAnchor

func update(rampage : float, delta : float):
	if delta==0:
		return
	var i : int = int(rampage*100)
	var s : String = "000"
	if i<10:
		s="00"+str(i)
	elif i<100:
		s="0"+str(i)
	else:
		s=str(i)
	label.text=s
	if delta > 0:
		squash.TriggerSquash(SquashAnchor.Medium)
		rotation_degrees=MathS.RandSigned()*8
	else:
		shaker.Trigger(Shaker.Small)
		rotation_degrees=0
