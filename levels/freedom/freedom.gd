extends Node2D

@export var scene_house: Node2D
@export var scene_to_stand: Node2D
@export var scene_to_horizon: Node2D
@export var player: AnimationPlayer

func _ready() -> void:
    scene_house.visible = true
    scene_to_stand.visible = false
    scene_to_horizon.visible = false
    player.play(&"Exit House")
