extends Control

var money = 0
var mod_money = 1

var mod_product = 1

var wheel = 0
var is_mouse_entered = false

var rotat = 0
var mod_rotat = 0.15

var t = 0.0
var s = 1
var random_position = Vector2()
var start_position = Vector2()

var products = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	products.append(Product.new(10, "Product1"))
	products.append(Product.new(100, "Product2"))
	products.append(Product.new(1000, "Product3"))
	products.append(Product.new(10000, "Product4"))


func shift_products_up() -> void:
	if products.size() > 1:
		var first_product = products[0]  # Сохраняем первый элемент
		for i in range(products.size() - 1):
			products[i] = products[i + 1]  # Сдвигаем элементы влево
		products[products.size() - 1] = first_product  # Перемещаем первый элемент в конец массива


func shift_products_down() -> void:
	if products.size() > 1:
		var last_product = products[products.size() - 1]  # Сохраняем последний элемент
		for i in range(products.size() - 1, 0, -1):
			products[i] = products[i - 1]  # Сдвигаем элементы вправо
		products[0] = last_product  # Перемещаем последний элемент на первое место


func turn() -> void:
	rotat += mod_rotat
	$Field/Click.set_rotation_degrees(rotat)
	if (abs(rotat) >= 30): mod_rotat *= -1


func moving(delta: float):
	if (t < 1):
		t += delta * 1200 / s
		$Field/Click.position = start_position.lerp(random_position, t)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if mod_product < 1:
		mod_product = 1
	
	turn()
	moving(delta)
	
	$Shop/Product.clear()
	for i in products:
		$Shop/Product.add_text(i.text + "\n\n")
	$Shop/Money.clear()
	$Shop/Money.append_text("Money: " + str(money))
	
	$Shop/Price.clear()
	$Shop/Price.append_text(str(products[1].price) + " x " + 
	str(mod_product) + " = " + str(products[1].price * mod_product))
	
	if is_mouse_entered:
		if wheel > 0:
			shift_products_up()
			wheel -= 2
		elif wheel < 0:
			shift_products_down()
			wheel += 2

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			wheel += 1
		elif  event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			wheel -= 1


func _on_texture_button_button_down() -> void:
	money += mod_money
	random_position = Vector2(
		clamp(randi() % int($Field.size.x), 0, int($Field.size.x)),
		clamp(randi() % int($Field.size.y), 0, int($Field.size.y))
	)
	start_position = $Field/Click.position
	t = 0.0
	s = (random_position - start_position).length()
	if s == 0:
		s = 1


func _on_product_mouse_entered() -> void:
	is_mouse_entered = true


func _on_product_mouse_exited() -> void:
	is_mouse_entered = false


func _on_buy_mouse_entered() -> void:
	is_mouse_entered = true


func _on_buy_mouse_exited() -> void:
	is_mouse_entered = false


func _on_buy_button_down() -> void:
	if money >= products[1].price * mod_product:
		money -= products[1].price * mod_product
		if products[1].text == "Product1":
			mod_money += 1 * mod_product
		elif products[1].text == "Product2":
			mod_money += 10 * mod_product
		elif products[1].text == "Product3":
			mod_money += 100 * mod_product
		elif products[1].text == "Product4":
			mod_money += 1000 * mod_product


func _on_mod_1_button_down() -> void:
	mod_product += 1


func _on_mod_n_1_button_down() -> void:
	mod_product -= 1


func _on_mod_10_button_down() -> void:
	mod_product += 10


func _on_mod_n_10_button_down() -> void:
	mod_product -= 10


func _on_mod_100_button_down() -> void:
	mod_product += 100


func _on_mod_n_100_button_down() -> void:
	mod_product -= 100
