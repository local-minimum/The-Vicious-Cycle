extends Node2D

@export var good_slice: PackedScene
@export var bad_slice: PackedScene
@export var peak_spin: float = PI * 1.5
@export var decay_spin: float = 0.4
var over_good: bool

const STOPPING_VELOCITY: float = 0.01
const SLICE_DEGREES: float = 30.0

var _good_areas: Array[Area2D]
var _bad_areas: Array[Area2D]
var _good_slice: Node2D

func _ready() -> void:
    _create_wheel()
    spin()
    release_spin()

func _create_wheel(good_slices: int = 2) -> void:
    for child in get_children():
        child.queue_free()

    var pieces: Array[Node2D]
    var slices: int = roundi(360 / SLICE_DEGREES)
    _good_slice = null

    for idx: int in slices:
        var is_good: bool = idx < good_slices
        var n: Node2D = good_slice.instantiate() if is_good else bad_slice.instantiate()
        if idx == 0 && is_good:
            _good_slice = n

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

    _phase = Phase.UNSPUN

func _on_pointer_area_area_entered(area: Area2D) -> void:
    if _good_areas.has(area):
        over_good = true
    elif _bad_areas.has(area):
        over_good = false

enum Phase { UNSPUN, SPIN, PEAKED, RELEASED, STOPPED }
var _phase: Phase = Phase.UNSPUN
var _held: bool
var _angular_velocity: float = 0.0

func spin() -> void:
    if _phase != Phase.UNSPUN:
        return

    _phase = Phase.SPIN
    _held = true
    _angular_velocity = 0.0


func release_spin() -> void:
    if !_held:
        return

    _held = false
    if _phase == Phase.PEAKED:
        _phase = Phase.RELEASED

func _process(delta: float) -> void:
    match _phase:
        Phase.SPIN:
            _angular_velocity = clampf(_angular_velocity + delta * peak_spin, 0.0, peak_spin)
            if _angular_velocity == peak_spin:
                _phase = Phase.PEAKED
            _spin(delta)

        Phase.PEAKED:
            if !_held:
                _phase = Phase.RELEASED
            _spin(delta)

        Phase.RELEASED:
            _angular_velocity *= 1.0 - delta * decay_spin
            if _angular_velocity < STOPPING_VELOCITY:
                _handle_spin_end()
            else:
                _spin(delta)

func _spin(delta: float) -> void:
    rotation += delta * _angular_velocity


func _handle_spin_end() -> void:
    _angular_velocity = 0.0
    _phase = Phase.STOPPED
    if over_good:
        __SignalBus.on_complete_spin.emit(true)
    elif _good_slice != null:

        await get_tree().create_timer(0.5).timeout
        var a = _good_slice.rotation

        var n: Node2D = bad_slice.instantiate()
        add_child(n)
        n.rotation = a

        await get_tree().create_timer(0.3).timeout

        n.visible = false
        await get_tree().create_timer(0.1).timeout

        n.visible = true
        await get_tree().create_timer(0.3).timeout

        n.visible = false
        await get_tree().create_timer(0.1).timeout

        n.visible = true
        _good_slice.queue_free()

        __SignalBus.on_complete_spin.emit(false)
    else:
        __SignalBus.on_complete_spin.emit(false)
