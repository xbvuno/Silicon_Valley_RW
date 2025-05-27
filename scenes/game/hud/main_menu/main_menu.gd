extends PanelContainer
signal change_scene(scene_id:String)



func _on_test_platform_button_button_up() -> void:
	change_scene.emit("test-platform")


func _on_test_combact_button_button_up() -> void:
	change_scene.emit("test_combact")


func _on_esci_button_up() -> void:
	get_tree().quit()
