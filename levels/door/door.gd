extends Node2D

enum Icon { EXIT, EXERCISE, UNDECIDED }
enum Phase { LOCKED, SLIDING, READY, SPINNING, SPUN, DONE }

@export var icon_exit: PackedScene
@export var icon_exercise: PackedScene
@export var icon_undecided: PackedScene
@export var icon_height: float = 96

@export var slider: Node2D
@export var lock: Node2D
@export var slider_duration: float = 1.0
@export var slider_distance: float = 222

@export var handle: Node2D
@export var handle_motion_duration: float = 0.8
@export var cylinders: Array[Node2D]
@export var cylinder_left: Array[Icon]
@export var cylinder_mid: Array[Icon]
@export var cylinder_right: Array[Icon]
@export var cylinder_spin_duration: float = 0.5
@export var cylinder_spin_length: Array[int] = [11, 12, 14]

var _cylinder_offsets: Array[int] = [0, 0, 0]

var _phase = Phase.LOCKED

func _ready() -> void:
    build_cylinders()

var _cylinder_icons: Array[Array] = []

func build_cylinders() -> void:
    for cyl: Node2D in cylinders:
        for child in cyl.get_children():
             child.queue_free()
    _cylinder_icons.clear()

    for idx in cylinders.size():
        var icons: Array[Node2D] = []
        _cylinder_icons.append(icons)
        var cyl: Node2D = cylinders[idx]
        for icon: Icon in get_icons(idx):
            var scene: PackedScene = get_icon_scene(icon)
            var n: Node2D = scene.instantiate()
            cyl.add_child(n)
            icons.append(n)

        set_cylinder(idx, 0.0)


func get_icons(cyl_idx: int) -> Array[Icon]:
    if posmod(cyl_idx, 3) == 0:
        return cylinder_left
    if posmod(cyl_idx, 3) == 1:
        return cylinder_mid
    return cylinder_right

func get_icon_scene(icon: Icon) -> PackedScene:
    match icon:
        Icon.EXIT:
            return icon_exit
        Icon.EXERCISE:
            return icon_exercise
        Icon.UNDECIDED:
            return icon_undecided
    return null

func _input(event: InputEvent) -> void:
    if _phase == Phase.LOCKED || _phase == Phase.READY:
        if event is InputEventMouseButton && !event.is_echo() && event.is_pressed() && (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
            if _phase == Phase.LOCKED:
                _phase = Phase.SLIDING
                var t = create_tween()
                t.set_parallel()
                t.tween_property(slider, "position:x", slider.position.x - slider_distance, slider_duration)
                t.tween_property(lock, "rotation_degrees", -170.0, slider_duration)
                t.finished.connect(_done_sliding)
            elif _phase == Phase.READY:
                var t = create_tween()
                t.tween_property(handle, "rotation_degrees", -30.0, handle_motion_duration)
                t.tween_property(handle, "rotation_degrees", 0.0, handle_motion_duration * 0.3)
                _phase = Phase.SPINNING
                t0 = Time.get_ticks_msec()

var t0: int

func _process(_delta: float) -> void:
    match _phase:
        Phase.SPINNING:
            _spin()

func _spin() -> void:
    var elapsed: float = (Time.get_ticks_msec() - t0) * 0.001
    var offset: float = elapsed / cylinder_spin_duration
    if offset < 1.0:
        offset *= offset
    var done: bool = true
    for idx in _cylinder_icons.size():
        done = set_cylinder(idx, offset) && done

    if done:
        var results: Array[Icon] = []
        for idx in _cylinder_offsets.size():
            var icons = get_icons(idx)
            _cylinder_offsets[idx] = posmod(_cylinder_offsets[idx] + cylinder_spin_length[idx], _cylinder_icons[idx].size())
            results.append(icons[posmod(2 - _cylinder_offsets[idx], icons.size())])

        print_debug(results.map(func (i: Icon) -> String: return Icon.find_key(i)))

        if results.has(Icon.EXERCISE):
            _phase = Phase.DONE
            push_warning("No transition to fail yet")
        elif results.has(Icon.UNDECIDED):
            _phase = Phase.READY
        else:
            _phase = Phase.DONE
            push_warning("No transition to success yet")

func set_cylinder(idx: int, offset: float) -> bool:
    var icons: Array[Node2D] = _cylinder_icons[idx]
    var off: float = min(offset, cylinder_spin_length[idx])
    var n: int = icons.size()

    for icon_idx: int in n:
        var icon_off: float = fposmod(off + icon_idx + _cylinder_offsets[idx], n)
        icons[icon_idx].position = Vector2.DOWN * icon_off * icon_height

    return off < offset

func _done_sliding() -> void:
    _phase = Phase.READY
