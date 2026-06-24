extends Node2D
class_name Fridge

@export var _stock: Array[FoodGroup]

func is_empty() -> bool:
    for group: FoodGroup in _stock:
        if !group.exhausted:
            return false

    return true
