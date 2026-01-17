extends Node
class_name GameTime

signal ticked(delta_hours)

var speed_levels := [0.0, 1.0, 2.0, 3.0, 4.0, 5.0]
var speed_index := 1
var hour_accumulator := 0.0

func set_speed(index: int) -> void:
    speed_index = clamp(index, 0, speed_levels.size() - 1)

func _process(delta: float) -> void:
    var speed = speed_levels[speed_index]
    if speed <= 0.0:
        return
    hour_accumulator += delta * speed
    if hour_accumulator >= 1.0:
        var hours = floor(hour_accumulator)
        hour_accumulator -= hours
        emit_signal("ticked", hours)
