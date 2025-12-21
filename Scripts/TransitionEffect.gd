class_name TransitionEffect
extends Node2D

func _ready():
    TransitionManager.EV_VisualsUpdate.connect(OnVisualsUpdate)

func OnVisualsUpdate(prog:float, modeIn:bool):
    if modeIn:
        modulate.a=prog
    else:
        modulate.a=1-prog