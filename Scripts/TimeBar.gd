class_name TimeBar
extends Node2D

@export var lineMain : Line2D
@export var lineBg : Line2D
@export var lineOutline : Line2D
@export var outlineLineWidthExtra : float
@export var outlineWidthExtra : float
@export var game : Game
@export var lineWidth : float
@export var width : float

@export var colStart : Color
@export var colEnd : Color
@export var colBg : Color
@export var colOutline : Color

func _ready():
    lineMain.set_point_position(0,Vector2(-width/2, 0))
    lineMain.set_point_position(1,Vector2(width/2, 0))
    lineBg.points=lineMain.points
    lineOutline.points=lineMain.points
    lineOutline.set_point_position(0, lineOutline.points[0]+Vector2.LEFT*outlineWidthExtra/2)
    lineOutline.set_point_position(1, lineOutline.points[1]+Vector2.RIGHT*outlineWidthExtra/2)

    lineMain.width=lineWidth
    lineBg.width=lineWidth
    lineOutline.width=lineWidth+outlineLineWidthExtra

    lineBg.modulate=colBg
    lineOutline.modulate=colOutline
    updateLineMain()

func updateLineMain():
    var p : float = MathS.Clamp01(game.t/game.gameDuration)
    lineMain.set_point_position(1,lineMain.points[0]+Vector2.RIGHT*p*width)
    lineMain.modulate=colStart.lerp(colEnd,p)

func _physics_process(delta):
    updateLineMain()
