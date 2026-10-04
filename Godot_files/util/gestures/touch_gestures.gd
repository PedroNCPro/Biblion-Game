extends Node2D
class_name TouchGestures


signal drag_detected(dist_vec: Vector2)
signal pinch_detected(dist_diff: float)

var touches := {}
var drag_start_pos := Vector2.ZERO
var pinch_start_dist := 0.0
var is_dragging := false
var is_pinching := false

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touches[event.index] = event.position
		else:
			touches.erase(event.index)
		_evaluate_gesture_state()
	elif event is InputEventScreenDrag:
		touches[event.index] = event.position
		_process_movement(event)
		#queue_redraw()
	#_draw_debug()

func _evaluate_gesture_state() -> void:
	is_dragging = false
	is_pinching = false
	match touches.size():
		1:
			is_dragging = true
			drag_start_pos = touches.values()[0]
		2:
			is_pinching = true
			pinch_start_dist = touches.values()[0].distance_to(touches.values()[1])


func _process_movement(event: InputEvent) -> void:
	if is_dragging and touches.size() == 1:
		drag_detected.emit(event.relative)
		
	elif is_pinching and touches.size() == 2:
		var curr_dist = touches.values()[0].distance_to(touches.values()[1])
		var dist_diff = curr_dist - pinch_start_dist
		pinch_detected.emit(dist_diff)
		pinch_start_dist = curr_dist


func _draw_debug() -> void:
	for touch_position in touches.values():
		draw_circle(touch_position, 100.0, Color.CORAL, false, 5.0)
