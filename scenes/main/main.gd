extends Control

var money = 0
var mod = 1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Shop/Money.clear()
	$Shop/Money.append_text("Money: " + str(money))


func _on_click_button_down() -> void:
	money += mod
	$Field/Click.position = Vector2(randi() % int($Field.size[0]), randi() % int($Field.size[1]))



func _on_buy_button_down() -> void:
	if (money >= 10):
		mod += 1
		money -= 10
