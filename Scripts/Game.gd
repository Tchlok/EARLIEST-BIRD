class_name Game
extends Node2D
@export var player : Player
@export var spawner : WormSpawner

@export var gameDuration : float
@export var timeToStart : float

@export var gameOverPacked : PackedScene

var step : int
var t : float

var prog : float

@export var uiHolder : Node2D
var targetOpacity : float
@export var targetOpacitySpeed : float

func _enter_tree():
	uiHolder.modulate.a=0
	Score.reset()
	step=0

func _physics_process(delta: float):
	t+=delta
	if uiHolder.modulate.a != targetOpacity:
		uiHolder.modulate.a+=(targetOpacity-uiHolder.modulate.a)*delta*targetOpacitySpeed
	

	match step:
		0:
			if t>=timeToStart:
				player.start()
				spawner.start()
				t=0
				step+=1
				targetOpacity=1
		1:
			if t>=gameDuration:
				player.stop()
				spawner.stop()
				step+=1
				targetOpacity=0
				TransitionManager.TransitionScene("res://Scenes/gameOver.tscn")
