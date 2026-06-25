extends Node
class_name _SignalBus

@warning_ignore_start("unused_signal")
signal on_start_exercise()
signal on_exercise(amount: float)
signal on_exercise_no_calories()
signal on_exercise_start_step(step: int, resistance: int)
signal on_exercise_complete()

signal on_start_eating()
signal on_inspect_food(food: Food2D, servings: int, on_eat: Callable)
signal on_stop_inspect_food()
signal on_eat(food: Food2D)

enum RefuseFood { CALORIES, HAPPINESS }
signal on_refuse_food(food: Food2D, reason: RefuseFood)

signal on_start_spin()
signal on_complete_spin(success: bool, can_spin_more: bool)
