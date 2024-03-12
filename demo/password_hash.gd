extends MarginContainer

const units = {
	'bytes': 1,
	'kibibytes': 1024,
	'mebibytes': 1024 * 1024,
	'kilobytes': 1000,
	'megabytes': 1000 * 1000,
}

var crypto = Crypto.new()

func _ready():
	for k in units:
		$Widgets/Memory/Units.add_item(k)
	$Widgets/Memory/Units.select(units.keys().find('mebibytes'))

func _on_randomize_pressed():
	var salt = crypto.generate_random_bytes(16)
	$Widgets/Salt/Value.text = Marshalls.raw_to_base64(salt)

func current_unit():
	var id = $Widgets/Memory/Units.get_selected_id()
	return units[$Widgets/Memory/Units.get_item_text(id)]

func _on_hash_pressed():
	var password = $Widgets/Password.text.to_utf8_buffer()
	var salt = Marshalls.base64_to_raw($Widgets/Salt/Value.text)
	if salt.size() != 16:
		$Widgets/InvalidSalt.visible = true
		return
	$Widgets/InvalidSalt.visible = false
	var iterations = int($Widgets/Iterations/Value.value)
	var memory = int($Widgets/Memory/Value.value)
	memory *= current_unit()
	var output_size = int($Widgets/OutputSize/Value.value)
	var hashed = GDSodium.argon2id_hash(
		password, salt,
		iterations, memory,
		output_size
	)
	$Widgets/Output.text = Marshalls.raw_to_base64(hashed)
