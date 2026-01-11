// Newspaper vending machine FSM
// Takes 5, 10 and 15 rupee coin inputs and dispenses newspaper

module newspaper_vending_machine(
    input wire clk,             // 100 MHz clock
    input wire reset,           // reset button
    input wire coin5,            // 5 rupee coin
    input wire coin10,           // 10 rupee coin
    input wire coin15,           // 15 rupee coin
    output reg newspaper,        // newspaper LED
    output reg [4:0] led_amount  // amount display LEDs
);

    // States based on total amount
    parameter S0  = 3'b000;   // 0 rupees
    parameter S5  = 3'b001;   // 5 rupees
    parameter S10 = 3'b010;   // 10 rupees
    parameter S15 = 3'b011;   // 15 rupees
    parameter S20 = 3'b100;   // 20 rupees
    parameter S25 = 3'b101;   // 25 rupees
    
    reg [2:0] state, next_state;
    
    // debounce delay (~10ms)
    parameter DEBOUNCE_TIME = 1_000_000;
    reg [19:0] debounce_counter5, debounce_counter10, debounce_counter15;
    
    // sync registers for switches
    reg coin5_sync1, coin5_sync2;
    reg coin10_sync1, coin10_sync2;
    reg coin15_sync1, coin15_sync2;
    reg reset_sync1, reset_sync2;
    
    // edge detection
    reg coin5_prev, coin10_prev, coin15_prev;
    wire coin5_edge, coin10_edge, coin15_edge;
    
    // debounced values
    reg coin5_stable, coin10_stable, coin15_stable;
    reg coin5_last, coin10_last, coin15_last;
    
    // keep newspaper LED ON for some time
    parameter DISPLAY_TIME = 200_000_000; // ~2 seconds
    reg [27:0] display_counter;
    reg displaying;
    
    // synchronize inputs
    always @(posedge clk) begin
        coin5_sync1  <= coin5;
        coin5_sync2  <= coin5_sync1;
        coin10_sync1 <= coin10;
        coin10_sync2 <= coin10_sync1;
        coin15_sync1 <= coin15;
        coin15_sync2 <= coin15_sync1;
        reset_sync1  <= reset;
        reset_sync2  <= reset_sync1;
    end
    
    // debounce 5 rupee coin
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
    
    // debounce 10 rupee coin
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
    
    // debounce 15 rupee coin
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
    
    // detect rising edge of coin input
    always @(posedge clk) begin
        if (reset_sync2) begin
            coin5_prev  <= 0;
            coin10_prev <= 0;
            coin15_prev <= 0;
        end else begin
            coin5_prev  <= coin5_stable;
            coin10_prev <= coin10_stable;
            coin15_prev <= coin15_stable;
        end
    end
    
    assign coin5_edge  = coin5_stable  & ~coin5_prev;
    assign coin10_edge = coin10_stable & ~coin10_prev;
    assign coin15_edge = coin15_stable & ~coin15_prev;
    
    // state register
    always @(posedge clk) begin
        if (reset_sync2)
            state <= S0;
        else
            state <= next_state;
    end
    
    // next state logic
    always @(*) begin
        next_state = state;
        case (state)
            S0:  if (coin5_edge) next_state = S5;
                 else if (coin10_edge) next_state = S10;
                 else if (coin15_edge) next_state = S15;
            S5:  if (coin5_edge) next_state = S10;
                 else if (coin10_edge) next_state = S15;
                 else if (coin15_edge) next_state = S20;
            S10: if (coin5_edge) next_state = S15;
                 else if (coin10_edge) next_state = S20;
                 else if (coin15_edge) next_state = S25;
            S15, S20, S25:
                 if (!displaying) next_state = S0;
            default: next_state = S0;
        endcase
    end
    
    // display timer
    always @(posedge clk) begin
        if (reset_sync2) begin
            display_counter <= 0;
            displaying <= 0;
        end else begin
            if ((state == S15 || state == S20 || state == S25) && !displaying) begin
                displaying <= 1;
                display_counter <= 0;
            end else if (displaying) begin
                if (display_counter < DISPLAY_TIME)
                    display_counter <= display_counter + 1;
                else begin
                    displaying <= 0;
                    display_counter <= 0;
                end
            end
        end
    end
    
    // newspaper LED control
    always @(posedge clk) begin
        if (reset_sync2)
            newspaper <= 0;
        else
            newspaper <= displaying;
    end
    
    // amount display LEDs
    always @(*) begin
        case (state)
            S0:  led_amount = 5'b00000;
            S5:  led_amount = 5'b00001;
            S10: led_amount = 5'b00011;
            S15: led_amount = 5'b00111;
            S20: led_amount = 5'b01111;
            S25: led_amount = 5'b11111;
            default: led_amount = 5'b00000;
        endcase
    end

endmodule
