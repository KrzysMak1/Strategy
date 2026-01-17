extends Node
class_name DataLoader

const DATA_PATH := "res://data"
const MOD_PATH := "res://data/mods"

var focus_index := {}
var errors := []

func load_all() -> Dictionary:
    errors.clear()
    var result := {
        "countries": _load_json("%s/countries.json" % DATA_PATH),
        "provinces": _load_json("%s/regions.json" % DATA_PATH),
        "technologies": _load_json("%s/technologies.json" % DATA_PATH),
        "units": _load_json("%s/units.json" % DATA_PATH),
        "events": _load_json("%s/events.json" % DATA_PATH),
        "focus_trees": _load_json("%s/focus_trees.json" % DATA_PATH),
        "decisions": _load_json("%s/decisions.json" % DATA_PATH),
        "armies": _load_json("%s/armies.json" % DATA_PATH)
    }
    _load_mod_overrides(result)
    _build_focus_index(result.get("focus_trees", {}))
    _validate_data(result)
    return result

func _load_mod_overrides(result: Dictionary) -> void:
    var dir = DirAccess.open(MOD_PATH)
    if dir == null:
        return
    dir.list_dir_begin()
    var name = dir.get_next()
    while name != "":
        if dir.current_is_dir() and not name.begins_with("."):
            var mod_root = "%s/%s" % [MOD_PATH, name]
            _merge_data(result, _load_json("%s/countries.json" % mod_root), "countries")
            _merge_data(result, _load_json("%s/regions.json" % mod_root), "provinces")
            _merge_data(result, _load_json("%s/focus_trees.json" % mod_root), "focus_trees")
            _merge_data(result, _load_json("%s/decisions.json" % mod_root), "decisions")
            _merge_data(result, _load_json("%s/armies.json" % mod_root), "armies")
        name = dir.get_next()
    dir.list_dir_end()

func _merge_data(result: Dictionary, payload: Dictionary, key: String) -> void:
    if payload.is_empty():
        return
    var target = result.get(key, {})
    for entry_key in payload.keys():
        target[entry_key] = payload[entry_key]
    result[key] = target

func _build_focus_index(trees: Dictionary) -> void:
    focus_index.clear()
    for tree_key in trees.keys():
        var tree = trees[tree_key]
        for focus in tree.get("nodes", []):
            focus_index[focus.get("id", "")] = focus

func get_focus(focus_id: String) -> Dictionary:
    return focus_index.get(focus_id, {})

func _load_json(path: String) -> Dictionary:
    var file = FileAccess.open(path, FileAccess.READ)
    if file == null:
        return {}
    var content = file.get_as_text()
    var data = JSON.parse_string(content)
    return data if typeof(data) == TYPE_DICTIONARY else {}

func _validate_data(data: Dictionary) -> void:
    var countries = data.get("countries", {})
    if countries.is_empty():
        errors.append("Brak danych krajów.")
    for country_id in countries.keys():
        var country = countries[country_id]
        _require_field(country, "name", "countries.%s" % country_id)
        _require_field(country, "ideology", "countries.%s" % country_id)
        _require_field(country, "capital", "countries.%s" % country_id)
    var provinces = data.get("provinces", {})
    if provinces.size() < 120:
        errors.append("Za mało prowincji: %s" % provinces.size())
    for province_id in provinces.keys():
        var province = provinces[province_id]
        _require_field(province, "owner", "regions.%s" % province_id)
        _require_field(province, "grid", "regions.%s" % province_id)
    var focus_trees = data.get("focus_trees", {})
    if focus_trees.is_empty():
        errors.append("Brak drzewek focusów.")
    var technologies = data.get("technologies", {})
    if technologies.size() < 60:
        errors.append("Za mało technologii: %s" % technologies.size())
    var units = data.get("units", {})
    if units.size() < 20:
        errors.append("Za mało jednostek/sprzętu: %s" % units.size())
    var events = data.get("events", {})
    if events.size() < 80:
        errors.append("Za mało eventów: %s" % events.size())

func _require_field(payload: Dictionary, field: String, context: String) -> void:
    if not payload.has(field):
        errors.append("Brak pola %s w %s" % [field, context])
