// FILE: newspaper_vending_machine.v
// PURPOSE: Main vending machine logic with 3 coin inputs (5, 10, 15 rupees)
// This is the TOP MODULE for synthesis

module newspaper_vending_machine(
    input wire clk,           // 100MHz clock from Basys 3
    input wire reset,         // Button for reset (BTNC)
    input wire coin5,         // Switch for 5 rupee coin (SW0)
    input wire coin10,        // Switch for 10 rupee coin (SW1)
    input wire coin15,        // Switch for 15 rupee coin (SW2)
    output reg newspaper,     // LED to indicate newspaper dispensed (LED15)
    output reg [4:0] led_amount // LEDs to show current amount (LED4-0)
);

    // State encoding - represents total amount inserted
    parameter S0 = 3'b000;   // 0 rupees
    parameter S5 = 3'b001;   // 5 rupees
    parameter S10 = 3'b010;  // 10 rupees
    parameter S15 = 3'b011;  // 15 rupees (dispense newspaper)
    parameter S20 = 3'b100;  // 20 rupees (extra - still dispense)
    parameter S25 = 3'b101;  // 25 rupees (extra - still dispense)
    
    reg [2:0] state, next_state;
    
    // Debounce counter - 10ms at 100MHz = 1,000,000 cycles
    parameter DEBOUNCE_TIME = 1_000_000;
    reg [19:0] debounce_counter5, debounce_counter10, debounce_counter15;
    
    // Two-stage synchronizers for switch inputs (prevent metastability)
    reg coin5_sync1, coin5_sync2;
    reg coin10_sync1, coin10_sync2;
    reg coin15_sync1, coin15_sync2;
    reg reset_sync1, reset_sync2;
    
    // Edge detection registers
    reg coin5_prev, coin10_prev, coin15_prev;
    wire coin5_edge, coin10_edge, coin15_edge;
    
    // Debounced signals
    reg coin5_stable, coin10_stable, coin15_stable;
    reg coin5_last, coin10_last, coin15_last;
    
    // Newspaper display timer (keep LED on for 2 seconds)
    parameter DISPLAY_TIME = 200_000_000; // 2 seconds at 100MHz
    reg [27:0] display_counter;
    reg displaying;
    
    // ====================
    // INPUT SYNCHRONIZATION (avoid metastability)
    // ====================
    always @(posedge clk) begin
        // Synchronize coin5
        coin5_sync1 <= coin5;
        coin5_sync2 <= coin5_sync1;
        
        // Synchronize coin10
        coin10_sync1 <= coin10;
        coin10_sync2 <= coin10_sync1;
        
        // Synchronize coin15
        coin15_sync1 <= coin15;
        coin15_sync2 <= coin15_sync1;
        
        // Synchronize reset
        reset_sync1 <= reset;
        reset_sync2 <= reset_sync1;
    end
    
    // ====================
    // DEBOUNCING LOGIC for coin5
    // ====================
    always @(posedge clk) begin
        if (reset_sync2) begin
            debounce_counter5 <= 0;
            coin5_stable <= 0;
            coin5_last <= 0;
        end else begin
            if (coin5_sync2 != coin5_last) begin
                debounce_counter5 <= 0;
                coin5_last <= coin5_sync2;
            end else if (debounce_counter5 < DEBOUNCE_TIME) begin
                debounce_counter5 <= debounce_counter5 + 1;
            end else begin
                coin5_stable <= coin5_last;
            end
        end
    end
    
    // ====================
    // DEBOUNCING LOGIC for coin10
    // ====================
    always @(posedge clk) begin
        if (reset_sync2) begin
            debounce_counter10 <= 0;
            coin10_stable <= 0;
            coin10_last <= 0;
        end else begin
            if (coin10_sync2 != coin10_last) begin
                debounce_counter10 <= 0;
                coin10_last <= coin10_sync2;
            end else if (debounce_counter10 < DEBOUNCE_TIME) begin
                debounce_counter10 <= debounce_counter10 + 1;
            end else begin
                coin10_stable <= coin10_last;
            end
        end
    end
    
    // ====================
    // DEBOUNCING LOGIC for coin15
    // ====================
    always @(posedge clk) begin
        if (reset_sync2) begin
            debounce_counter15 <= 0;
            coin15_stable <= 0;
            coin15_last <= 0;
        end else begin
            if (coin15_sync2 != coin15_last) begin
                debounce_counter15 <= 0;
                coin15_last <= coin15_sync2;
            end else if (debounce_counter15 < DEBOUNCE_TIME) begin
                debounce_counter15 <= debounce_counter15 + 1;
            end else begin
                coin15_stable <= coin15_last;
            end
        end
    end
    
    // ====================
    // EDGE DETECTION (detect rising edge = coin insertion)
    // ====================
    always @(posedge clk) begin
        if (reset_sync2) begin
            coin5_prev <= 0;
            coin10_prev <= 0;
            coin15_prev <= 0;
        end else begin
            coin5_prev <= coin5_stable;
            coin10_prev <= coin10_stable;
            coin15_prev <= coin15_stable;
        end
    end
    
    assign coin5_edge = coin5_stable & ~coin5_prev;   // Rising edge = insert ₹5
    assign coin10_edge = coin10_stable & ~coin10_prev; // Rising edge = insert ₹10
    assign coin15_edge = coin15_stable & ~coin15_prev; // Rising edge = insert ₹15
    
    // ====================
    // STATE REGISTER
    // ====================
    always @(posedge clk) begin
        if (reset_sync2) begin
            state <= S0;
        end else begin
            state <= next_state;
        end
    end
    
    // ====================
    // NEXT STATE LOGIC (FSM transitions)
    // ====================
    always @(*) begin
        next_state = state; // Default: stay in current state
        
        case (state)
            S0: begin // 0 rupees
                if (coin5_edge)
                    next_state = S5;
                else if (coin10_edge)
                    next_state = S10;
                else if (coin15_edge)
                    next_state = S15; // Exact amount - dispense!
            end
            
            S5: begin // 5 rupees
                if (coin5_edge)
                    next_state = S10;
                else if (coin10_edge)
                    next_state = S15; // 5+10=15 - dispense!
                else if (coin15_edge)
                    next_state = S20;
            end
            
            S10: begin // 10 rupees
                if (coin5_edge)
                    next_state = S15; // 10+5=15 - dispense!
                else if (coin10_edge)
                    next_state = S20;
                else if (coin15_edge)
                    next_state = S25;
            end
            
            S15: begin // 15 rupees - DISPENSE!
                if (!displaying)
                    next_state = S0; // Return to initial state after dispensing
            end
            
            S20: begin // 20 rupees (overpayment)
                if (!displaying)
                    next_state = S0;
            end
            
            S25: begin // 25 rupees (overpayment)
                if (!displaying)
                    next_state = S0;
            end
            
            default: next_state = S0;
        endcase
    end
    
    // ====================
    // DISPLAY TIMER (keep newspaper LED on for 2 seconds)
    // ====================
    always @(posedge clk) begin
        if (reset_sync2) begin
            display_counter <= 0;
            displaying <= 0;
        end else begin
            // Check if we just reached a dispensing state
            if ((state == S15 || state == S20 || state == S25) && !displaying) begin
                displaying <= 1;
                display_counter <= 0;
            end else if (displaying) begin
                if (display_counter < DISPLAY_TIME) begin
                    display_counter <= display_counter + 1;
                end else begin
                    displaying <= 0;
                    display_counter <= 0;
                end
            end
        end
    end
    
    // ====================
    // OUTPUT LOGIC - Newspaper LED
    // ====================
    always @(posedge clk) begin
        if (reset_sync2) begin
            newspaper <= 0;
        end else begin
            // Light up when dispensing (states >= 15 rupees)
            newspaper <= displaying;
        end
    end
    
    // ====================
    // OUTPUT LOGIC - Amount Display LEDs
    // ====================
    always @(*) begin
        case (state)
            S0:  led_amount = 5'b00000;  // 0 rupees - all LEDs off
            S5:  led_amount = 5'b00001;  // 5 rupees - 1 LED
            S10: led_amount = 5'b00011;  // 10 rupees - 2 LEDs
            S15: led_amount = 5'b00111;  // 15 rupees - 3 LEDs
            S20: led_amount = 5'b01111;  // 20 rupees - 4 LEDs
            S25: led_amount = 5'b11111;  // 25 rupees - 5 LEDs
            default: led_amount = 5'b00000;
        endcase
    end
    
endmodule
