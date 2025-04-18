import utils

# Setup
aes_sbox = utils.SBox()
cipher = utils.FeedbackCipher(aes_sbox)

# -- 1 -- Test String
print("\n-- (1) TEST STRING --")
# Informations Setup
plaintext = "LanaDelRey"
print(f"SETUP\n-> Plaintext: {plaintext}")

print(f"AES SBox ENCRYPTION")
# ciphertext = cipher.encrypt_string(plaintext)
ciphertext = cipher.encrypt(plaintext, 1, False)
print(f"-> Ciphertext: {ciphertext}")

print(f"AES SBox DECRYPTION")
# original = cipher.decrypt_string(ciphertext)
original = cipher.decrypt(ciphertext, 1)
print(f"-> Original Plaintext: {original}")

# -- 2 -- Test Hex Array
print("\n-- (2) TEST HEX ARRAY --")
# Informations Setup
plaintext_hex = [0x3c, 0x7f, 0x9B, 0x5e, 0x1a, 0x9c, 0x2a, 0x12, 0x39, 0xb5]
print("SETUP\n-> Plaintext:", [hex(x) for x in plaintext_hex])

print(f"AES SBox ENCRYPTION")
# ciphertext_hex = cipher.encrypt_array(plaintext_hex, False)
ciphertext_hex = cipher.encrypt(plaintext_hex, 2, False)
print("-> Ciphertext", [hex(x) for x in ciphertext_hex])

print(f"AES SBox DECRYPTION")
# result_hex = cipher.decrypt_array(ciphertext_hex)
result_hex = cipher.decrypt(ciphertext_hex, 2)
print("-> Original Plaintext:", [hex(x) for x in result_hex])

# -- 3 -- Test Propagation Delay
print("\n-- (3) Propagation Delay --")
# Informations Setup
plaintext_hex = [0x3c, 0x7f, 0x9B, 0x5e, 0x1a, 0x9c, 0x2a, 0x12, 0x39, 0xb5]
print("SETUP\n-> Plaintext:", [hex(x) for x in plaintext_hex])

print(f"AES SBox ENCRYPTION")
# ciphertext_hex = cipher.encrypt_array(plaintext_hex, True)
ciphertext_hex = cipher.encrypt(plaintext_hex, 2, True)
print("-> Ciphertext", [hex(x) for x in ciphertext_hex])

print(f"AES SBox DECRYPTION")
# result_hex = cipher.decrypt_array(ciphertext_hex)
result_hex = cipher.decrypt(ciphertext_hex, 2)
print("-> Original Plaintext:", [hex(x) for x in result_hex])