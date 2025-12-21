class_name Player
extends Node2D

@export var peckDepthIndicator : Node2D
var peckDepthIndicatorTargetA : float
@export var peckDepthIndicatorIdleA : float = 0.25
@export var peckDepthIndicatorFadeIn : float = 2
@export var peckDepthIndicatorFadeOut : float = 5

@export var beakSlashPacked : PackedScene

@export var walkingSpeed : float
@export var chargingSpeedMod : float
@export var chargingDuration : float
@export var chargingSlowdownEase : MathS.EasingMethod
var chargingStoredPower : float


@export var walkingAccelerationDuration : float
@export var walkingAccelerationEase : MathS.EasingMethod

@export var flipBoundary : float
@export var fernLeft : Shaker
@export var fernRight : Shaker

@export var peckDepthBase : float
@export var peckDepthScale : float
@export var peckDuration : float
@export var peckCheckWidth : int

@export var hopSinMagMod : float
@export var hopSinMagFlat : float
@export var hopSinFreqMod : float
@export var hopStunnedBounceCurve : Curve
@export var hopStunnedBounceHeight : float
var hopAnchorYDeltaOld : float

@export var leanMod : float
@export var squash : SquashAnchor
@export var squashSecondary : SquashAnchor

var curPeckDepth : float

var curSpeed
var direction : int = 1

@export var beakPoint : Node2D
@export var stunDuration : float

enum PlayerState {Walking, Charging, Pecking, Stunned}
var curState : PlayerState
var stateT : float

@export var walkingBodyTex : Texture2D
@export var chargingBodyTex : Texture2D
@export var peckingBodyTex : Texture2D
@export var stunnedBodyTex : Texture2D

@export var walkingEyeTex : Texture2D
@export var chargingEyeTex : Texture2D
@export var peckingEyeTex : Texture2D
@export var stunnedEyeTex : Texture2D

@export var walkingBeakTex : Texture2D
@export var chargingBeakTex : Texture2D
@export var peckingBeakTex : Texture2D
@export var stunnedBeakTex : Texture2D

@export var bodySp : Sprite2D
@export var eyeSp : Sprite2D
@export var beakSp : Sprite2D
@export var feetSp : Sprite2D

@export var colorNormal : Color
@export var colorCharged : Color
var targetAccentColor : Color
var curAccentColor : Color
var curAccentColorV3 : Vector3
@export var accentColorSpeed :float


@export var anchor : Node2D
var _t : float

@export var cam : Cam

func _ready():
	curState=PlayerState.Stunned
	active=false
	addRampage(0)

func _physics_process(delta: float):
	curSpeed=0
	var rMod : float = lerp(1.0,rampageSpeedMod,rampage)

	match curState:
		PlayerState.Walking:
			
			curSpeed=lerp(0.0, walkingSpeed, MathS.Ease(stateT / chargingDuration, walkingAccelerationEase))*rMod
		PlayerState.Charging:
			curSpeed=lerp(walkingSpeed, walkingSpeed*chargingSpeedMod, MathS.Ease(stateT / chargingDuration, chargingSlowdownEase))*rMod
			chargingStoredPower=MathS.Clamp01(stateT / (chargingDuration / lerp(1.0,rampageChargeMod,rampage)))
			targetAccentColor=colorNormal.lerp(colorCharged,chargingStoredPower)
			peckDepthIndicatorTargetA=lerp(peckDepthIndicatorIdleA, 1.0,chargingStoredPower)
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
				var success : int = 0
				success+=w.attemptKill(beakPoint.global_position)
				success+=w.attemptKill(beakPoint.global_position)
				success+=w.attemptKill(beakPoint.global_position+Vector2.RIGHT*peckCheckWidth)
				success+=w.attemptKill(beakPoint.global_position+Vector2.RIGHT*peckCheckWidth)
				success+=w.attemptKill(beakPoint.global_position+Vector2.LEFT*peckCheckWidth)
				success+=w.attemptKill(beakPoint.global_position+Vector2.LEFT*peckCheckWidth)
				for i in range(success):
					addRampage(rampagePerKill)

			if stateT>=peckDuration:
				changeState(PlayerState.Walking)
		PlayerState.Stunned:
			if stateT>=stunDuration:
				changeState(PlayerState.Walking)
	stateT+=delta
	curPeckDepth=peckDepthBase+peckDepthScale*chargingStoredPower
	
	if direction == 1 and position.x > flipBoundary:
		flipDirection()
		fernRight.Trigger(2)
	elif direction == -1 and position.x < -flipBoundary:
		flipDirection()
		fernLeft.Trigger(2)
	position.x+=direction*curSpeed*delta

func _process(delta: float):
	
	if active:
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
	
	_t+=delta
	var hopAnchorYDelta : float = anchor.position.y
	anchor.position.y=-MathS.Sin01(_t*(hopSinFreqMod))*((hopSinMagMod*curSpeed)+hopSinMagFlat)
	hopAnchorYDelta-=anchor.position.y
	if sign(hopAnchorYDelta)!=sign(hopAnchorYDeltaOld) and sign(hopAnchorYDelta)==1:
		feetSp.flip_h=not feetSp.flip_h
	peckDepthIndicator.position=Vector2.DOWN*curPeckDepth
	if curState==PlayerState.Stunned:
		anchor.position.y=hopStunnedBounceCurve.sample(MathS.Clamp01(stateT/stunDuration))*hopStunnedBounceHeight*-1
	anchor.rotation_degrees=direction*curSpeed*leanMod
	
	hopAnchorYDeltaOld=hopAnchorYDelta
	
	if peckDepthIndicator.modulate.a != peckDepthIndicatorTargetA:
		var mod = peckDepthIndicatorFadeIn if peckDepthIndicatorTargetA>peckDepthIndicator.modulate.a else peckDepthIndicatorFadeOut
		peckDepthIndicator.modulate.a+=(peckDepthIndicatorTargetA-peckDepthIndicator.modulate.a)*mod*delta
		if abs(peckDepthIndicator.modulate.a-peckDepthIndicatorTargetA)<0.02:
			peckDepthIndicator.modulate.a=peckDepthIndicatorTargetA
	
	if curAccentColor!=targetAccentColor:
		var targetColV3 = Vector3(targetAccentColor.r,targetAccentColor.g,targetAccentColor.b)
		curAccentColorV3+=(targetColV3-curAccentColorV3)*delta*accentColorSpeed
		curAccentColor=Color(curAccentColorV3.x,curAccentColorV3.y,curAccentColorV3.z,curAccentColor.a)
		beakSp.modulate=curAccentColor
		eyeSp.modulate=curAccentColor
		peckDepthIndicator.get_child(0).modulate=Color(curAccentColor.r,curAccentColor.g,curAccentColor.b,peckDepthIndicator.modulate.a)

func flipDirection():
	direction*=-1
	squashSecondary.TriggerSquash(0.1)

func changeState(newState:PlayerState):
	if curState==newState:
		return
	if curState==PlayerState.Pecking:
		beakPoint.position.y=0
		chargingStoredPower=0
	stateT=0
	curState=newState
	match curState:
		PlayerState.Walking:
			peckDepthIndicatorTargetA=peckDepthIndicatorIdleA
			bodySp.texture=walkingBodyTex
			eyeSp.texture=walkingEyeTex
			beakSp.texture=walkingBeakTex
			targetAccentColor=colorNormal
		PlayerState.Charging:
			bodySp.texture=chargingBodyTex
			eyeSp.texture=chargingEyeTex
			beakSp.texture=chargingBeakTex
			squash.TriggerStretch(SquashAnchor.Small)
		PlayerState.Pecking:
			peckDepthIndicatorTargetA=0
			bodySp.texture=peckingBodyTex
			eyeSp.texture=peckingEyeTex
			beakSp.texture=peckingBeakTex
			squash.TriggerSquash(SquashAnchor.Medium)

			var slashInstance : BeakSlash = beakSlashPacked.instantiate()
			slashInstance.setup(self, curAccentColor)
			get_parent().add_child(slashInstance)


		PlayerState.Stunned:
			targetAccentColor=colorNormal
			peckDepthIndicatorTargetA=0
			bodySp.texture=stunnedBodyTex
			eyeSp.texture=stunnedEyeTex
			beakSp.texture=stunnedBeakTex
			squash.TriggerStretch(SquashAnchor.Medium)
			addRampage(-rampageStunLoss)
			cam.triggerRock()

var active : bool
func start():
	active=true
	changeState(PlayerState.Walking)
	if Input.is_action_pressed("action"):
		changeState(PlayerState.Charging)
func stop():
	active=false
	changeState(PlayerState.Walking)
	walkingSpeed=0

var rampage : float = 0
@export var rampagePerKill : float
@export var rampageStunLoss : float
@export var rampageSpeedMod : float
@export var rampageChargeMod : float
@export var rampageDisplay : RampageDisplay

func addRampage(amount : float):
	var delta = rampage
	rampage=MathS.Clamp01(rampage+amount)
	delta=-(delta-rampage)
	rampageDisplay.update(rampage,delta)
