// --- FBC TEST ---
// Usually, the key should be given to the cipher (at least) one clock before the first plaintext block.
// The following test demonstrates that if the new_msg flag and the in_valid flag are set at 1 at the same time, 
//   meaning that the key and the first plaintext block are ready at the same posedge clock, 
//   then the encryption of the first message block will be skipped and the actual encryption will begin with
//   the second block.

/* 
    Encryption
        P[0,…9]
        C[0] = 00
        C[1] = P[1] + S(K)
        C[2] = P[2] + S(C[1])
        C[3] = P[3] + S(C[2])
        ...

    Decryption
        C[0,…9]
        P[0] = C[0] + S(K) 
        P[1] = C[1] + S(C[0])
        P[2] = C[2] + S(C[1])
        ...
*/

module tb_wrong_aes_feedback_cipher;

    reg clk;
    reg rst_n;
    reg new_msg;
    reg enc_dec;        // 1 to encrypt, 0 to decrypt
    reg in_valid;
    reg [7:0] key;
    reg [7:0] in_msg;
    wire [7:0] out_msg;
    wire out_ready;

    reg [7:0] plaintext [10];  // Array to contain the input bytes for the test
    reg [7:0] expected_ciphertext [10]; // Array to contain the output bytes for the test
    reg [7:0] encrypted_output [10];  
    reg [7:0] decrypted_output [10]; 

    aes_feedback_cipher dut(
        .clk (clk),
        .rst (rst_n),
        .key (key),
        .in_msg (in_msg),
        .new_msg (new_msg),
        .enc_dec (enc_dec),
        .in_valid (in_valid),
        .out_msg (out_msg),
        .out_ready (out_ready)
    );

    initial begin
        clk = 0;
        forever #5 clk = !clk;
    end

    initial begin
        // Signals initialization
        rst_n = 0;
        new_msg = 0;
        enc_dec = 1; 
        in_valid = 0;
        key = 8'hA5; // Testing key

        #10 rst_n = 1;

        $readmemh("tv/inputs.txt", plaintext);
        $readmemh("tv/outputs.txt", expected_ciphertext);

        $display("Starting encryption test");
        for (int i = 0; i < 10; i++) begin
            
            if (i == 0) begin
                new_msg = 1;    // A new message begins
                //#10;            // Keeps new_msg=1 for one clock cycle
                //new_msg = 0;    
            end
            
            //#10; 
            in_msg = plaintext[i]; 
            in_valid = 1; 
            #10 in_valid = 0;
            new_msg = 0;
            //#10 new_msg = 0;

            //wait(out_ready);
            encrypted_output[i] = out_msg;
            if (encrypted_output[i] === expected_ciphertext[i])
                $display("Encryption %0d correct: \n\tInput byte: %h \n\tOutput byte: %h \n\tExpected output byte: %h", i+1, plaintext[i], encrypted_output[i], expected_ciphertext[i]);
            else
                $display("Encryption %0d failed: \n\tInput byte: %h \n\tOutput byte: %h \n\tExpected output byte: %h", i+1, plaintext[i], encrypted_output[i], expected_ciphertext[i]);
        end

        #50;

        $display("Starting decryption test (decryption of the bytes resulting from the previous encryption)");

        enc_dec = 0; // Decryption
        
        // Try to decrypt the encrypted message to see that 
        // a correct decryption over a wrong ciphertext results
        // in something different from the original message
        for (int i = 0; i < 10; i++) begin
            
            if (i == 0) begin
                new_msg = 1;    // A new message begins
                #10;            // Keeps new_msg=1 for one clock cycle
                new_msg = 0; 
            end
            
            //#10; 
            // For the decryption use the same sequence resulting
            // from the encryption
            in_msg = encrypted_output[i]; 
            in_valid = 1; 
            #10 in_valid = 0; 
            //#10;

            wait(out_ready);
            decrypted_output[i] = out_msg;
            if (decrypted_output[i] === plaintext[i])
                $display("Decryption %0d correct: \n\tInput byte: %h \n\tOutput byte: %h \n\tExpected output byte: %h", i+1, encrypted_output[i], decrypted_output[i], plaintext[i]);
            else
                $display("Decryption %0d failed: \n\tInput byte: %h \n\tOutput byte: %h \n\tExpected output byte: %h", i+1, encrypted_output[i], decrypted_output[i], plaintext[i]);
        end

        $stop;
    end
endmodule