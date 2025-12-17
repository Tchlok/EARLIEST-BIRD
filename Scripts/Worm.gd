class_name Worm
extends RigidBody2D

var target : Vector2
@export var segmentsPacked : PackedScene
var segments : WormSegments

func _enter_tree():
	Score.EV_WormSpawned.emit(self)

func setup(segCount, widthMod):
	segments = segmentsPacked.instantiate()
	segments.setup(self,segCount,1+MathS.RandSigned()*0.4)
	get_parent().add_child(segments)

func attemptKill(beakPos : Vector2):
	var res = segments.hitCheck(beakPos)
	if res != null:
		print("HIT AT " + str(res))
		kill(res)

func kill(impactPos : Vector2):
	if is_queued_for_deletion():
		return
	Score.EV_WormKilled.emit(self)
	segments.queue_free()
	queue_free()

func _physics_process(delta: float):
	linear_velocity=30*position.direction_to(get_global_mouse_position())
