extends Node2D
class_name Door

enum Icon { EXIT, EXERCISE, UNDECIDED }
enum Phase { LOCKED, SLIDING, READY, SPINNING, SPUN, DONE }

@export var icon_exit: PackedScene
@export var icon_exercise: PackedScene
@export var icon_undecided: PackedScene

@export var replace_exit: Texture2D
@export var replace_exercise: Texture2D
@export var replace_undecided: Texture2D

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

@export var crisis_mods: Array[SlotModification]

@export var mouse: Node2D
@export var mouse_anim: AnimationPlayer

#region SaveState
var _cylinder_offsets: Array[int] = [0, 0, 0]
#endregion

var _phase = Phase.LOCKED

func _ready() -> void:
    if GlobalStateVicious.door_cylinder_offsets.size() > 0:
        _cylinder_offsets.clear()
        for off: int in GlobalStateVicious.door_cylinder_offsets:
            _cylinder_offsets.append(off)

    build_cylinders()
    await get_tree().create_timer(2.0).timeout
    if _phase == Phase.LOCKED:
        mouse.visible = true
        mouse_anim.play(&"click")

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
        var icon_idx: int = 0
        for icon: Icon in get_icons(idx):
            var scene: PackedScene = get_icon_scene(icon)
            var n: Node2D = scene.instantiate()
            var mod: SlotModification = get_mod(idx, icon_idx)

            if mod:
                var replace_ico: Texture2D = get_replacement_icons(mod.icon)
                var replace_sprite: Sprite2D = Sprite2D.new()
                replace_sprite.texture = replace_ico
                replace_sprite.rotation_degrees = randf_range(-2.0, 2.0)
                if replace_sprite.rotation_degrees < 0:
                    replace_sprite.rotation_degrees -= 2.0
                else:
                    replace_sprite.rotation_degrees += 2.0
                n.add_child(replace_sprite)

            cyl.add_child(n)
            icons.append(n)
            icon_idx += 1

        set_cylinder(idx, 0.0)

func get_mod(cyl_idx: int, icon_idx: int) -> SlotModification:
    if GlobalStateVicious.day == 1:
        return

    var mod_idx: int = crisis_mods.find_custom(func (mod: SlotModification) -> bool: return mod.cylinder == cyl_idx && mod.position == icon_idx)
    if mod_idx < 0 || mod_idx >= GlobalStateVicious.crisis_counter:
        return null
    return crisis_mods[mod_idx]

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

func get_replacement_icons(icon: Icon) -> Texture2D:
    match icon:
        Icon.EXIT:
            return replace_exit
        Icon.EXERCISE:
            return replace_exercise
        Icon.UNDECIDED:
            return replace_undecided
    return null

func _input(event: InputEvent) -> void:
    if _phase == Phase.LOCKED || _phase == Phase.READY:
        if event is InputEventMouseButton && !event.is_echo() && event.is_pressed() && (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
            if _phase == Phase.LOCKED:
                mouse.visible = false
                _phase = Phase.SLIDING
                var t = create_tween()
                t.set_parallel()
                t.tween_property(slider, "position:x", slider.position.x - slider_distance, slider_duration)
                t.tween_property(lock, "rotation_degrees", -170.0, slider_duration)
                t.finished.connect(_done_sliding)
            elif _phase == Phase.READY:
                mouse.visible = false
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
            var icon_idx: int = posmod(2 - _cylinder_offsets[idx], icons.size())
            var mod: SlotModification = get_mod(idx, icon_idx)
            if mod:
                results.append(mod.icon)
            else:
                results.append(icons[icon_idx])

        #print_debug(results.map(func (i: Icon) -> String: return Icon.find_key(i)))
        GlobalStateVicious.door_cylinder_offsets.clear()
        for off: int in  _cylinder_offsets:
            GlobalStateVicious.door_cylinder_offsets.append(off)

        if results.has(Icon.EXERCISE):
            _phase = Phase.DONE
            await get_tree().create_timer(1.0).timeout
            get_tree().change_scene_to_file(&"res://levels/passage_of_time/passage_of_time.tscn")
        elif results.has(Icon.UNDECIDED):
            _phase = Phase.READY
        else:
            _phase = Phase.DONE
            get_tree().change_scene_to_file(&"res://levels/freedom/freedom.tscn")

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
    await get_tree().create_timer(2.0).timeout
    if _phase == Phase.READY:
        mouse.visible = true
        mouse_anim.play(&"click")
