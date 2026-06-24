class_name GlobalStateVicious

static var door_cylinder_offsets: Array[int] = [0, 0, 0]
static var crisis_counter: int = 0
static var calories: float = 65.0
static var happiness: float = 35.0

const _KEY_DOOR_CYLINDER: String = "door_cylinder_offsets"
const _KEY_CRISIS: String = "cricis_counter"
const _KEY_CALORIES: String = "calories"
const _KEY_HAPPINESS: String = "happiness"

static func save() -> Dictionary:
    return {
        _KEY_DOOR_CYLINDER: door_cylinder_offsets,
        _KEY_CRISIS: crisis_counter,
        _KEY_CALORIES: calories,
        _KEY_HAPPINESS: happiness,
    }

static func reset() -> void:
    door_cylinder_offsets = [0, 0, 0]
    crisis_counter = 0
    calories = 65.0
    happiness = 35.0

static func load(data: Dictionary) -> void:
    var warn: bool = !data.is_empty()
    door_cylinder_offsets = DictionaryUtils.safe_geta(data, _KEY_DOOR_CYLINDER, [0, 0, 0] as Array[int], warn)
    crisis_counter = DictionaryUtils.safe_geti(data, _KEY_CRISIS, 0, warn)
    calories = DictionaryUtils.safe_getf(data, _KEY_CALORIES, 65.0, warn)
    happiness = DictionaryUtils.safe_getf(data, _KEY_HAPPINESS, 35.0, warn)
