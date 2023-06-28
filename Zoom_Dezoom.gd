extends Camera2D

var min_zoom = 0.5
var max_zoom = 2.0
var zoom_factor = 0.1
var zoom_duration = 0.2
var current_zoom = 1.0

func _process(_delta):
	key_action_to_dezoom_zoom()

func key_action_to_dezoom_zoom():
	if Input.is_action_just_released("zoom_in"):
		set_zoom_level(current_zoom + zoom_factor)
	if Input.is_action_just_released("zoom_out"):
		set_zoom_level(current_zoom - zoom_factor)

func set_zoom_level(value: float):
	current_zoom = clamp(value, min_zoom, max_zoom)
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "zoom", Vector2(current_zoom, current_zoom), zoom_duration)
	
	
