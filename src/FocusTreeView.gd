extends Control
class_name FocusTreeView

var game_state: GameState
var selected_focus := ""

func _ready() -> void:
    mouse_filter = Control.MOUSE_FILTER_PASS

func _gui_input(event: InputEvent) -> void:
    if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        var focus = _focus_at_position(event.position)
        if focus != "":
            selected_focus = focus
            queue_redraw()

func start_selected_focus() -> void:
    if selected_focus == "":
        return
    if game_state:
        game_state.start_focus(selected_focus)

func _draw() -> void:
    if game_state == null:
        return
    var tree = game_state.focus_trees.get(game_state.selected_country_id, {})
    var nodes = tree.get("nodes", [])
    var positions = _layout(nodes)
    for node in nodes:
        var pos = positions.get(node.get("id", ""), Vector2.ZERO)
        for prereq in node.get("prerequisites", []):
            if positions.has(prereq):
                draw_line(positions[prereq] + Vector2(60, 20), pos + Vector2(60, 20), Color(0.4, 0.4, 0.4), 2.0)
    for node in nodes:
        var pos = positions.get(node.get("id", ""), Vector2.ZERO)
        var rect = Rect2(pos, Vector2(120, 40))
        var color = Color(0.2, 0.2, 0.2)
        if node.get("id", "") == selected_focus:
            color = Color(0.8, 0.7, 0.2)
        elif game_state.focus_state.get(game_state.selected_country_id, "") == node.get("id", ""):
            color = Color(0.3, 0.6, 0.3)
        draw_rect(rect, color)
        draw_rect(rect, Color.WHITE, false, 1.0)
        draw_string(get_theme_default_font(), pos + Vector2(6, 24), node.get("name", ""), HORIZONTAL_ALIGNMENT_LEFT, 110, 12, Color.WHITE)

func _focus_at_position(pos: Vector2) -> String:
    if game_state == null:
        return ""
    var tree = game_state.focus_trees.get(game_state.selected_country_id, {})
    var nodes = tree.get("nodes", [])
    var positions = _layout(nodes)
    for node in nodes:
        var rect = Rect2(positions.get(node.get("id", ""), Vector2.ZERO), Vector2(120, 40))
        if rect.has_point(pos):
            return node.get("id", "")
    return ""

func _layout(nodes: Array) -> Dictionary:
    var positions := {}
    var depth := {}
    for node in nodes:
        depth[node.get("id", "")] = 0
    var changed = true
    while changed:
        changed = false
        for node in nodes:
            var node_id = node.get("id", "")
            var prereqs = node.get("prerequisites", [])
            for prereq in prereqs:
                var value = depth.get(prereq, 0) + 1
                if value > depth.get(node_id, 0):
                    depth[node_id] = value
                    changed = true
    var columns := {}
    for node in nodes:
        var node_id = node.get("id", "")
        var col = depth.get(node_id, 0)
        if not columns.has(col):
            columns[col] = []
        columns[col].append(node_id)
    for col in columns.keys():
        var rows = columns[col]
        for idx in range(rows.size()):
            positions[rows[idx]] = Vector2(40 + col * 160, 40 + idx * 80)
    return positions
