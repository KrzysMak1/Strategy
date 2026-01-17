extends Node
class_name EventBus

signal event_emitted(event_id: String, payload: Dictionary)

func emit_event(event_id: String, payload: Dictionary = {}) -> void:
    emit_signal("event_emitted", event_id, payload)

