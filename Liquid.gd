extends Sprite2D

var mode = "water"

func _on_hit_box_body_entered(body):
	body.in_liquid = true

func _on_hit_box_body_exited(body):
	body.in_liquid = false
	body.motion += Vector2(0,-150)



