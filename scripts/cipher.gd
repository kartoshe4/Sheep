extends Node

var aes = AESContext.new()
var text

var text_link = "/home/ilya/Документы/Hackaton/text.txt"

var encrypted_ecb

var data = " "

# sheepiscool
const TEXT = "92be66296a24458eafc5594169515a57"

func _ready() -> void:
	pass


func save_to_file(content, link):
	var file = FileAccess.open(link, FileAccess.WRITE)
	file.store_string(content)

func load_from_file(link):
	var file = FileAccess.open(link, FileAccess.READ)
	var content = file.get_as_text()
	return content


func _process(delta: float) -> void:
	data = str($"..".money)
	if data.length() > 5 and data.length() < 16:
		encrypt_data()
		save_to_file(text, text_link)


func encrypt_data() -> void:
	var key = "Afrn"  # Ключ длиной 5 байт (32 бита)
	var iv = "TheSocietyofFact"  # IV должен быть ровно 16 байт

	# Убедитесь, что длина данных кратна 16, добавьте паддинг, если нужно
	data = pad_data(data)

	# Расширение ключа до 16 байт (AES-128)
	var extended_key = pad_edges(key)

	# Шифрование в режиме ECB
	aes.start(AESContext.MODE_ECB_ENCRYPT, extended_key.to_utf8_buffer(), iv.to_utf8_buffer())
	encrypted_ecb = aes.update(data.to_utf8_buffer())
	aes.finish()

	# Обновление текста в Label
	text = encrypted_ecb.hex_encode()


func pad_data(data: String) -> String:
	# Добавление паддинга для кратности 16 байтам
	var padding_length = 16 - (data.length() % 16)
	return data + str(padding_length).repeat(padding_length)


func pad_edges(key: String) -> String:
	var res = String(key)
	for i in range(16 - key.length()):
		res += "0"
	# Расширение короткого ключа до 16 байт
	return res # Заполнение нулями до 16 байт
