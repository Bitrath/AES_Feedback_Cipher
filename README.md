# Feedback Cipher (AES-SBox based)

This repository contains the design, implementation, and testing of an AES-SBox-based Feedback Cipher. The project was developed for the Hardware and Embedded Security Master's course at the University of Pisa (Academic Year 2023/2024).

## Authors
* Nicolò Zarulli @[Bitrath](https://github.com/Bitrath) 
* Giacomo Lombardi @[LombardiGiacomo](https://github.com/LombardiGiacomo)

## Overview

The goal of this project is to implement a simplified Feedback Cipher schema that supports both encryption and decryption functionalities. The cipher utilizes an 8-bit Initialization Vector (IV) and the substitution box (S-Box) transformation from the Advanced Encryption Standard (AES).

### Cryptographic Operations
**Encryption:** The plaintext byte $P[i]$ is XORed with the S-box transformation of the $IV[i]$.
* Formula: $C[i] = P[i] \oplus S(IV[i])$.
* The $IV$ is initialized with an 8-bit symmetric key $K$ ($IV[0]=K$).
* For subsequent rounds, the $IV$ updates using the previous ciphertext byte ($IV[i]=C[i-1]$).

**Decryption:** By keeping the S-Box in "encryption mode," the XOR properties allow the extraction of the plaintext from the ciphertext.
* Formula: $P[i] = C[i] \oplus S(IV[i])$.
* Because $S \oplus S = 0$, the operation effectively reverses the encryption.

## High-Level Model (Python)

A high-level implementation is provided in Python (version 3.10+) to outline the simple and direct logic of the cipher before hardware synthesis.

**`utils.py`:** Contains the core backbone of the cipher, encapsulating the `SBox` and `FeedbackCipher` classes. 
* **`main.py`:** Provides execution examples, including string encryption/decryption, hexadecimal array testing, and propagation delay simulations.

## RTL Design (SystemVerilog)
The hardware implementation relies on SystemVerilog files processed through Modelsim for zero-delay simulation and Quartus Prime for synthesis.

### Architecture

The cipher implements a revised Single-inter-round-pipelined architecture to handle the feedback path required for successive rounds. 
* **Preliminary Round ($i=0$):** The IV loads the symmetric key to access the S-Box.
* **Successive Rounds ($i > 0$):** The IV loads the feedback data from the previous round.
* **Multiplexer Control:** A feedback multiplexer, controlled by the `enc_dec` flag, ensures the correct data is fed back into the register depending on whether an encryption or decryption operation is occurring.

### Module Interface (`aes_feedback_cipher.sv`)
* `clk`, `rst`: Clock and asynchronous active-low reset signals.
* `new_msg`: Input flag signaling the start of a new message to initialize the key.
* `enc_dec`: Functionality flag indicating encryption (1) or decryption (0).
* `in_valid`: Flag indicating the input data is valid and stable.
* `key`: 8-bit symmetric key for IV initialization.
* `in_msg` / `out_msg`: 8-bit ports for input and output messages.
* `out_ready`: Flag indicating the output data is ready and stable.

## Functional Verification
Two testbenches were created to verify module functionality:

* **Correct Usage (`aes_feedback_cipher_tb.sv`):** Asserts the `rst` signal, loads the `key` via the `new_msg` flag, and successfully feeds plaintext bytes sequentially while checking against expected ciphertext, followed by a successful decryption test.
* **Incorrect Usage (`wrong_use_tb.sv`):** Demonstrates improper usage by asserting `new_msg` and `in_valid` simultaneously while keeping it high for a full clock period. This shows how the first byte fails to encrypt, shifting the proper encryption to the second byte.

## FPGA Implementation Results
The design was fitted onto an Intel Cyclone V `5CGXFC9D6F27C7` FPGA device using Quartus Prime.

* **Logic Utilization:** Uses less than 1% of total resources (50 out of 113,560 ALMs), demonstrating a highly scalable and lightweight design.
* **Registers:** Utilizes only 18 registers.
* **Pin Usage:** Requires 30 out of 378 available pins (approx. 8%), indicating higher I/O communication relative to its logic footprint.
* **Static Timing Analysis (STA):** * Without virtual pins: Maximum clock frequency of **93.98 MHz**.
* With virtual pins: Maximum clock frequency of **150.69 MHz**.
