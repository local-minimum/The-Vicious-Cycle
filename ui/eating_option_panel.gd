extends PanelContainer

@export var title: Label
@export var count: Label
@export var icon: TextureRect
@export var calory_icon: TextureRect
@export var happiness_icon: TextureRect
@export var eat_btn: Button
@export var happiness_textures: Array[Texture]
@export var calories_textures: Array[Texture]

func _enter_tree() -> void:
    if __SignalBus.on_start_eating.connect(_handle_start_eating) != OK:
        push_error("Could not connect start eating")
    if __SignalBus.on_inspect_food.connect(_handle_inspect_food) != OK:
        push_error("Failed to connect inspect food")
    if __SignalBus.on_refuse_food.connect(_handle_refuse_food) != OK:
        push_error("Failed to connect refuse food")
    if __SignalBus.on_eat.connect(_handle_eat) != OK:
        push_error("Failed to connect eat")
    if __SignalBus.on_stop_inspect_food.connect(_handle_stop_inpsect_food) != OK:
        push_error("Failed to connect stop inspect food")
    if eat_btn.pressed.connect(_btn_callback) != OK:
        push_error("Failed to connect eat button")

func _ready() -> void:
    visible = false

func _handle_eat(food: Food2D) -> void:
    if food != _food:
        return
    _servings = maxi(0, _servings - 1)
    if _servings > 0:
        count.text = "%s servings left" % [_servings]
    else:
        visible = false

func _handle_refuse_food(__food: Food2D, _reason: _SignalBus.RefuseFood) -> void:
    #print_debug("Hide refuse food")
    visible = false

func _handle_stop_inpsect_food() -> void:
    #print_debug("Hide inspect food")
    visible = false

func _handle_start_eating() -> void:
    #print_debug("Show start eating")
    visible = true

var _food: Food2D
var _eat_callback: Callable = _no_callback
var _servings: int

func _handle_inspect_food(food: Food2D, servings: int, on_eat: Callable) -> void:
    _food = food
    _eat_callback = on_eat
    _servings = servings
    title.text = food.name
    count.text = "%s servings left" % [servings]
    icon.texture = food.icon
    icon.visible = food.icon != null
    eat_btn.disabled = servings < 1
    _set_happiness_icon(food.happiness)
    _set_calories_icon(food.calories)
    #print_stack()
    #print_debug("Show inpsect ", food)
    visible = true

func _set_happiness_icon(happiness: float) -> void:
    if happiness < 0.0:
        happiness_icon.texture = happiness_textures[0]
    elif happiness < 5.0:
        happiness_icon.texture = happiness_textures[1]
    elif happiness == 5.0:
        happiness_icon.texture = happiness_textures[2]
    else:
        happiness_icon.texture = happiness_textures[3]

func _set_calories_icon(calories: float) -> void:
    if calories < 10.0:
        calory_icon.texture = calories_textures[0]
    elif calories < 15.0:
        calory_icon.texture = calories_textures[1]
    else:
        calory_icon.texture = calories_textures[2]

func _no_callback() -> void:
    push_warning("Tried to eat nothing")

func _btn_callback() -> void:
    _eat_callback.call()
    print_debug("Hide button callback")
    visible = false
