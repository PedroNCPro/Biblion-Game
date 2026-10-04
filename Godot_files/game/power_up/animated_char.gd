extends Control

#to change the duration or strength of the animation, change the curves
@export var rotation_anim : Curve
@export var scale_anim : Curve

func spring(t : float) -> void:
	$Movable.rotation_degrees = rotation_anim.sample(t)
	$Movable.scale = scale_anim.sample(t) * Vector2(1.0, 1.0)

func _on_anim_delay_timeout() -> void:
	create_tween().tween_method(spring, 0.0, rotation_anim.max_domain, rotation_anim.max_domain)

func set_char(ch : String) -> void:
	$Movable/Label.text = ch
	
func get_char() -> String:
	return $Movable/Label.text

func set_element(e : int) -> void:
	$Movable/Label.material.set_shader_parameter("base_elem", e)

#starts the "boing" animation after "lag" seconds
func activate(lag : float) -> void:
	if lag <= 0.0001:
		_on_anim_delay_timeout()
	else:
		$AnimDelay.start(lag)
