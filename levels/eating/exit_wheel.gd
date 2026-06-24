extends Node2D

@export var wheel: SpinWheel

func _on_mouse_stopper_gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton && !event.is_echo() && (event as InputEventMouseButton).button_index == MOUSE_BUTTON_LEFT:
        if event.is_pressed():
            wheel.spin()
        elif event.is_released():
            wheel.release_spin()
