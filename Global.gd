extends Node

func wait(s):
	var t = Timer.new()
	t.set_wait_time(s)
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	await t.timeout
	t.queue_free()

func _ready():
	set_keybinding_by_OS_language()

##### V Buttons V #####

var current_available_button_id = 1
signal a_button_was_pressed

func pressed_button_event():
	current_available_button_id += 1
	emit_signal("a_button_was_pressed")
	print("current available button's id = " + str(current_available_button_id))

func set_keybinding_by_OS_language():
	if OS.get_locale_language() != "fr":
		var up = InputEventKey.new()
		up.keycode = KEY_W
		InputMap.action_erase_events("up")
		InputMap.action_add_event("up",up)
		var left = InputEventKey.new()
		left.keycode = KEY_A
		InputMap.action_erase_events("left")
		InputMap.action_add_event("left",left)
