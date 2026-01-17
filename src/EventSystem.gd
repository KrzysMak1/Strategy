extends Node
class_name EventSystem

var events := {}
var active_events := []

func load_events(event_data: Dictionary) -> void:
    events = event_data

func trigger_event(event_id: String) -> void:
    if events.has(event_id):
        active_events.append(events[event_id])
