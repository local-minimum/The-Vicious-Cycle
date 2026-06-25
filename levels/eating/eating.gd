extends Node2D

@export var fridge: Fridge
@export var wheel_mouse_stopper: Control
@export var wheel_base: Node2D
@export var wheel_moving_ui_base: Control
@export var wheel: SpinWheel
@export var show_wheel_btn: Button
@export var hide_wheel_btn: Button
@export var exit_fridge_btn: Button

var good_slices: int = 0

func _enter_tree() -> void:
    if __SignalBus.on_eat.connect(_handle_eat) != OK:
        push_error("Failed to connect handle eat")

    if __SignalBus.on_complete_spin.connect(_handle_complete_spin) != OK:
        push_error("Failed to connect complete spin")

    if __SignalBus.on_start_spin.connect(_handle_start_spin) != OK:
        push_error("Failed to connect start spin")

    if show_wheel_btn.pressed.connect(_handle_show_wheel) != OK:
        push_error("Failed to connect show wheel")

    if hide_wheel_btn.pressed.connect(_handle_hide_wheel) != OK:
        push_error("Failed to connect hide wheel")

    if exit_fridge_btn.pressed.connect(_handle_exit_scene) != OK:
        push_error("Failed to connect exit fridge")

func _ready() -> void:
    exit_fridge_btn.visible = fridge.is_empty()
    show_wheel_btn.visible =  good_slices > 0
    _handle_hide_wheel()

func _handle_eat(food: Food2D) -> void:
    if fridge.is_empty():
        exit_fridge_btn.visible = true
        show_wheel_btn.visible = false
        return

    good_slices += ceili(food.calories / 5.0)
    show_wheel_btn.visible = good_slices > 0

func _handle_show_wheel() -> void:
    wheel_mouse_stopper.visible = true
    wheel_base.visible = true
    wheel_moving_ui_base.visible = true
    show_wheel_btn.visible = false
    hide_wheel_btn.visible = true
    wheel.create_wheel(good_slices)

func _handle_hide_wheel() -> void:
    hide_wheel_btn.visible = false
    wheel_base.visible = false
    wheel_mouse_stopper.visible = false
    wheel_moving_ui_base.visible = false

    if good_slices > 0:
        show_wheel_btn.visible = true

func _handle_exit_scene(_success: bool = false) -> void:
    get_tree().change_scene_to_file(&"res://levels/passage_of_time/passage_of_time.tscn")

func _handle_start_spin() -> void:
    hide_wheel_btn.visible = false

func _handle_complete_spin(success: bool, can_spin_more: bool) -> void:
    if success:
        _handle_exit_scene(true)
        return

    good_slices = maxi(good_slices - 1, 0)
    if !can_spin_more:
        _handle_hide_wheel()
    else:
        hide_wheel_btn.visible = true
