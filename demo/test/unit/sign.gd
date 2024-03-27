extends UnitTest

func test_generate():
	var kp = GDSodiumSign.generate_keypair()
	assert_false(kp.private_key.is_empty() or kp.public_key.is_empty())

func generate_case():
	var kp = GDSodiumSign.generate_keypair()
	var crypto = Crypto.new()
	var message = crypto.generate_random_bytes(32)
	var message2 = crypto.generate_random_bytes(32)
	var signer = GDSodiumSign.new()
	signer.update(message)
	signer.update(message2)
	return SigSet.new([
		GDSodiumSign.private_key_to_seed(kp.private_key),
		kp.private_key,
		kp.public_key,
		message,
		GDSodiumSign.sign_detached(message, kp.private_key),
		message2,
		signer.final_sign(kp.private_key)
	])

func run_sign(f: Callable):
	var fixed = run_cases(
		f,
		sign_sets
	)
	var random = run_cases(
		f,
		range(10).map(func(a): return generate_case())
	)
	return fixed and random

func test_generate_seed():
	return run_sign(
		func(case):
			var kp = GDSodiumSign.generate_keypair(case.seed)
			return (kp.private_key == case.private_key
				and kp.public_key == case.public_key)
	)

func test_private_key_to_seed():
	return run_sign(
		func(case):
			var seed = GDSodiumSign.private_key_to_seed(case.private_key)
			return seed == case.seed
	)

func test_private_key_to_public_key():
	return run_sign(
		func(case):
			var pk = GDSodiumSign.private_key_to_public_key(case.private_key)
			return pk == case.public_key
	)

func test_sign_detached():
	return run_sign(
		func(case):
			var sig = GDSodiumSign.sign_detached(
				case.message, case.private_key)
			return sig == case.signature
	)

func test_sign():
	return run_sign(
		func(case):
			var sig = GDSodiumSign.sign(
				case.message, case.private_key)
			return sig == case.signature + case.message
	)

func test_verify_detached():
	return run_sign(
		func(case):
			return GDSodiumSign.verify_detached(
				case.message, case.signature, case.public_key)
	)

func test_open():
	return run_sign(
		func(case):
			var message = GDSodiumSign.open(
				case.signature + case.message, case.public_key)
			return message.valid and message.message == case.message
	)

func test_sign_multipart():
	return run_sign(
		func(case):
			var signer = GDSodiumSign.new()
			signer.update(case.message)
			signer.update(case.message2)
			return signer.final_sign(case.private_key) == case.signature2
	)

func test_verify_multipart():
	return run_sign(
		func(case):
			var signer = GDSodiumSign.new()
			signer.update(case.message)
			signer.update(case.message2)
			return signer.final_verify(case.signature2, case.public_key)
	)


# seed, private, public, message, signature, message2, sig2
# such that sign(message, private_key) = signature
# and update(message), update(message2), final_sign() = sig2
const sign_sets_array = [
	['yxodmQ6P66AztesUZ3qol3F9aANC5rdrCUdgizyK+ig=',
	'yxodmQ6P66AztesUZ3qol3F9aANC5rdrCUdgizyK+ijQ'
	+ 'KETWdKo6c5DNOtQ99Py8VsujHJIwtGll+2RHhJpfIw==',
	'0ChE1nSqOnOQzTrUPfT8vFbLoxySMLRpZftkR4SaXyM=',
	'Sw77ydIxJa1ELV6FVCGoeSCE9qByaHZ5l49As1UE5Ww=',
	'+/Az7GOymKNRLYZ4lwEde/gRERHPjPTlh4PAbIQjR+HN'
	+ 'zKMXBQOXV0oQaM/UUn7Xx51dJRQbtj7SeMEcYbClDA==',
	'XNcQjYtclW2D5zKdP0usH4eJPshm/IIrgRt3QwlIBYc=',
	'Co1UXEml6igfSBck3c7RpGUN7c0BsZu7diLQZ1gJy0LR'
	+ 'UZJhX1nZTlDSrWtdQsS6hCQg8/QsJwPZpCSjoqvLCg=='],
	['YnKYxYaO7Gc/Zs+aMp9nteB9xHSlnj4fdJCxwgkrWow=',
	'YnKYxYaO7Gc/Zs+aMp9nteB9xHSlnj4fdJCxwgkrWozV'
	+ 'CuA/LAi1zMjG93mVEoQSIJd1JF1wstF9dyOdYDRtEA==',
	'1QrgPywItczIxvd5lRKEEiCXdSRdcLLRfXcjnWA0bRA=',
	'I4XfmnGOPXt0jpo2Yll6nFzG+UMVlr4cCbRbYcM7d9E=',
	'C+elhr0ZU5z/V3YWQyRjShvt34pHuz3K5xoRlyeXA2rx'
	+ 'mJWT7UobAEAlfJorr2/XzDwm0WlrVKH9m7ji+DFWBg==',
	'76Qec9AuVyEzxfWquJHNrL4BJdEIS7Yp/K7bk1SP2DE=',
	'V1es7GlPqM3ysaCWK7a3g4WcTxjUdGToLC2Wx7RpclJT'
	+ '/TBGKlhLxK9iYzSwqLdcth1v9+jEviete3RYhk4hAA=='],
	['czPYkCk9XMao8JI6re+AzkRtEvtXT0olPTn4+pKcznk=',
	'czPYkCk9XMao8JI6re+AzkRtEvtXT0olPTn4+pKcznl3'
	+ 'IUWsMF/eqNao8ZOaeQUnQygLHBiBTXxdyFdHF5cAzw==',
	'dyFFrDBf3qjWqPGTmnkFJ0MoCxwYgU18XchXRxeXAM8=',
	'MHITmUTftZRm8ajAbGIuSnjMgfi5ueeh+CZ6/T0Yez8=',
	'DjmgPiPbbO3mdv4NJ+c4fJTajRVc61oB7Qc+bylKuZJp'
	+ 'orc+jQRLXSxlsOjzENzFTPzW9VbFsriEIRBxsVYqCg==',
	'a2+cGTJzt0pmNCs1vPdY1mN7HEPntPwLFTJNF7/l/9Y=',
	'ZN+7EVYHRqOkRUOXMQZOMxGO3VtGp/Jwucj6pgoZ/3yx'
	+ 'd5yoFTVfRr9hE2uTMPCzNGQHUpfdbGmppecTADU4BQ=='],
	['eY7dV+9hkI9XO//buk1VRTNMUAxkjU42l1An4t2QxXs=',
	'eY7dV+9hkI9XO//buk1VRTNMUAxkjU42l1An4t2QxXuE'
	+ 'XYW6/C7/LeTZwlysN6Dvk5P1sq0AjbeA2IWi9WudPg==',
	'hF2Fuvwu/y3k2cJcrDeg75OT9bKtAI23gNiFovVrnT4=',
	'RFEghyxwAnp8A2xOm0/7BhWIhSt80YZKYVlTICnfYYc=',
	'FYjg30aOz6TB8eddxsFL58yVl0Y5rEQsDq7jU1XfupL9'
	+ 'JA0H/Tty4x+lFtniAlb0Ll3aK0D7R1b79fOR5udbDw==',
	'E5XSLGeC2hD6hcOxY9v65E5WGGhEE/tgd+pJcoiMKXk=',
	'pwEK2zw9FvszLz672Tefwu0C+PKEcZecG9JdRodAXtwN'
	+ 'dlSZ+6gZukmDol7jc7PkpM6r5GAiZ0+a+oZwVby3Aw=='],
	['Tj8qvd17aVPwmI/4e9FfmHgry3zxZXNIBBe4qgwBBDs=',
	'Tj8qvd17aVPwmI/4e9FfmHgry3zxZXNIBBe4qgwBBDs/'
	+ 'ZDIc0EOOgZol1Snq3MOMMj5e1OAZRATSfFLYf7Xo5w==',
	'P2QyHNBDjoGaJdUp6tzDjDI+XtTgGUQE0nxS2H+16Oc=',
	'zL/mK5n5ekLf3vNbY2GYH4HNS+eNzqlif2D5xL3S6A0=',
	'KJ0bgx75u9U6xHz/8G/HpQS6aN3nFAxj2nDJihIy20SF'
	+ 'Eeoqcge6jHVa563fbnrvdrSfDMo055wuCUA1btLjAA==',
	'WDD061jdxpJsWHzwC4b/pTtvLSl3qbsMaCcwBDGesRI=',
	'Ha7yPhaoJxjDTTcN4kDbRHuZgPu6IWP5K89nMlaGm7u1'
	+ 'fnvbQa3CELaqKRcEQkznBq/al+ExWyoy3bB/YkmRAw=='],
	['Xr0UAVmiaBUf+mgdMM9ElUPYRnKIdM7jWKTOpy9LRDo=',
	'Xr0UAVmiaBUf+mgdMM9ElUPYRnKIdM7jWKTOpy9LRDoW'
	+ 'XNmKU6ZhE2mpbt06iIfBnw9GYgFHFcHYuzv9g/6mrg==',
	'FlzZilOmYRNpqW7dOoiHwZ8PRmIBRxXB2Ls7/YP+pq4=',
	'U+L7rx9LF4Lgf1udqVid1LDqWTJDKgLUQJSpMwHodH8=',
	'60MX9vNDbkH3KOl+/q5GA+a08+yuLOgxh2j0HxIL7y81'
	+ 'QnsVPzgzOa+qBUJcOnAYcsI8iAqCx3d6njC6Z5iLCQ==',
	'B7Xd3SeJo81veQt6tfaxETZmfhphdegCoMzy5FOnhHM=',
	'MsuwC7J7ZzvxH+mx7ZCcWLYWcaKbd3Cdpbg3XxRZxcBr'
	+ 'GuaOBd4+1braRCy8XF1hLFOcJngvErhoc/oRVaC8BA=='],
	['h36JGQIKTyit49D3K0Uen0Es+YqoMJEUSMJuHEM7m3g=',
	'h36JGQIKTyit49D3K0Uen0Es+YqoMJEUSMJuHEM7m3iZ'
	+ '8vftGvlC6EarnQwhJQ9VZ7aeF/WE5AgawF7BezN+mg==',
	'mfL37Rr5QuhGq50MISUPVWe2nhf1hOQIGsBewXszfpo=',
	'IlXFWC02K7yNcSC8U8lOoXqoRvUYMGsZW/Q6bNjbuV8=',
	'VRXhZGrdRf0Yka7786v3XubI5r37ClTGgBj3Of0qyxT9'
	+ 'jNZ3W5+uyYjvYRr7BvTHhaW6tT8HuDjuPr+taysYDw==',
	'XWFvkrYq6SOVkNbIsR4y47fG81UwrMgfbeFjptO/awQ=',
	'P/BUCHe4Wfdy/tAJ3ppQ9cElRCII9QcjPbbw7oEoV5hd'
	+ 'oixumSVtKH4c6iyIFZBKDhGWqDK0sROwbdCGpxXDBA=='],
	['7He9zq9l9zJ9Fksr0IMjYlFriPBKrLUMTLlCTqG0tOY=',
	'7He9zq9l9zJ9Fksr0IMjYlFriPBKrLUMTLlCTqG0tOaB'
	+ 'ST0g8G28bt/zfSu75fMYXxKuxiorT5s9ejzbihmnGg==',
	'gUk9IPBtvG7f830ru+XzGF8SrsYqK0+bPXo824oZpxo=',
	'3x6fEXfh443SBtWcSF2aq14p9tMSU7baLmTCrGRUwH4=',
	'+qSmmnyHnZ/trEIlaaepTILjs56gsaJw6G/BtrWkvMRw'
	+ '4ErZoe5hs6HRa5IX9TnI/03ijRPhTMgZjHOJ/bWwDA==',
	'4yH7nKpEzmhS+NfeIJ2Ro2iqgDeG7jiSHNpAkTySy1k=',
	'C/Fv+SGD/JQtvigS6QjCVReLRaqCmRUm9BAqnPZNx+wn'
	+ 'OIqVsAmRxp0mMq6uaFOC8kjvccHvt56kFiCNN44UBQ=='],
	['cVCN5QZMCSvgjnBVjj32P395scF9V54PEZATaey1uwk=',
	'cVCN5QZMCSvgjnBVjj32P395scF9V54PEZATaey1uwmw'
	+ '4xE2NFrHoyxY7UXE5FX4pnaF/OkqrZgB43+ZJtSCtw==',
	'sOMRNjRax6MsWO1FxORV+KZ2hfzpKq2YAeN/mSbUgrc=',
	'QNzwevFd8JPgi31u5rzhuLfunx293RZl9hZo9xjV8jk=',
	'mOduoXqRR/YYNz2bACWaIxX+qxfYJasQ1/EXzEBrdmnN'
	+ 'SEHRljUEt0l4DOU9kKA5et3bxbqkDo4RrWbLUTNsAw==',
	'l15aFbHwoG+KFUHR4ZWQLLRBGvQMWI8SQiKFtR/1nHU=',
	'Udq5AnnRp5k19K74ELX6uSBkNJUtPsxQ1hnGlVKtsH9q'
	+ 'dvn+9eaBaBpZs3gkzTaNAH8NSZWNAHMyHI5p1m7EBQ=='],
	['bmzU4ovbHMPlDNMBKven8YtH/ijJqRZ+o2MSpaU9AgE=',
	'bmzU4ovbHMPlDNMBKven8YtH/ijJqRZ+o2MSpaU9AgGg'
	+ 'ONs5d0w5UbN+IqYcRwaLf6xC2U5l4n2nX3YQabgCKg==',
	'oDjbOXdMOVGzfiKmHEcGi3+sQtlOZeJ9p192EGm4Aio=',
	'RRISNuy4elYHY1uBnKSuqEz9Y/apKjNgJkCdW8FMlOM=',
	'9OMRy2HqX/QXJMwg7BaV14gKpb0Q0JX/JcKxk1mmNkAK'
	+ 'ziRWaAkfX27pECIeWc9U5JUme0vfp6NktSOgJyG1DQ==',
	'mZhUj1C7DbZQWzowfROn64MeZuVG8xkqU3zq8l2Pwho=',
	'4CFHlli9/NQw/EclmLR7jiMh4tIj/7Nlwzof/gJ2iABA'
	+ 'wnpoHOSp8gCWz3Dn5vV+v2edOzfjH92lg+K5bWeBAg=='],
]

class SigSet:
	var seed
	var private_key
	var public_key
	var message
	var signature
	var message2
	var signature2
	func _init(e):
		e = e.map(func(b):
			return Marshalls.base64_to_raw(b) if b is String else b)
		seed = e[0]
		private_key = e[1]
		public_key = e[2]
		message = e[3]
		signature = e[4]
		message2 = e[5]
		signature2 = e[6]

var sign_sets = sign_sets_array.map(SigSet.new)
