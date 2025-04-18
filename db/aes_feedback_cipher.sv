module aes_feedback_cipher (
    input        clk,       // S: Clock 
    input        rst,       // S: Reset 
    input        new_msg,   // S: New message, start the process 
    input        enc_dec,   // S: Encryption or Decryption
    input        in_valid,  // S: Input valid 
    output       out_ready, // S: Output valid signal
    input  [7:0] key,       // W: key for IV Round Zero
    input  [7:0] in_msg,    // W: Enc: P[i] - Dec: C[i]
    output [7:0] out_msg    // W: Enc: C[i] - Dec: P[i]
);
    // Internal Circuit Registers
    logic [7:0] iv;             // Initialization Vector (Round 0: Key, Round i: C[i-1])
    logic [7:0] sbox_out;       // Output of SBox Combinational Circuit
    logic [7:0] round_out;      // Output of the XOR operation
    logic done;                 // Successful Round Completition Flag

    // AES SBox Instance
    aes_sbox feedback_cipher_sbox(
        .in(iv),
        .out(sbox_out)
    );

    always_ff @(posedge clk or negedge rst) begin
        if (!rst) begin
            // Reset all internal registers
            iv <= 8'b0;
            round_out <= 8'b0;
            done <= 1'b0;
        end
        else if (new_msg) begin
            // A new message begins, load the key for Round 0
            iv <= key;
        end 
        else if (in_valid) begin
            // The input is decalred valid, proceed with cipher logic
            if (enc_dec) begin
                // Encryption: C[i] = P[i] ^ S(IV)
                round_out <= in_msg ^ sbox_out;
                // Feedback: IV[i+1] = C[i]
                iv <= in_msg ^ sbox_out;
            end
            else begin
                // Decryption: P[i] = C[i] ^ S(IV)
                round_out <= in_msg ^ sbox_out;
                // Feedback: IV[i+1] = C[i]
                // The input message is the actual ciphertext, which we also need for the feedback process
                iv <= in_msg;
            end 
            done <= 1'b1;
        end
        else begin 
            done <= 1'b0;
        end
    end
    
    assign out_msg = round_out;
    assign out_ready = done;
endmodule
