class_name Worm
extends RigidBody2D

var target : Vector2
@export var segmentsPacked : PackedScene
var segments : WormSegments
@export var nav : NavigationAgent2D

@export var targetRerollCd : float
var rerollRemainingTime : float
@export var targetRerollChance : float
var spawnSideOffsetRangeY : Vector2

func _enter_tree():
	Score.EV_WormSpawned.emit(self)
	rerollRemainingTime=targetRerollCd*randf()

func setup(segCount, widthMod, endPosition,_spawnSideOffsetRangeY):
	segments = segmentsPacked.instantiate()
	segments.setup(self,segCount,1+MathS.RandSigned()*0.4)
	get_parent().add_child(segments)
	nav.target_position=endPosition
	spawnSideOffsetRangeY=_spawnSideOffsetRangeY

func attemptKill(beakPos : Vector2):
	var res = segments.hitCheck(beakPos)
	if res != null:
		if is_queued_for_deletion():
			return 0
		kill(res,true)
		return 1
	return 0

func kill(impactPos : Vector2, credit : bool):
	if is_queued_for_deletion():
		return
	Score.EV_WormKilled.emit(self,credit)
	segments.wormDead()
	queue_free()

func _physics_process(delta: float):
	if nav.is_target_reached():
		kill(Vector2.ZERO,false)
	else:
		var dir : Vector2
		dir=position.direction_to(nav.get_next_path_position())
		linear_velocity=dir*30
