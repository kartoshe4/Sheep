extends Control

var text_link = "/home/ilya/Документы/Hackaton/game.save"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var cut
	cut = ProjectSettings.globalize_path("res://game.txt")
	text_link = cut.substr(0, cut.find("Sheep/")) + "game.save"
	var file = FileAccess
	if not(file.file_exists(text_link)):
		file = FileAccess.open(text_link, FileAccess.WRITE)
		file.close()

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
