class_name GameOverWorm
extends Node2D

@export var tog : SmoothToggle
@export var sp : Sprite2D
var activateCd : float
func setup(_activateCd : float, _col : Color, _tex : Texture2D, _z : int):
    activateCd = _activateCd
    sp.flip_h=randf()>0.5
    sp.flip_v=randf()>0.5
    sp.modulate=_col
    sp.z_index=_z
    sp.texture=_tex
    sp.rotation_degrees=randf()*360
func _process(delta):
    if activateCd > 0:
        activateCd-=delta
        if activateCd<=0:
            tog.TriggerOn()
            SoundSpawner.SpawnFromName("Click",0.1)
