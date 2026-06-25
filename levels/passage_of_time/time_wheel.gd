extends Node2D

@export var _wheel: Node2D
@export var _bed: Node2D
@export var _short_sleep_bed: Node2D

@export var _night_line: Node2D
@export var _night_line_start_angle: float = -50.0

@export var _night_exercise: Node2D

@export var _short_night_tween_duration: float = 1.0

@export var _first_day_angle_start: float = -164.0
@export var _checkpoint_time_angles: Array[float]

@export var _angle_rotation_duration: float = 0.1
@export var _wait_before_next_scene: float = 1.0


const _PT_WAKUP_FIRST_EXERCISE: int = 0
const _PT_BREAKFAST: int = 1
const _PT_SECOND_EXERCISE: int = 2
const _PT_LUNCH: int = 3
const _PT_DOOR_CHECK: int = 4
const _PT_THIRD_EXERCISE: int = 5
const _PT_SUPPER: int = 6
const _PT_ATTEMPT_SLEEP: int = 7
const _PT_NIGHT_EXERCISE_OR_SLEEP: int = 8
const _PT_SHORT_SLEEP: int = 9

func _ready() -> void:
    if GlobalStateVicious.time_checkpoint < _PT_WAKUP_FIRST_EXERCISE:
        _wheel.rotation_degrees = _first_day_angle_start
    else:
        _wheel.rotation_degrees = _checkpoint_time_angles[GlobalStateVicious.time_checkpoint]

    if GlobalStateVicious.time_checkpoint == _PT_NIGHT_EXERCISE_OR_SLEEP:
        _night_line.visible = true
        _night_exercise.visible = true
        _night_exercise.rotation = 0
        _bed.position = _short_sleep_bed.position
        _bed.rotation = _short_sleep_bed.rotation
    else:
        _night_line.visible = false
        _night_exercise.visible = false

    await get_tree().create_timer(_wait_before_next_scene).timeout
    progress_time()

func progress_time() -> void:
    var next_time: int = posmod(GlobalStateVicious.time_checkpoint + 1, 10)

    if next_time == 0:
        GlobalStateVicious.day += 1
        print_debug("Gain one crisis from new day")
        GlobalStateVicious.crisis_counter += 1

    var target_a: float = _checkpoint_time_angles[next_time]
    var delta: float = target_a - _wheel.rotation_degrees

    if delta < -180:
        delta += 360
    elif delta > 180:
        delta -= 360

    var duration: float = absf(delta) * _angle_rotation_duration

    GlobalStateVicious.time_checkpoint = next_time

    var t: Tween = create_tween()
    t.tween_property(_wheel, "rotation_degrees", _wheel.rotation_degrees + delta, duration)
    t.finished.connect(_handle_reach_checkpoint)

var _short_sleep: bool = false

func _handle_reach_checkpoint() -> void:
    match GlobalStateVicious.time_checkpoint:
        _PT_BREAKFAST, _PT_LUNCH, _PT_SUPPER:
            await get_tree().create_timer(_wait_before_next_scene).timeout
            get_tree().change_scene_to_file(&"res://levels/eating/eating.tscn")

        _PT_ATTEMPT_SLEEP:
            if GlobalStateVicious.happiness < 20.0 || GlobalStateVicious.calories > 60.0:
                _short_sleep = true
                tween_to_short_sleep()
                progress_time()
            else:
                _short_sleep = false
                progress_time()

        _PT_SECOND_EXERCISE, _PT_THIRD_EXERCISE:
            await get_tree().create_timer(_wait_before_next_scene).timeout
            get_tree().change_scene_to_file(&"res://levels/spinning/spinning.tscn")

        _PT_NIGHT_EXERCISE_OR_SLEEP:
            if _short_sleep:
                await get_tree().create_timer(_wait_before_next_scene * 3).timeout
                get_tree().change_scene_to_file(&"res://levels/spinning/spinning.tscn")
            else:
                await get_tree().create_timer(_wait_before_next_scene).timeout
                get_tree().change_scene_to_file(&"res://levels/sleeping/bed_room.tscn")

        _PT_SHORT_SLEEP:
            await get_tree().create_timer(_wait_before_next_scene).timeout
            get_tree().change_scene_to_file(&"res://levels/sleeping/bed_room.tscn")

        _PT_DOOR_CHECK:
            await get_tree().create_timer(_wait_before_next_scene).timeout
            get_tree().change_scene_to_file(&"res://levels/door/exit_appartment_check.tscn")

        _PT_WAKUP_FIRST_EXERCISE:
            await get_tree().create_timer(_wait_before_next_scene).timeout
            get_tree().change_scene_to_file(&"res://levels/sleeping/bed_room.tscn")

func tween_to_short_sleep() -> void:
    _night_line.rotation_degrees = _night_line_start_angle
    _night_line.visible = true

    var t: Tween = create_tween()
    t.set_parallel()
    t.tween_property(_night_line, "rotation_degrees", 0.0, _short_night_tween_duration)
    t.tween_property(_bed, "position", _short_sleep_bed.position, _short_night_tween_duration)
    t.tween_property(_bed, "rotation", _short_sleep_bed.rotation, _short_night_tween_duration)
    t.finished.connect(func() -> void:
        _night_exercise.visible = true
    )
