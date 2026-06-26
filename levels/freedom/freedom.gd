extends Node2D

@export var scene_house: Node2D
@export var scene_to_stand: Node2D
@export var scene_to_horizon: Node2D
@export var player: AnimationPlayer
@export_file("*.mp3")  var verse_one: String
@export_file("*.mp3")  var verse_two: String
@export_file("*.mp3")  var verse_three: String

func _ready() -> void:
    scene_house.visible = true
    scene_to_stand.visible = false
    scene_to_horizon.visible = false
    player.play(&"Exit House")

    await get_tree().create_timer(1.0).timeout
    AudioHub.play_dialogue(verse_one)
    AudioHub.play_dialogue(verse_two, null, null, _AudioHub.QueueBehaviour.ENQUEUE)
    AudioHub.play_dialogue(verse_three, null, null, _AudioHub.QueueBehaviour.ENQUEUE)
