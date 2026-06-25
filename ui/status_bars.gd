extends VBoxContainer
class_name StatusBars

@export var calories_bar: TextureProgressBar
@export var happiness_bar: TextureProgressBar

var convert_calories_to_happiness: bool
var calories: float:
    get():
        return GlobalStateVicious.calories
    set(value):
        GlobalStateVicious.calories = clampf(value, 0.0, 100.0)

var happiness: float:
    get():
        return GlobalStateVicious.happiness
    set(value):
        GlobalStateVicious.happiness = clampf(value, 0.0, 100.0)

func _enter_tree() -> void:
    if __SignalBus.on_exercise.connect(_handle_exercise) != OK:
        push_error("Failed to connect exercise")
    if __SignalBus.on_start_exercise.connect(_handle_start_exercies) != OK:
        push_error("Failed to connect start exercise")
    if __SignalBus.on_eat.connect(_handle_eat) != OK:
        push_error("Failed to connect eat")

func _ready() -> void:
    calories_bar.value = calories
    happiness_bar.value = happiness

func _handle_start_exercies() -> void:
    convert_calories_to_happiness = true

func _handle_exercise(amount: float) -> void:
    calories -= amount * 0.0015
    calories_bar.value = calories
    if calories == 0:
        __SignalBus.on_exercise_no_calories.emit()

func _handle_eat(food: Food2D) -> void:
    calories += food.calories
    calories_bar.value = calories
    happiness += food.happiness
    happiness_bar.value = happiness

func _process(delta: float) -> void:
    if !convert_calories_to_happiness:
        return

    var cal_to_happiness: float = 0.0
    if calories > 60.0:
        cal_to_happiness = calories - 60.0
    elif calories < 45.0:
        cal_to_happiness  = (calories - 45.0) * 0.2
    else:
        cal_to_happiness = 0.25 * (calories - 45.0)

    happiness -= cal_to_happiness * delta * 0.1
    happiness_bar.value = happiness
