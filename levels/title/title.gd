extends Node2D

@export var player: AnimationPlayer
@export var storage_provider: SaveStorageProvider

func _ready() -> void:
    player.play(&"Blinking Press")

func _input(event: InputEvent) -> void:
    if event is InputEventMouseButton && (event as InputEventMouseButton).is_pressed():
        _load_game()
        return

    if event is InputEventKey && (event as InputEventKey).is_pressed():
        _load_game()
        return

    if event is InputEventJoypadButton:
        var jevt: InputEventJoypadButton = event
        if jevt.is_pressed() && [JOY_BUTTON_A, JOY_BUTTON_B, JOY_BUTTON_X, JOY_BUTTON_Y].has(jevt.button_index):
            _load_game()
            return

func _load_game() -> void:
    GlobalState.reset(storage_provider)
    get_tree().change_scene_to_file(&"res://levels/passage_of_time/passage_of_time.tscn")
