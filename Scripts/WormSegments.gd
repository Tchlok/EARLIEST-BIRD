class_name WormSegments
extends Line2D

@export var baseWidth : float
@export var baseDist : float = 5

@export var segmentColors : Array[Color]
@export var dirtLine : Line2D
@export var dirtWidthAdd : int = 4

var belongsTo : Worm
func setup(_belongsTo, segCount, scaleMod):
	belongsTo=_belongsTo
	var p : PackedVector2Array
	for i in range(segCount):
		p.append(belongsTo.position)
	points=p
	dist=baseDist*scaleMod
	width=baseWidth*scaleMod
	var remainingSegCol : Array[Color] = Array(segmentColors)
	var colA : Color = remainingSegCol.pick_random()
	remainingSegCol.erase(colA)
	var colB : Color = remainingSegCol.pick_random()
	
	dirtLine.width=width+dirtWidthAdd

	gradient.add_point(0,colA)
	gradient.add_point(1,colB)
	gradient.remove_point(0)

var speed : float = 100
var dist : float

func _physics_process(delta: float):
		
	boundsX=Vector2(points[0].x,points[0].x)
	lowestY=points[0].y

	if points[0].distance_to(belongsTo.position)>2:
		set_point_position(0, points[0] + points[0].direction_to(belongsTo.position)*delta*speed)
	for i in range(1,points.size()):
		if points[i].distance_to(points[i-1])>dist:
			set_point_position(i, points[i] + points[i].direction_to(points[i-1])*delta*speed)
	for p in points:
		if p.x < boundsX.x:
			boundsX.x=p.x
		elif p.x > boundsX.y:
			boundsX.y=p.x
		if p.y < lowestY:
			lowestY=p.y
	dirtLine.points=points

var boundsX : Vector2
var lowestY : float

func hitCheck(beakPos):
	if beakPos.x < boundsX.x:
		return null
	if beakPos.x > boundsX.y:
		return null
	if beakPos.y < lowestY:
		return null
	var cur
	cur = Geometry2D.segment_intersects_segment(belongsTo.position,points[0],beakPos, beakPos+Vector2.UP*1000)
	if cur!=null:
		print("FIRST SEG HIT")
		return cur

	for i in range(points.size()-1):
		cur = Geometry2D.segment_intersects_segment(points[i],points[i+1],beakPos, beakPos+Vector2.UP*1000)
		if cur!=null:
			print(str(i)+"TH SEG HIT")
			return cur
