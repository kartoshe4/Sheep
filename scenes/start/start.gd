extends Control

var text_link = "/home/ilya/Документы/Hackaton/game.save"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_start_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main.tscn")


func _on_reset_pressed() -> void:
	var file = FileAccess.open(text_link, FileAccess.WRITE)
	file.store_string("")
