class_name WormSegments
extends Line2D

@export var baseWidth : float
@export var baseDist : float = 5

@export var segmentColors : Array[Color]
@export var dirtLine : Line2D
@export var dirtWidthAdd : int = 4

var colA : Color
var colB : Color

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
	colA = remainingSegCol.pick_random()
	remainingSegCol.erase(colA)
	colB = remainingSegCol.pick_random()
	
	dirtLine.width=width+dirtWidthAdd

	gradient.add_point(0,colA)
	gradient.add_point(1,colB)
	gradient.remove_point(0)

var speed : float = 100
var dist : float

func _physics_process(delta: float):
	
	if not dead:
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
	else:
		deadT+=delta
		segmentT+=delta
		var p = MathS.Clamp01(deadT/timeToFree)
		dirtLine.width=(width+dirtWidthAdd-4)*dirtWidthCurve.sample(p)
		if segmentT>=timeBetweenRipples:
			segmentT-=timeBetweenRipples
			if 0 <= segmentRippleLeft:
				spawnSegPar(points[segmentRippleLeft])
				segmentRippleLeft-=1
			if points.size()>segmentRippleRight:
				spawnSegPar(points[segmentRippleRight])
				segmentRippleRight+=1
		if deadT>=timeToFree:
			queue_free()

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
		return cur

	for i in range(points.size()-1):
		cur = Geometry2D.segment_intersects_segment(points[i],points[i+1],beakPos, beakPos+Vector2.UP*1000)
		if cur!=null:
			return cur


var deadT : float
var segmentRippleLeft : int
var segmentRippleRight : int
var dead : bool
@export var timeBetweenRipples : float
var segmentT : float
@export var timeToFree : float
@export var dirtWidthCurve : Curve

func wormDead():
	dead=true
	self_modulate.a=0
	var centralIdx = points.size()/2
	segmentRippleLeft=centralIdx-1
	segmentRippleRight=centralIdx+1
	segmentT=0
	spawnSegPar(points[centralIdx])

func spawnSegPar(pos : Vector2):
	var col : Color=colA.lerp(colB,randf())
	var result : ParSelfFreeCPU = ParticleSpawner.SpawnFromName("DestroyedSegment",pos)
	result.modulate=col
