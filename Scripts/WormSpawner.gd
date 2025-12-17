extends Node

@export var wormPacked : PackedScene

@export var maxWormCount : int

@export var spawnSideOffsetX : float
@export var spawnSideOffsetRangeY : Vector2

@export var spawnBottomChance : float
@export var spawnBottomOffset : float

func _ready():
    for i in range(maxWormCount):
        spawnWorm(getWormSpawnPoint())

#TODO remove test input action
func _process(delta):
    if Input.is_action_just_pressed("test"):
        spawnWorm(getWormSpawnPoint())

func getWormSpawnPoint():
    var result : Vector2
    if randf()<=spawnBottomChance:
        result.x=lerp(-spawnSideOffsetX,spawnSideOffsetX,randf())
        result.y=spawnBottomOffset
    elif randf()<=0.5:
        result.x=-spawnSideOffsetX
        result.y=lerp(spawnSideOffsetRangeY.x,spawnSideOffsetRangeY.y,randf())
    else:
        result.x=spawnSideOffsetX
        result.y=lerp(spawnSideOffsetRangeY.x,spawnSideOffsetRangeY.y,randf())
    return result

func spawnWorm(pos : Vector2):
    var worm : Worm = wormPacked.instantiate()
    worm.position=pos
    add_child(worm)
    worm.setup(10,1)