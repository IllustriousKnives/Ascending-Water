extends Node2D

@onready var id = name.to_int()
@export_enum("spawn_part", "remove_part") var mode : String = "spawn_part"
@export_range(0.1, 10) var button_action_wait_time : float = 2
var available = false

func _ready():
	Global.a_button_was_pressed.connect(refresh_state)
	refresh_state()

func _process(_delta):
	if available:
		$Sprite.rotation += 0.005
	else:
		$Sprite.rotation -= 0.002

func _on_hit_box_body_entered(body):
	if body.type == "player" and available:
		Global.pressed_button_event()
		$Particles_effect.emitting = true
		particle_animation()

func refresh_state():
	if id == Global.current_available_button_id:
		$Animation.play("Button_Available")
		available = true
	elif id > Global.current_available_button_id:
		$Animation.play("Button_Not_Available")
		available = false
	else:
		$Animation.play("Button_Used")
		available = false

func particle_animation():
	$Particle.visible = true
	$Particle/Particles_effect.emitting = true
	$Particle/Animation.play("Effect")
	var tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN)
	tween.tween_property($Particle, "global_position" , $Part/Center.position, button_action_wait_time)
	tween.play()
	await tween.finished
	$Particle/Animation.stop()
	$Particle/Particles_effect.emitting = false
	$Particle.self_modulate = Color(0,0,0,0)
	do_button_action()

func do_button_action():
	if mode == "spawn_part":
		$Part/TileMap.modulate = Color(1,1,1,1)
		$Part/TileMap.set_layer_enabled(0, true)
	elif mode =="remove_part":
		$Part.queue_free()
