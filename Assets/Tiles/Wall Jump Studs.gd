extends TileMap

func _ready():
	infinite_animation()
	pass

func infinite_animation():
	var tween
	while true:
		tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "modulate", Color(1, 1, 1, 1),1)
		await tween.finished
		tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
		tween.tween_property(self, "modulate", Color(0.6, 0.6, 0.6, 1),1)
		await tween.finished




