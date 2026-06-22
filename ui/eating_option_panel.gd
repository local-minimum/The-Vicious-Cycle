extends PanelContainer

@export var title: Label
@export var count: Label
@export var icon: TextureRect
@export var calory_icon: TextureRect
@export var happiness_icon: TextureRect
@export var eat_btn: Button

func _enter_tree() -> void:
    if __SignalBus.on_start_eating.connect(_handle_start_eating) != OK:
        push_error("Could not connect start eating")
    if __SignalBus.on_inspect_food.connect(_handle_inspect_food) != OK:
        push_error("Failed to connect inspect food")
    if __SignalBus.on_stop_inspect_food.connect(_handle_stop_inpsect_food) != OK:
        push_error("Failed to connect stop inspect food")
    if eat_btn.pressed.connect(_btn_callback) != OK:
        push_error("Failed to connect eat button")

func _ready() -> void:
    visible = false

func _handle_stop_inpsect_food() -> void:
    visible = false

func _handle_start_eating() -> void:
    visible = true

var _food: Food2D
var _eat_callback: Callable = _no_callback

func _handle_inspect_food(food: Food2D, servings: int, on_eat: Callable) -> void:
    _food = food
    _eat_callback = on_eat
    title.text = food.name
    count.text = "%s servings left" % [servings]
    icon.texture = food.icon
    icon.visible = food.icon != null
    eat_btn.disabled = servings < 1
    visible = true

func _no_callback() -> void:
    push_warning("Tried to eat nothing")

func _btn_callback() -> void:
    _eat_callback.call()
    visible = false
