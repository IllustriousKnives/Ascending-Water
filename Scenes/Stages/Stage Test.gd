extends Node

func _ready():
	map_timed_actions()

func map_timed_actions():
	await Global.wait(15)
	var tween_water = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween_water.tween_property($Liquid, "global_position", $Liquid.global_position + Vector2(0, -350),10)
	await Global.wait(20)
	tween_water = create_tween()
	tween_water.tween_property($Liquid, "global_position", $Liquid.global_position + Vector2(0, -700),17)
	await Global.wait(30)
	tween_water = create_tween()
	tween_water.tween_property($Liquid, "global_position", $Liquid.global_position + Vector2(0, -500),30)
	
	
