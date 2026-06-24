class_name GlobalState

static var save_slot: int

const _KEY_VICIOUS: String = "vicious"

static func save(provider: SaveStorageProvider) -> bool:
    var payload: Dictionary = {
        _KEY_VICIOUS: GlobalStateVicious.save(),
    }
    return provider.store_data(save_slot, payload)

static func reset(provider: SaveStorageProvider) -> bool:
    GlobalStateVicious.reset()
    return save(provider)

static func load(provider: SaveStorageProvider, slot: int) -> void:
    save_slot = slot
    var data = provider.retrieve_data(slot)
    GlobalStateVicious.load(data.get(_KEY_VICIOUS, {}))
