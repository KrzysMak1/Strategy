extends CanvasLayer
class_name DebugOverlay

@export var label: Label

func update_text(text: String) -> void:
    if label:
        label.text = text
