extends TextureRect

@export var step_progress: TextureProgressBar
@export var step_arrows: Array[TextureRect]
@export_range(1.0, 10.0) var time_per_step: float = 5
@export var step_resistances: Array[int]

func _enter_tree() -> void:
    visible = false
    if __SignalBus.on_start_exercise.connect(_run_program) != OK:
        push_error("Failed to connect start exercise")

func _run_program() -> void:
    step_progress.value = 0
    for arrow: TextureRect in step_arrows:
        arrow.modulate.a = 0
    visible = true
    _run_step(0)
    print_debug("Run steps")

func _run_step(step: int) -> void:
    step_progress.value = 0
    __SignalBus.on_exercise_start_step.emit(step, step_resistances[step])

    var t: Tween = create_tween()
    var arrow = step_arrows[step]
    var arrow_half_blinks: int = floori(time_per_step / 0.5)

    t.set_parallel()
    t.tween_method(
        func (progress: float) -> void:
            var inc = (floori(progress) % 2) == 0
            var blink_progress = progress - floor(progress)
            if inc:
                arrow.modulate.a = lerpf(0, 1, blink_progress)
            else:
                arrow.modulate.a = lerpf(1, 0, blink_progress)
            ,
        0.0,
        float(arrow_half_blinks),
        time_per_step)
    t.tween_property(step_progress, 'value', 100, time_per_step)

    t.finished.connect(func () -> void:
        arrow.modulate.a = 0
        if step + 1 < step_arrows.size():
            _run_step(step + 1)
        else:
            __SignalBus.on_exercise_complete.emit()
        ,
    )
