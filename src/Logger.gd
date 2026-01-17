extends Node
class_name Logger

signal entry_added(entry: Dictionary)

const LEVELS := {
    "INFO": 0,
    "WARN": 1,
    "ERROR": 2
}

var entries: Array = []
var min_level := LEVELS.INFO
var muted_sources := {}

func set_min_level(level_name: String) -> void:
    if LEVELS.has(level_name):
        min_level = LEVELS[level_name]

func mute_source(source: String, muted: bool = true) -> void:
    if source == "":
        return
    if muted:
        muted_sources[source] = true
    else:
        muted_sources.erase(source)

func log(message: String, level_name: String = "INFO", source: String = "") -> void:
    if not LEVELS.has(level_name):
        level_name = "INFO"
    if LEVELS[level_name] < min_level:
        return
    if source != "" and muted_sources.get(source, false):
        return
    var entry = {
        "message": message,
        "level": level_name,
        "source": source,
        "timestamp": Time.get_datetime_string_from_system()
    }
    entries.append(entry)
    if entries.size() > 200:
        entries.pop_front()
    emit_signal("entry_added", entry)

func info(message: String, source: String = "") -> void:
    log(message, "INFO", source)

func warn(message: String, source: String = "") -> void:
    log(message, "WARN", source)

func error(message: String, source: String = "") -> void:
    log(message, "ERROR", source)
