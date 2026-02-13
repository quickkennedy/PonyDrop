extends RigidBody2D

@export var pop_audio: AudioStreamPlayer

var type = 0
var type_textures = [
	preload("res://art/a.png"),
	preload("res://art/b.png"),
	preload("res://art/c.png"),
	preload("res://art/d.png"),
	preload("res://art/e.png"),
	preload("res://art/f.png"),
	preload("res://japanese_pear.png"), #
	preload("res://pear.png"), #
	preload("res://pineapple.png"), #
	preload("res://melon.png"), #
	preload("res://watermelon.png"), #
]
var size_ratio = 1.75/3.0 * 2

# idk these are magic numbers! how did you come up with this????
var type_sizes = [
	1.0 * size_ratio,
	1.25992104989487 * size_ratio,
	1.587401051968192 * size_ratio,
	2.0 * size_ratio,
	2.51984209978974 * size_ratio,
	3.174802103936383 * size_ratio,
	4.0 * size_ratio,
	5.03968419957948 * size_ratio,
	6.349604207872766 * size_ratio,
	8.0 * size_ratio,
	10.07936839915896 * size_ratio,
]
var type_scores = [
	1,
	3,
	6,
	10,
	15,
	21,
	28,
	36,
	45,
	55,
	66,
]

var follows = true
var fused = false
var just_dropped = true

func calc_size(t):
	return type_sizes[t] * 0.7

func calc_mass(t):
	return 1 #(1 / (type_sizes[type] /  size_ratio)) * 200

func set_type(t):
	type = t
	
	var shape = get_node("CollisionShape2D")
	shape.scale = Vector2(calc_size(t), calc_size(t))
	
	var sprite = get_node("Sprite2D")
	sprite.scale = Vector2(calc_size(t), calc_size(t))
	sprite.texture = type_textures[t]
	
	mass = calc_mass(type)

func start():
	follows = false
	#get_node("CollisionShape2D").disabled = false
	set_collision_layer_value(1, true)
	set_collision_layer_value(2, false)
	
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, false)

func _process(delta):
	if follows:
		# move to the mouse's x
		move_and_collide(Vector2(get_local_mouse_position().x,0))
		
		set_linear_velocity(Vector2(0.0, 0.0))
	elif just_dropped:
		var t = Timer.new()
		t.set_wait_time(0.4)
		t.set_one_shot(true)
		self.add_child(t)
		
		t.start()
		await t.timeout
		t.queue_free()
		
		just_dropped = false

#func _ready():
	#pop_audio.play()

func _on_body_entered(body):
	if fused == false && body.has_signal("body_entered") \
	&& body.type == type && body.fused == false:
		body.fused = true
		fused = true
		
		var new_pos = (body.position + position) / 2.0
		var main = get_node("/root/MainScene")
		
		# AUDIO DOESNT WORK IDK.
		#pop_audio.pitch_scale = 1.25 - type * 0.05
		#pop_audio.play()
		
		var score = main.get_node("Score")
		score.add_score(type_scores[type])
		
		body.queue_free()
		queue_free()
		
		if type < 10:
			main.fuse_fruits(type + 1, new_pos)
