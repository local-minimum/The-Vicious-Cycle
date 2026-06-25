extends Node2D

@export var small_clock_2200: Node2D
@export var small_clock_0145: Node2D
@export var small_clock_0529: Node2D
@export var small_clock_0530: Node2D
@export var large_clock_colon: Node2D
@export var large_clock_no_colon: Node2D
@export var person_standing: Node2D
@export var person_sitting: Node2D
@export var person_sleeping: Node2D

const _PT_WAKUP_FIRST_EXERCISE: int = 0
const _PT_NIGHT_EXERCISE_OR_SLEEP: int = 8
const _PT_SHORT_SLEEP: int = 9

func _ready() -> void:
    large_clock_colon.visible = false
    large_clock_no_colon.visible = false

    person_standing.visible = false
    person_sitting.visible = false
    person_sleeping.visible = false

    _set_small_clock()

    if GlobalStateVicious.time_checkpoint == _PT_WAKUP_FIRST_EXERCISE:
        _animate_waking_up()
    else:
        _animate_going_to_sleep()

func _set_small_clock() -> void:
    small_clock_0145.visible = false
    small_clock_0529.visible = false
    small_clock_0530.visible = false
    small_clock_2200.visible = false

    match GlobalStateVicious.time_checkpoint:
        _PT_WAKUP_FIRST_EXERCISE:
            small_clock_0529.visible = true
        _PT_NIGHT_EXERCISE_OR_SLEEP:
            small_clock_2200.visible = true
        _PT_SHORT_SLEEP:
            small_clock_0145.visible = true

func _animate_going_to_sleep() -> void:
    await get_tree().create_timer(1.0).timeout
    person_standing.visible = true
    await get_tree().create_timer(1.5).timeout
    person_standing.visible = false
    person_sitting.visible = true
    await get_tree().create_timer(2.0).timeout
    person_sitting.visible = false
    person_sleeping.visible = true
    await get_tree().create_timer(1.5).timeout
    GlobalStateVicious.time_checkpoint = _PT_SHORT_SLEEP
    get_tree().change_scene_to_file(&"res://levels/passage_of_time/passage_of_time.tscn")

func _animate_waking_up() -> void:
    person_sleeping.visible = true

    await get_tree().create_timer(1.0).timeout
    small_clock_0529.visible = false
    small_clock_0530.visible = true
    await get_tree().create_timer(0.5).timeout
    for idx in 15:
        large_clock_colon.visible = (idx % 2) == 0
        large_clock_no_colon.visible = (idx % 2) == 1
        await get_tree().create_timer(0.1).timeout

    large_clock_colon.visible = false
    large_clock_no_colon.visible = false

    await get_tree().create_timer(1.5).timeout
    person_sleeping.visible = false
    person_sitting.visible = true
    await get_tree().create_timer(2.0).timeout
    person_sitting.visible = false
    person_standing.visible = true
    await get_tree().create_timer(1.5).timeout
    get_tree().change_scene_to_file(&"res://levels/spinning/spinning.tscn")
