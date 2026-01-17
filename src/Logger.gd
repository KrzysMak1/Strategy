extends Node
class_name Logger

var entries := []

func log(message: String) -> void:
    entries.append("%s" % message)
    if entries.size() > 200:
        entries.pop_front()
