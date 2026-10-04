extends Node
class_name GridGestures


@export var camera: Camera2D
@export var zoom_factor: float = 0.001
@export var move_factor: float = 0.1
@export var min_zoom := Vector2(0.2, 0.2)
@export var max_zoom := Vector2(3.0, 3.0)

var grid_init_pos: Vector2 # TODO when double tapping, reset grid position and scale


func _ready() -> void:
	camera = get_tree().get_first_node_in_group("grid_camera")
	var extra_limit = Vector2(200, 500)
	var screen_w = ProjectSettings.get_setting("display/window/size/viewport_width")
	var screen_h = ProjectSettings.get_setting("display/window/size/viewport_height")
	#camera.position = Vector2(screen_w / 2.0, screen_h / 2.0)
	camera.limit_left = -extra_limit.x * 2
	camera.limit_top = -extra_limit.y * 2
	camera.limit_right = screen_w + extra_limit.x
	camera.limit_bottom = screen_h + extra_limit.y


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_on_touch_gestures_pinch_detected(5)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_on_touch_gestures_pinch_detected(-5)


func _on_touch_gestures_drag_detected(dist_vec: Vector2) -> void:
	#print(camera.position)
	camera.position -= dist_vec * move_factor


func _on_touch_gestures_pinch_detected(dist_diff: float) -> void:
	#print(camera.zoom)
	var zoom_change = Vector2(dist_diff, dist_diff) * zoom_factor
	var new_zoom = camera.zoom + zoom_change
	new_zoom = clamp(new_zoom, min_zoom, max_zoom)
	camera.zoom = new_zoom
