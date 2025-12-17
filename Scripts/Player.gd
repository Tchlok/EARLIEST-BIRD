class_name Player
extends Node2D

@export var peckDepthIndicator : Node2D
@export var walkingSpeed : float
@export var chargingSpeed : float
@export var chargingDuration : float
@export var chargingSlowdownEase : MathS.EasingMethod
var chargingStoredPower : float


@export var walkingAccelerationDuration : float
@export var walkingAccelerationEase : MathS.EasingMethod

@export var flipBoundary : float

@export var peckDepthBase : float
@export var peckDepthScale : float
@export var peckDuration : float
@export var peckCheckWidth : int

var curPeckDepth : float

var curSpeed
var direction : int = 1

@export var beakPoint : Node2D

@export var stunDuration : float

enum PlayerState {Walking, Charging, Pecking, Stunned}
var curState : PlayerState
var stateT : float


func _physics_process(delta: float):
	curSpeed=0
	match curState:
		PlayerState.Walking:
			curSpeed=lerp(0.0, walkingSpeed, MathS.Ease(stateT / chargingDuration, walkingAccelerationEase))
		PlayerState.Charging:
			curSpeed=lerp(walkingSpeed, chargingSpeed, MathS.Ease(stateT / chargingDuration, chargingSlowdownEase))
			chargingStoredPower=MathS.Clamp01(stateT / chargingDuration)
		PlayerState.Pecking:
			beakPoint.position.y=curPeckDepth*MathS.Clamp01(stateT/peckDuration)
			
			#rock
			var query = PhysicsRayQueryParameters2D.create(beakPoint.global_position,beakPoint.global_position+Vector2.UP*1000,2)
			query.collide_with_bodies=true
			var rayResult = get_world_2d().direct_space_state.intersect_ray(query)
			if not rayResult.is_empty():
				var rock : Rock = rayResult["collider"]
				rock.hit()
				changeState(PlayerState.Stunned)
			#worms
			for w in Score.worms:
				w.attemptKill(beakPoint.global_position)
				w.attemptKill(beakPoint.global_position+Vector2.RIGHT*peckCheckWidth)
				w.attemptKill(beakPoint.global_position+Vector2.LEFT*peckCheckWidth)
			if stateT>=peckDuration:
				changeState(PlayerState.Walking)
		PlayerState.Stunned:
			if stateT>=stunDuration:
				changeState(PlayerState.Walking)
	stateT+=delta
	curPeckDepth=peckDepthBase+peckDepthScale*chargingStoredPower
	
	if direction == 1 and position.x > flipBoundary:
		flipDirection()
	elif direction == -1 and position.x < -flipBoundary:
		flipDirection()
	position.x+=direction*curSpeed*delta

func _process(delta: float):
	match curState:
		PlayerState.Walking:
			if Input.is_action_just_pressed("action"):
				changeState(PlayerState.Charging)
		PlayerState.Charging:
			if Input.is_action_just_released("action"):
				changeState(PlayerState.Pecking)
		PlayerState.Pecking:
			pass
		PlayerState.Stunned:
			pass
	
	peckDepthIndicator.position=position+Vector2.DOWN*curPeckDepth

func flipDirection():
	direction*=-1
func stun():
	if curState==PlayerState.Stunned:
		return
	print("Stun")
	changeState(PlayerState.Stunned)

func changeState(newState:PlayerState):
	if curState==newState:
		return
	if curState==PlayerState.Pecking:
		beakPoint.position.y=0
		chargingStoredPower=0
	stateT=0
	curState=newState
