extends Node2D

@export var front_pedal_spoke: RigidBody2D
@export var back_pedal_spoke: Node2D
@export var wheel: RigidBody2D

@export var angular_speed_decay_per_second: float = 0.1
@export var pedaling_force: float = 2.0
@export var wheel_velocity_factor: float = 0.4

const FRONT_ANGLE_MIN: float = deg_to_rad(42)
const FRONT_ANGLE_MAX: float = deg_to_rad(241)
const BACK_ANGLE_MIN: float = deg_to_rad(-137)
const BACK_ANGLE_MAX: float = deg_to_rad(62)
var _wheel_pos: Vector2

func _ready() -> void:
    _wheel_pos = wheel.position

func _physics_process(delta: float) -> void:
    var balance_force: float = Input.get_axis(&"pedal_right", &"pedal_left")

    _process_speed_decay(delta)

    if balance_force < 0:
        var a: float = fposmod(front_pedal_spoke.global_rotation, TAU)
        var force_direction: float = 1.0 if a >= FRONT_ANGLE_MIN && a <= FRONT_ANGLE_MAX else -1.0
        print_debug(a, balance_force, force_direction, front_pedal_spoke.angular_velocity)
        _apply_force(delta, force_direction * absf(balance_force))
    elif balance_force > 0:
        var a: float = fposmod(back_pedal_spoke.global_rotation + PI, TAU) - PI
        var force_direction: float = 1.0 if a >= BACK_ANGLE_MIN && a <= BACK_ANGLE_MAX else -1.0
        _apply_force(delta, force_direction * absf(balance_force))

    wheel.position = _wheel_pos

func _process_speed_decay(delta: float) -> void:
    front_pedal_spoke.angular_velocity *= (1.0 - delta * angular_speed_decay_per_second)

func _apply_force(delta: float, direction: float) -> void:
    front_pedal_spoke.angular_velocity += direction * delta * pedaling_force
    if front_pedal_spoke.angular_velocity > 0:
        wheel.angular_velocity = wheel_velocity_factor * front_pedal_spoke.angular_velocity / angular_speed_decay_per_second
