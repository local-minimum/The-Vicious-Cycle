extends Node2D

@export var good_slice: PackedScene
@export var bad_slice: PackedScene

var over_good: bool

const SLICE_DEGREES: float = 30.0

var _good_areas: Array[Area2D]
var _bad_areas: Array[Area2D]

func _ready() -> void:
    _create_wheel()

func _create_wheel() -> void:
    for child in get_children():
        child.queue_free()

    var pieces: Array[Node2D]
    var needed_good: int = 2
    var slices: int = roundi(360 / SLICE_DEGREES)
    for idx: int in slices:
        var is_good: bool = idx < needed_good
        var n: Node2D = good_slice.instantiate() if is_good else bad_slice.instantiate()
        var area: Area2D = n.find_children("", "Area2D")[0]
        if is_good:
            _good_areas.append(area)
        else:
            _bad_areas.append(area)
        pieces.append(n)

    pieces.shuffle()

    var a: float = randf_range(0.0, 360.0)
    for idx: int in slices:
        var piece: Node2D = pieces[idx]
        add_child(piece)
        piece.position = Vector2.ZERO
        piece.rotation_degrees = a + idx * SLICE_DEGREES

func _on_pointer_area_area_entered(area: Area2D) -> void:
    if _good_areas.has(area):
        over_good = true
    elif _bad_areas.has(area):
        over_good = false
