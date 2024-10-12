extends Control

#var config
#var path_to_save_file := "user://game.save"
#var section_name := "game" #!!!

var aes = AESContext.new()
var text_link = "/home/ilya/Документы/Hackaton/game.save"
var array = []

var edit_text
var text

var money = 10000000000000
var money_per_second = 0
var mod_money = 1

var casino

var mod_product = 1

var wheel = 0
var is_mouse_entered = false

var sheep1_pos = Vector2()
var sheep2_pos = Vector2(-1000, 1000)

var hay1_vis = false
var hay2_vis = false

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

var is_rank = false

var damage = 10000

func save_to_file(link):
	array.clear()
	var file = FileAccess.open(link, FileAccess.WRITE)
	array.append(money)
	array.append(money_per_second)
	array.append(mod_money)
	array.append(sheep1_pos.x)
	array.append(sheep1_pos.y)
	array.append(sheep2_pos.x)
	array.append(sheep2_pos.y)
	array.append(hay1_vis)
	array.append(hay2_vis)
	array.append(damage)
	file.store_string(encrypt(array))

func load_from_file(link):
	var file = FileAccess.open(link, FileAccess.READ)
	text = file.get_as_text()
	array = decrypt(text)
	if array.size() != 0:
		money = array[0]
		money_per_second = array[1]
		mod_money = array[2]
		if mod_money == 0:
			mod_money = 1
		$Field/Sheep.position.x = array[3]
		$Field/Sheep.position.y = array[4]
		$Field/Sheep2.position.x = array[5]
		$Field/Sheep2.position.y = array[6]
		if $Field/Sheep2.position == Vector2():
			$Field/Sheep2.position = Vector2(-1000, 1000)
		$Field/Hay.visible = array[7]
		$Field/Hay2.visible = array[8]
		damage = array[9]
	else:
		save_to_file(text_link)


func decimal_to_base(decimal_number: int, base: int) -> String:
	if base < 2 or base > 37:
		return ""  # Поддерживаем только базы от 2 до 36

	var result = ""
	while decimal_number > 0:
		var remainder = decimal_number % base
		if remainder < 10:
			result = str(remainder) + result
		else:
			result = String(char(remainder - 10 + 65)) + result  # Для значений от 10 до 35
		decimal_number /= base

	return result


func hex_to_decimal(hex_string: String) -> int:
	var decimal_value = 0
	var length = hex_string.length()

	# Перебираем каждый символ в строке
	for i in range(length):
		var char = hex_string[length - 1 - i]  # Берем символ с конца
		
		var let = {
			"0": 0,
			"1": 1,
			"2": 2,
			"3": 3,
			"4": 4,
			"5": 5,
			"6": 6,
			"7": 7,
			"8": 8,
			"9": 9,
			"A": 10,
			"B": 11,
			"C": 12,
			"D": 13,
			"E": 14,
			"F": 15,
			"G": 16,
			"H": 17,
			"I": 18,
			"J": 19,
			"K": 20,
			"L": 21,
			"M": 22,
			"N": 23,
			"O": 24,
			"P": 25,
			"Q": 26,
			"R": 27,
			"S": 28,
			"T": 29,
			"U": 30,
			"V": 31,
			"W": 32,
			"X": 33,
			"Y": 34,
			"Z": 35
		}
		if not (char in let):
			var file = FileAccess.open(text_link, FileAccess.WRITE)
			file.store_string("")
			get_tree().quit()
		# Добавляем значение к десятичному результату
		else:
			decimal_value += let[char] * pow(36, i)

	return decimal_value


func encrypt(data: Array) -> String:
	var arr = []
	for i in data:
		arr.append(decimal_to_base(i, 36))
	var max_size = 10
	for i in arr:
		if (i.length() > max_size):
			max_size = i.length()
	for i in range(arr.size()):
		while (arr[i].length() < max_size):
			arr[i] = '0' + arr[i]
	arr.insert(0, decimal_to_base(max_size, 16))
	var d = ""
	for i in arr:
		d += str(i)
	return str(d)

func decrypt(data):
	var arr = []
	var size = hex_to_decimal(data.substr(0,1))
	if size > 0:
		for i in range(1, data.length(), size):
			arr.append(hex_to_decimal(data.substr(i, size)))
	return arr


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	edit_text = $Shop/TextEdit
	
	$Field/Hay.visible = false
	$Field/Hay2.visible = false
	
	load_from_file(text_link)
	
	$Backsound.play()
	$Timer.start()
	start_position_2 = Vector2($Field/Sheep2.position)
	
	products.append(Product.new(10, "+1 per click"))
	products.append(Product.new(150, "+1 per second"))
	products.append(Product.new(1000, "Hay"))
	products.append(Product.new(100000, "Second Sheep"))
	products.append(Product.new(0, "Casino(x2)"))
	products.append(Product.new(0, "Casino(x3)"))
	products.append(Product.new(0, "Casino(x10)"))
	products.append(Product.new(int(pow(10, 15)), "flag"))
	products.append(Product.new(10000000000, "password"))


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
	
	if edit_text.text == "ObshchFackt":
		$Shop/Win.play()
		$Shop/Label.text = "Теперь вы можете купить модификатор к урону"
		is_rank = true
		edit_text.visible = false
		edit_text.clear()
	save_to_file(text_link)
	if is_rank:
		products.append(Product.new(10000000, "+1 damage"))
		is_rank = false
	
	sheep1_pos = $Field/Sheep.position
	sheep2_pos = $Field/Sheep2.position

	hay1_vis = $Field/Hay.visible
	hay2_vis = $Field/Hay2.visible
	
	if not($Backsound.is_playing()):
		$Backsound.play()
	
	if mod_product < 1 or products[1].text == "Second Sheep"\
		or products[1].text == "flag" or products[1].text == "Hay"\
		or products[1].text == "Casino(x2)" or products[1].text == "Casino(x3)"\
		or products[1].text == "Casino(x10)":
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
			shift_products_down()
			$Shop/Turn.play()
			wheel -= 2
		elif wheel < 0:
			shift_products_up()
			$Shop/Turn.play()
			wheel += 2

func _input(event: InputEvent) -> void:
	if not($Shop/Turn.is_playing()) and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			wheel += 1
		elif  event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			wheel -= 1


func sheep():
	if randi() % 20 == 12:
		$Sheep.play()
	else:
		$Kick.play()


func _on_sheep_button_down() -> void:
	sheep()
	money += mod_money
	random_position_1 = Vector2(
		clamp(randi() % int($Field.size.x), 0, int($Field.size.x)),
		clamp(randi() % int($Field.size.y), 0, int($Field.size.y))
	)
	$Field/Hay.position = random_position_1
	start_position_1 = $Field/Sheep.position
	t_1 = 0.0
	s_1 = (random_position_1 - start_position_1).length()
	if s_1 == 0:
		s_1 = 1


func _on_sheep_2_button_down() -> void:
	sheep()
	money += mod_money
	random_position_2 = Vector2(
		clamp(randi() % int($Field.size.x), 0, int($Field.size.x)),
		clamp(randi() % int($Field.size.y), 0, int($Field.size.y))
	)
	$Field/Hay2.position = random_position_2
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
		$Shop/Purchase.play()
		money -= products[1].price * mod_product
		if products[1].text == "+1 per click":
			mod_money += 1 * mod_product
		elif products[1].text == "+1 per second":
			money_per_second += 1 * mod_product
		elif products[1].text == "Hay":
			if not $Field/Hay.visible:
				$Field/Hay.visible = true
				$Field/Hay2.visible = true
				mod_money *= 2
			else:
				money += 1000
			products.pop_at(1)
		elif products[1].text == "Casino(x2)":
			casino = randi() % 2
			if (casino):
				money *= 2
			else:
				money /= 2
		elif products[1].text == "Casino(x3)":
			casino = randi() % 3 / 2
			if (casino):
				money *= 3
			else:
				money /= 3
		elif products[1].text == "Casino(x10)":
			casino = randi() % 10 / 9
			if (casino):
				money *= 10
			else:
				money /= 10
		elif products[1].text == "Second Sheep":
			$Field/Sheep2.position = Vector2(0, 0)
			products.pop_at(1)
		elif products[1].text == "flag":
			$Shop/Win.play()
			$Shop/Label.text = "flag{!successful&farmer!}"
			products.pop_at(1)
		elif products[1].text == "password":
			$Shop/Win.play()
			$Shop/Label.text = "Tmowmfazuezuoq"
			products.pop_at(1)
		if products[1].text == "+1 damage":
			damage += 1 * mod_product


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


func _on_timer_timeout() -> void:
	$Timer.start()
	money += money_per_second
