class_name BeakSlash
extends Node2D

var p : Player
var trackBeak : bool

@export var tex : Array[Texture2D]

@export var slashLine : Line2D
@export var impactLine : Line2D

@export var slashWidth : float
@export var impactWidth : float

@export var slashDuration : float
@export var slashCurve : Curve
@export var impactDuration : float
@export var impactCurve : Curve

var t : float

func setup(_p : Player, slashColor : Color):
	p=_p
	trackBeak=true
	slashLine.width=slashWidth
	impactLine.width=impactWidth
	
	var texSelected = tex.pick_random()
	slashLine.texture=texSelected
	slashLine.modulate=slashColor
	impactLine.texture=texSelected
func _physics_process(delta):
	if trackBeak:
		if p.curState!=Player.PlayerState.Pecking:
			trackBeak=false
		else:
			slashLine.set_point_position(0,p.position)
			slashLine.set_point_position(1,p.beakPoint.global_position)
			
			impactLine.set_point_position(0,p.position)
			impactLine.set_point_position(1,p.beakPoint.global_position)
	else:
		t+=delta
		slashLine.width=slashWidth*slashCurve.sample(MathS.Clamp01(t/slashDuration))
		impactLine.width=impactWidth*impactCurve.sample(MathS.Clamp01(t/impactDuration))
		
		if t>=impactDuration:
			queue_free()
