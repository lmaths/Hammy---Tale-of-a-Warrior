extends MarginContainer
 
@onready var label = $MarginContainer/Label
@onready var timer = $Timer

const MAX_WIDTH = 150
var text = ""
var letter_index = -1
var letter_display_time := 0.07
var space_display_time := 0.05
var punctuation_display_time := 0.02

signal text_display_finished()

func display_text(text_to_display: String):
	print("text do tisplayu")
	print(text_to_display)
	text = text_to_display
	label.text = text_to_display
	print("final")
	custom_minimum_size.x = min(size.x, MAX_WIDTH)
	if size.x > MAX_WIDTH:
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		await resized
		await resized
		custom_minimum_size.y = size.y
	
	global_position.x -= size.x / 2
	global_position.y -= size.y + 40
	label.text = ""
	
	display_letter()

func display_letter():
	print(text.length())
	letter_index += 1
	if letter_index >= text.length():
		print("emitiu")
		text_display_finished.emit()
		return
	label.text += text[letter_index]
	match text[letter_index]:
		"!", "?", ",", ".":
			timer.start(punctuation_display_time)
		" ":
			timer.start(space_display_time)
		_:
			timer.start(letter_display_time)


func _on_timer_timeout():
	display_letter()
