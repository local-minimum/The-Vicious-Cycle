extends StaticBody2D

@export var front_pedal: RigidBody2D

var _offset_angle: float

func _ready() -> void:
    _offset_angle = global_rotation - front_pedal.global_rotation

func _physics_process(_delta: float) -> void:
    global_rotation = front_pedal.global_rotation + _offset_angle
