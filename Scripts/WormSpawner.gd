class_name WormSpawner
extends Node

@export var wormPacked : PackedScene

@export var maxWormCount : int

@export var spawnSideOffsetX : float
@export var spawnSideOffsetRangeY : Vector2

@export var spawnBottomChance : float
@export var spawnBottomOffset : float

@export var spawnCd : float = 1
var curCd : float

@export var layouts : Array[PackedScene]
var l : Node2D

var active : bool


func _ready():
	active=false
	l = layouts.pick_random().instantiate()
	get_parent().add_child.call_deferred(l)



func _physics_process(delta: float):
	if Score.wormsAlive < maxWormCount and active:
		curCd-=delta
		if curCd <= 0:
			curCd=spawnCd
			spawnWorm()



func spawnWorm():
	var spawn : Vector2
	var target : Vector2
	if randf()<=spawnBottomChance:
		spawn.x=lerp(-20,20,randf())
		spawn.y=spawnBottomOffset
		if randf()>0.5:
			target.x=spawnSideOffsetX+100
			target.y=lerp(spawnSideOffsetRangeY.x,spawnSideOffsetRangeY.y,randf())
		else:
			target.x=-spawnSideOffsetX-100
			target.y=lerp(spawnSideOffsetRangeY.x,spawnSideOffsetRangeY.y,randf())

	elif randf()<=0.5:
		spawn.x=-spawnSideOffsetX
		spawn.y=lerp(spawnSideOffsetRangeY.x,spawnSideOffsetRangeY.y,randf())

		target.x=spawnSideOffsetX+100
		target.y=lerp(spawnSideOffsetRangeY.x,spawnSideOffsetRangeY.y,randf())
	else:
		spawn.x=spawnSideOffsetX
		spawn.y=lerp(spawnSideOffsetRangeY.x,spawnSideOffsetRangeY.y,randf())
		
		target.x=-spawnSideOffsetX-100
		target.y=lerp(spawnSideOffsetRangeY.x,spawnSideOffsetRangeY.y,randf())

	var worm : Worm = wormPacked.instantiate()
	worm.position=spawn
	add_child(worm)
	worm.setup(10,1,target,spawnSideOffsetRangeY)

func start():
	active=true
	spawnWorm()
	spawnWorm()
func stop():
	active=false
