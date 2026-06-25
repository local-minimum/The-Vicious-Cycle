extends Node2D

@export var front_pedal_spoke: RigidBody2D
@export var back_pedal_spoke: Node2D
@export var wheel: RigidBody2D

@export var spinning_settings: Array[SpinningSetting]

@export var collapse_joints: Array[Joint2D]
var collapsed: bool
var completed: bool

const FRONT_ANGLE_MIN: float = deg_to_rad(42)
const FRONT_ANGLE_MAX: float = deg_to_rad(241)
const BACK_ANGLE_MIN: float = deg_to_rad(-137)
const BACK_ANGLE_MAX: float = deg_to_rad(62)
var _wheel_pos: Vector2
var _active_setting: int = 0

func _enter_tree() -> void:
    if __SignalBus.on_exercise_no_calories.connect(_handle_no_calories) != OK:
        push_error("Failed to connect no calories")
    if __SignalBus.on_exercise_start_step.connect(_handle_start_spin_step) != OK:
        push_error("Failed to connect exercise start step")
    if __SignalBus.on_exercise_complete.connect(_handle_spinning_complete) != OK:
        push_error("Failed to connect spinning complete")

func _handle_start_spin_step(_step: int, resistance: int) -> void:
    _active_setting = resistance - 1

func _handle_spinning_complete() -> void:
    completed = true
    await get_tree().create_timer(1.0).timeout
    get_tree().change_scene_to_file(&"res://levels/passage_of_time/passage_of_time.tscn")

func _handle_no_calories() -> void:
    for joint: Joint2D in collapse_joints:
        joint.queue_free()
    collapsed = true
    GlobalStateVicious.crisis_counter += 1
    await get_tree().create_timer(5.0).timeout
    get_tree().change_scene_to_file(&"res://levels/passage_of_time/passage_of_time.tscn")

func _ready() -> void:
    completed = false
    _wheel_pos = wheel.position
    __SignalBus.on_start_exercise.emit()

func _physics_process(delta: float) -> void:
    var balance_force: float = Input.get_axis(&"pedal_right", &"pedal_left")

    _process_speed_decay(delta)

    if !collapsed && !completed:
        if balance_force < 0:
            var a: float = fposmod(front_pedal_spoke.global_rotation, TAU)
            var force_direction: float = 1.0 if a >= FRONT_ANGLE_MIN && a <= FRONT_ANGLE_MAX else -1.0
            _apply_force(delta, force_direction * absf(balance_force))
        elif balance_force > 0:
            var a: float = fposmod(back_pedal_spoke.global_rotation + PI, TAU) - PI
            var force_direction: float = 1.0 if a >= BACK_ANGLE_MIN && a <= BACK_ANGLE_MAX else -1.0
            _apply_force(delta, force_direction * absf(balance_force))

    wheel.position = _wheel_pos


func _process_speed_decay(delta: float) -> void:
    front_pedal_spoke.angular_velocity *= (1.0 - delta * spinning_settings[_active_setting].angular_speed_decay_per_second)

func _apply_force(delta: float, direction: float) -> void:
    var setting: SpinningSetting = spinning_settings[_active_setting]
    var effort = direction * delta * setting.pedaling_force
    front_pedal_spoke.angular_velocity += effort
    if front_pedal_spoke.angular_velocity > 0:
        wheel.angular_velocity = setting.wheel_velocity_factor * front_pedal_spoke.angular_velocity / setting.angular_speed_decay_per_second
    if effort > 0:
        __SignalBus.on_exercise.emit(effort / setting.angular_speed_decay_per_second)
