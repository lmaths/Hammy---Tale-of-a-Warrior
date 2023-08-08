extends Node2D

@onready var area_2d = $Area2D
@onready var dialog_sprite = $DialogSprite
@export var lines: Array[String] = []
func _unhandled_input(event):
	if(area_2d.get_overlapping_bodies().size() > 0):
		dialog_sprite.show()
		if event.is_action_pressed("interact") && !DialogManager.is_message_active && DialogManager.body != null:
			dialog_sprite.hide()
			DialogManager.start_message(global_position, lines)
	else:
		dialog_sprite.hide()


func _on_area_2d_body_entered(body):
	DialogManager.set_body(body)


func _on_area_2d_body_exited(body):
	DialogManager.set_body(null)
	if DialogManager.dialog_box != null:
		DialogManager.dialog_box.queue_free()
		DialogManager.is_message_active = false
