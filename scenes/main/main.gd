extends Control

var money = 1000000
var mod_money = 1

var mod_product = 1

var wheel = 0
var is_mouse_entered = false

var rotat_1 = 0
var mod_rotat_1 = 0.15

var rotat_2 = 10
var mod_rotat_2 = 0.15

var t_1 = 0.0
var s_1 = 1
var random_position_1 = Vector2()
var start_position_1 = Vector2()

var t_2 = 0.0
var s_2 = 1
var random_position_2 = Vector2()
var start_position_2 = Vector2()

var products = []
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	start_position_2 = Vector2($Field/Sheep2.position)
	
	products.append(Product.new(10, "Product1"))
	products.append(Product.new(100, "Product2"))
	products.append(Product.new(1000, "Product3"))
	products.append(Product.new(10000, "Product4"))
	products.append(Product.new(10000, "Second Sheep"))
	products.append(Product.new(int(pow(10, 15)), "flag"))


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


func turn_1() -> void:
	rotat_1 += mod_rotat_1
	$Field/Sheep.set_rotation_degrees(rotat_1)
	if (abs(rotat_1) >= 30): mod_rotat_1 *= -1


func turn_2() -> void:
	rotat_2 += mod_rotat_2
	$Field/Sheep2.set_rotation_degrees(rotat_2)
	if (abs(rotat_2) >= 30): mod_rotat_2 *= -1


func moving_1(delta: float) -> void:
	if (t_1 < 1):
		t_1 += delta * 1200 / s_1
		$Field/Sheep.position = start_position_1.lerp(random_position_1, t_1)


func moving_2(delta: float) -> void:
	if (t_2 < 1):
		t_2 += delta * 1200 / s_2
		$Field/Sheep2.position = start_position_2.lerp(random_position_2, t_2)


func output(num: int) -> String:
	if num / int(pow(10, 15)) > 0:
		return str(num/int(pow(10, 15))) + '.'\
		 + str((num%int(pow(10, 15))-num%int(pow(10, 15)))/int(pow(10, 15))) + 'q'
	elif num / 1000000000 > 0:
		return str(num/1000000000) + '.'\
		 + str((num%1000000000-num%100000000)/1000000000) + 'b'
	elif num / 1000000 > 0:
		return str(num/1000000) + '.'\
		 + str((num%1000000-num%100000)/1000000) + 'm'
	elif num / 1000 > 0:
		return str(num/1000) + '.'\
		 + str((num%1000-num%100)/100) + 'k'
	else:
		return str(num)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if mod_product < 1 or products[1].text == "Second Sheep"\
		or products[1].text == "flag":
		mod_product = 1
	
	turn_1()
	turn_2()
	moving_1(delta)
	moving_2(delta)
	
	$Shop/Product.clear()
	for i in products:
		$Shop/Product.add_text(i.text + "\n\n")
	$Shop/Money.clear()
	$Shop/Money.append_text("Money: " + output(money))
	
	$Shop/Click.clear()
	$Shop/Click.append_text("Mod Click: " + output(mod_money))
	
	$Shop/Price.clear()
	$Shop/Price.append_text(output(products[1].price) + " x " + 
	output(mod_product) + " = " + output(products[1].price * mod_product))
	
	if is_mouse_entered:
		if wheel > 0:
			shift_products_up()
			$Shop/Turn.play()
			wheel -= 2
		elif wheel < 0:
			shift_products_down()
			$Shop/Turn.play()
			wheel += 2

func _input(event: InputEvent) -> void:
	if not($Shop/Turn.is_playing()) and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			wheel += 1
		elif  event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			wheel -= 1


func _on_sheep_button_down() -> void:
	money += mod_money
	random_position_1 = Vector2(
		clamp(randi() % int($Field.size.x), 0, int($Field.size.x)),
		clamp(randi() % int($Field.size.y), 0, int($Field.size.y))
	)
	start_position_1 = $Field/Sheep.position
	t_1 = 0.0
	s_1 = (random_position_1 - start_position_1).length()
	if s_1 == 0:
		s_1 = 1


func _on_sheep_2_button_down() -> void:
	money += mod_money
	random_position_2 = Vector2(
		clamp(randi() % int($Field.size.x), 0, int($Field.size.x)),
		clamp(randi() % int($Field.size.y), 0, int($Field.size.y))
	)
	start_position_2 = $Field/Sheep2.position
	t_2 = 0.0
	s_2 = (random_position_2 - start_position_2).length()
	if s_2 == 0:
		s_2 = 1


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
		elif products[1].text == "Second Sheep":
			$Field/Sheep2.position = Vector2(0, 0)
			products.pop_at(1)


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
