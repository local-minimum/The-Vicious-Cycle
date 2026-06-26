extends Node2D

@export var direction: float = 1.0
@export var child_rotation: float = 0.0

func _process(delta: float) -> void:
    rotation += direction * delta

    if child_rotation == 0.0:
        return

    for child in get_children():
        if child is Node2D:
            var c: Node2D = child
            c.rotation += child_rotation * delta
