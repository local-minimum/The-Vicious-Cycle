class_name GlobalStateVicious

static var door_cylinder_offsets: Array[int] = [0, 0, 0]
static var cricis_counter: int = 0

const _KEY_DOOR_CYLINDER: String = "door_cylinder_offsets"
const _KEY_CRICIS: String = "cricis_counter"

static func save() -> Dictionary:
    return {
        _KEY_DOOR_CYLINDER: door_cylinder_offsets,
        _KEY_CRICIS: cricis_counter,
    }

static func reset() -> void:
    door_cylinder_offsets = [0, 0, 0]
    cricis_counter = 0

static func load(data: Dictionary) -> void:
    var warn: bool = !data.is_empty()
    door_cylinder_offsets = DictionaryUtils.safe_geta(data, _KEY_DOOR_CYLINDER, [0, 0, 0] as Array[int], warn)
    cricis_counter = DictionaryUtils.safe_geti(data, _KEY_CRICIS, 0, warn)
