extends Node2D
class_name MapController

signal province_clicked(province_id)

var provinces := {}
var armies := {}
var map_mode := "political"
var tile_size := Vector2(64, 64)
var grid_width := 12
var grid_height := 10
var selected_province := ""

var camera: Camera2D
var pan_speed := 600.0
var zoom_step := 0.1

func setup(province_data: Dictionary, camera_ref: Camera2D) -> void:
    provinces = province_data
    camera = camera_ref
    _update_bounds()
    queue_redraw()

func set_armies(army_data: Dictionary) -> void:
    armies = army_data
    queue_redraw()

func set_selected_province(province_id: String) -> void:
    selected_province = province_id
    queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
    if event is InputEventMouseButton:
        if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
            camera.zoom = camera.zoom - Vector2(zoom_step, zoom_step)
        elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
            camera.zoom = camera.zoom + Vector2(zoom_step, zoom_step)
        elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
            var local_pos = to_local(event.position)
            var grid_pos = Vector2i(local_pos.x / tile_size.x, local_pos.y / tile_size.y)
            var province_id = _province_id_from_grid(grid_pos)
            if province_id != "":
                emit_signal("province_clicked", province_id)
    if event is InputEventKey and event.pressed:
        if event.keycode == KEY_1:
            map_mode = "political"
        elif event.keycode == KEY_2:
            map_mode = "infrastructure"
        elif event.keycode == KEY_3:
            map_mode = "supply"
        elif event.keycode == KEY_4:
            map_mode = "resistance"
        elif event.keycode == KEY_5:
            map_mode = "air"
        queue_redraw()

func _process(delta: float) -> void:
    var move = Vector2.ZERO
    if Input.is_action_pressed("ui_left"):
        move.x -= 1
    if Input.is_action_pressed("ui_right"):
        move.x += 1
    if Input.is_action_pressed("ui_up"):
        move.y -= 1
    if Input.is_action_pressed("ui_down"):
        move.y += 1
    if move != Vector2.ZERO:
        camera.position += move.normalized() * pan_speed * delta / camera.zoom.x

func _draw() -> void:
    for province_id in provinces.keys():
        var province = provinces[province_id]
        var grid = province.get("grid", [0, 0])
        var rect = Rect2(Vector2(grid[0], grid[1]) * tile_size, tile_size)
        var color = _color_for_province(province)
        draw_rect(rect, color)
        draw_rect(rect, Color.BLACK, false, 1.0)
        if province_id == selected_province:
            draw_rect(rect.grow(2.0), Color(1, 1, 0), false, 2.0)
    for army_id in armies.keys():
        var army = armies[army_id]
        var province_id = army.get("province_id", "")
        var province = provinces.get(province_id, {})
        if province.is_empty():
            continue
        var grid = province.get("grid", [0, 0])
        var center = Vector2(grid[0], grid[1]) * tile_size + tile_size * 0.5
        draw_circle(center, 8.0, Color(0.1, 0.1, 0.1))
        draw_string(get_theme_default_font(), center + Vector2(10, 4), army.get("country_id", ""), HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color.WHITE)

func _province_id_from_grid(grid_pos: Vector2i) -> String:
    for province_id in provinces.keys():
        var province = provinces[province_id]
        var grid = province.get("grid", [0, 0])
        if grid[0] == grid_pos.x and grid[1] == grid_pos.y:
            return province_id
    return ""

func _update_bounds() -> void:
    var max_x = 0
    var max_y = 0
    for province_id in provinces.keys():
        var grid = provinces[province_id].get("grid", [0, 0])
        max_x = max(max_x, int(grid[0]))
        max_y = max(max_y, int(grid[1]))
    grid_width = max_x + 1
    grid_height = max_y + 1

func get_neighbors(province_id: String) -> Array:
    var province = provinces.get(province_id, {})
    if province.is_empty():
        return []
    var grid = province.get("grid", [0, 0])
    var neighbors = []
    var offsets = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
    for offset in offsets:
        var check = Vector2i(grid[0] + offset.x, grid[1] + offset.y)
        var neighbor_id = _province_id_from_grid(check)
        if neighbor_id != "":
            neighbors.append(neighbor_id)
    return neighbors

func _color_for_province(province: Dictionary) -> Color:
    match map_mode:
        "political":
            var color = province.get("owner_color", [0.5, 0.5, 0.5])
            return Color(color[0], color[1], color[2])
        "infrastructure":
            var infra = float(province.get("infrastructure", 1.0)) / 10.0
            return Color(0.2, 0.5 + infra * 0.5, 0.2)
        "supply":
            var supply = float(province.get("supply", 1.0)) / 10.0
            return Color(0.2, 0.2, 0.5 + supply * 0.5)
        "resistance":
            var res = float(province.get("resistance", 0.0)) / 10.0
            return Color(0.5 + res * 0.5, 0.2, 0.2)
        "air":
            var air = float(province.get("air_coverage", 0.0)) / 10.0
            return Color(0.6, 0.6, 0.2 + air * 0.3)
        _:
            return Color(0.4, 0.4, 0.4)
