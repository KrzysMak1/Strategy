extends Node
class_name AIController

var priorities := {}

func set_priorities(country_id: String, focus_ids: Array) -> void:
    priorities[country_id] = focus_ids

func choose_focus(country_id: String) -> String:
    var list = priorities.get(country_id, [])
    return list[0] if list.size() > 0 else ""

func tick(game_state: GameState) -> void:
    for country_id in game_state.countries.keys():
        if country_id == game_state.selected_country_id:
            continue
        if game_state.focus_state.get(country_id, "") == "" and game_state.focus_trees.has(country_id):
            var tree = game_state.focus_trees[country_id]
            var nodes = tree.get("nodes", [])
            if nodes.size() > 0:
                game_state.focus_state[country_id] = nodes[0].get("id", "")

        for army_id in game_state.armies.keys():
            var army = game_state.armies[army_id]
            if army.get("country_id") != country_id:
                continue
            if not army.get("path", []).is_empty():
                continue
            var province_id = army.get("province_id", "")
            var neighbors = game_state.get_neighbors(province_id)
            if neighbors.is_empty():
                continue
            var target = neighbors[randi() % neighbors.size()]
            army["path"] = [target]
            game_state.armies[army_id] = army
