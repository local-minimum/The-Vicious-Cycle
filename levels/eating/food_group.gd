extends Area2D
class_name FoodGroup

@export var pieces: Array[Node2D]
@export var food: Food2D
@export var click_to_eat: bool = true

static var _focus_food: FoodGroup
var _clicked_focus: bool

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
    if event is InputEventMouseButton:
        var m_event: InputEventMouseButton = event
        if m_event.is_echo() || !m_event.is_pressed() || m_event.button_index != MOUSE_BUTTON_LEFT:
            return
    else:
        return

    if click_to_eat:
        _handle_eat()
        __SignalBus.on_inspect_food.emit(food, pieces.size(), _handle_eat)
    elif _focus_food == self:
        _clicked_focus = true
    else:
        _focus_food = self
        _clicked_focus = true
        __SignalBus.on_inspect_food.emit(food, pieces.size(), _handle_eat)

func _on_mouse_entered() -> void:
    if _focus_food != self:
        _clicked_focus = false

    if _focus_food == null:
        _focus_food = self
        __SignalBus.on_inspect_food.emit(food, pieces.size(), _handle_eat)

func _handle_eat() -> void:
    _clicked_focus = false
    _focus_food = null
    var p: Node2D = pieces.pop_front()
    if p != null:
        p.queue_free()
        __SignalBus.on_eat.emit(food)
    if pieces.is_empty():
        visible = false
        await get_tree().create_timer(0.25).timeout
        __SignalBus.on_stop_inspect_food.emit()

func _on_mouse_exited() -> void:
    if !_clicked_focus && _focus_food == self:
        _clicked_focus = false
        _focus_food = null
        __SignalBus.on_stop_inspect_food.emit()
