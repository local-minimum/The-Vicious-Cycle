class_name GlobalStateVicious

static var day: int = 0
static var time_checkpoint: int = -1
static var door_cylinder_offsets: Array[int] = [0, 0, 0]
static var crisis_counter: int = 0
static var calories: float = 65.0
static var happiness: float = 35.0
static var eaten_food: Dictionary[String, int] = {}

const _KEY_DAY: String = "day"
const _KEY_TIME_CHECKPOINT: String = "time_chekpt"
const _KEY_DOOR_CYLINDER: String = "door_cylinder_offsets"
const _KEY_CRISIS: String = "cricis_counter"
const _KEY_CALORIES: String = "calories"
const _KEY_HAPPINESS: String = "happiness"
const _KEY_EATEN: String = "eaten_food"

static func save() -> Dictionary:
    return {
        _KEY_DAY: day,
        _KEY_TIME_CHECKPOINT: time_checkpoint,
        _KEY_DOOR_CYLINDER: door_cylinder_offsets,
        _KEY_CRISIS: crisis_counter,
        _KEY_CALORIES: calories,
        _KEY_HAPPINESS: happiness,
        _KEY_EATEN: eaten_food,
    }

static func reset() -> void:
    day = 0
    time_checkpoint = -1
    door_cylinder_offsets = [0, 0, 0]
    crisis_counter = 0
    calories = 65.0
    happiness = 35.0
    eaten_food = {}

static func load(data: Dictionary) -> void:
    var warn: bool = !data.is_empty()
    day = DictionaryUtils.safe_geti(data, _KEY_DAY, 0, warn)
    time_checkpoint = DictionaryUtils.safe_geti(data, _KEY_TIME_CHECKPOINT, 0, warn)
    door_cylinder_offsets = DictionaryUtils.safe_geta(data, _KEY_DOOR_CYLINDER, [0, 0, 0] as Array[int], warn)
    crisis_counter = DictionaryUtils.safe_geti(data, _KEY_CRISIS, 0, warn)
    calories = DictionaryUtils.safe_getf(data, _KEY_CALORIES, 65.0, warn)
    happiness = DictionaryUtils.safe_getf(data, _KEY_HAPPINESS, 35.0, warn)
    eaten_food = DictionaryUtils.safe_getd(data, _KEY_EATEN, {}, warn)
