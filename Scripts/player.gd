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

var curPeckDepth : float

var curSpeed
var direction : int = 1

@export var beakArea : Area2D

@export var stunDuration : float

enum PlayerState {Walking, Charging, Pecking, Stunned}
var curState : PlayerState
var stateT : float

func _ready():
	beakArea.body_entered.connect(onBeakBodyEntered)

func _physics_process(delta: float):
	curSpeed=0
	match curState:
		PlayerState.Walking:
			curSpeed=lerp(0.0, walkingSpeed, MathS.Ease(stateT / chargingDuration, walkingAccelerationEase))
		PlayerState.Charging:
			curSpeed=lerp(walkingSpeed, chargingSpeed, MathS.Ease(stateT / chargingDuration, chargingSlowdownEase))
			chargingStoredPower=MathS.Clamp01(stateT / chargingDuration)
		PlayerState.Pecking:
			beakArea.position.y=curPeckDepth*MathS.Clamp01(stateT/peckDuration)
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
		beakArea.position.y=0
		chargingStoredPower=0
	stateT=0
	curState=newState

func onBeakBodyEntered(body : Node2D):
	if body is Worm:
		var worm : Worm=body
		worm.kill()
	elif body is Rock:
		var rock : Rock=body
		rock.hit()
		stun()
