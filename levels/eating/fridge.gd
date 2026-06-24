extends Node2D
class_name Fridge

@export var _stock: Array[FoodGroup]

func _enter_tree() -> void:
    if __SignalBus.on_eat.connect(_handle_eat) != OK:
        push_error("Failed to connect eat")

func _handle_eat(food: Food2D) -> void:
    GlobalStateVicious.eaten_food[food.name] = GlobalStateVicious.eaten_food.get(food.name, 0) + 1

func is_empty() -> bool:
    for group: FoodGroup in _stock:
        if !group.exhausted:
            return false

    return true

func _ready() -> void:
    for food_name: String in GlobalStateVicious.eaten_food:
        var count: int = GlobalStateVicious.eaten_food[food_name]
        while count > 0:
            var group_idx: int = _stock.find_custom(func (g: FoodGroup) -> bool: return g.food.name == food_name && !g.exhausted)
            if group_idx < 0:
                push_error("Could not find food group '%s' with food left" % [food_name])
                break

            var group: FoodGroup = _stock[group_idx]
            while count > 0 && !group.exhausted:
                group.consume_one_food()
                count -= 1
