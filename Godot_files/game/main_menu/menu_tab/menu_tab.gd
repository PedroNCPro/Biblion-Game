extends CanvasLayer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_menu_tab_button_toggled(toggled_on: bool) -> void:
	if(toggled_on): 
		get_tree().paused = true
		$MenuTabContainer.show()
	else:
		get_tree().paused = false
		$MenuTabContainer.hide()

func _on_options_button_pressed() -> void:
	$OptionsWindow.show()


func _on_leave_run_button_pressed() -> void:
	$LeaveWindow.show()


func _on_leave_button_pressed() -> void:
	get_tree().paused = false
	RunManager._on_menu_tab_leave_pressed()


func _on_cancel_button_pressed() -> void:
	$LeaveWindow.hide()
