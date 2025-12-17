extends Area2D

@export var colors : Array[Color]
@export var startOffset : Vector2

var line : Line2D
var sp : Sprite2D
var flowerVelocity : Vector2

@export var minScale : float
@export var maxScale : float
@export var ease : MathS.EasingMethod

@export var springDamp : float
@export var springRigid : float

@export var pushImpactMod : float
@export var pushCd : float
var curCd : float

func _enter_tree():
	line=get_child(0)
	sp=get_child(1)
	sp.modulate=colors.pick_random()
	sp.rotation_degrees=randf()*360
	sp.position=startOffset
	sp.scale=Vector2.ONE*lerp(minScale,maxScale,randf())
	area_entered.connect(_onAreaEntered)

func _process(delta):
	var p : float
	for i in range(line.points.size()):
		p=i/float(line.points.size()-1)
		line.points[i].y=sp.position.y*p
		line.points[i].x=sp.position.x*MathS.Ease(p,ease)
	var toStartOffset : Vector2 = sp.position-startOffset
	flowerVelocity += -springRigid*toStartOffset-(springDamp*flowerVelocity)
	sp.position+=flowerVelocity*delta

	if curCd>0:
		curCd-=delta
		if curCd <=0:
			monitoring=true


func _onAreaEntered(other : Area2D):
	var p : Player = other.get_parent()
	if p.curState==Player.PlayerState.Stunned:
		return
	sp.position+=Vector2.RIGHT*p.curSpeed*p.direction*pushImpactMod
	sp.position+=Vector2.DOWN*2
	sp.rotation_degrees+=p.curSpeed*p.direction*0.5
	curCd=pushCd
	set_deferred("monitoring",false)
