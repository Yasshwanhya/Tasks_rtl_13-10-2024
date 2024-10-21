`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.10.2024
// Design Name: 
// Module Name: axi_MAC
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: FSM-based Multiply-Accumulate (MAC) using localparam for states
// 
//////////////////////////////////////////////////////////////////////////////////

module axi_MAC #( 
    parameter int_a=6,
    parameter frac_a=8,
    parameter int_b=6,
    parameter frac_b=8,
    
)(
    input clock,
    input rstn,
    
    // Input signals
    input signed [int_a+frac_a-1:0] a,
    input signed [int_b+frac_b-1:0] b,
    input valid_i,
    input ready_i,
    input last_i,
    
    // Output signals
    output reg signed [out_int+out_frac-1:0] product_out,
    output reg ready_o,
    output reg valid_o,
    output reg last_o,

    output overflow,
    output underflow
);
    localparam out_int = (int_a>=int_b)?(2*int_a):(2*int_b);   
    localparam out_frac = (frac_a>=frac_b)?(2*frac_a):(2*frac_b);

    // State Definitions (using localparam)
    localparam [1:0] RESET = 2'b00, MAC = 2'b01, OUTPUT = 2'b10;
    
    // Intermediate registers and state
    reg signed [out_int+out_frac-1:0] store_ab, acc;
    reg valid, last, ready;
    reg [1:0] state, next_state;  // Current state and next state

    wire signed [out_int+out_frac-1:0] product, pdt, accc;

    // Multiplier and Adder instantiation
    fp_mul #(int_a, frac_a, int_b, frac_b, out_int, out_frac) mult (
        .clock(clock),
        .rstn(rstn),
        .a(a),
        .b(b),
        .product(product)
    );
    
    fp_add #(int_a, frac_a, int_b, frac_b, out_int, out_frac) addt (
        .clock(clock),
        .rstn(rstn),
        .a(pdt),
        .b(accc),
        .out(product),
        .overflow(overflow),
        .underflow(underflow)
    );

    // FSM State Transitions
    always @(posedge clock or negedge rstn) begin
        if (!rstn) begin
            state <= RESET;  // Reset the state machine to RESET state
        end else begin
            state <= next_state;  // Move to the next state
        end
    end

    // FSM Next State Logic
    always @(*) begin
        case (state)
            RESET: begin
                if (valid_i && ready_i) begin
                    next_state = MAC;  // Move to MAC state when valid_i and ready_i are high
                end else begin
                    next_state = RESET;  // Stay in RESET state if no valid inputs
                end
            end
            
            MAC: begin
                if (valid_i && ready_i && last_i) begin
                    next_state = OUTPUT;  // Move to OUTPUT state if last_i is asserted
                end else begin
                    next_state = MAC;  // Stay in MAC state
                end
            end
            
            OUTPUT: begin
                next_state = RESET;  // After output, go back to RESET
            end
            
            default: next_state = RESET;  // Default case
        endcase
    end

    // FSM Output Logic and State Management
    always @(posedge clock or negedge rstn) begin
        if (!rstn) begin
            // Reset the output signals and internal registers
            acc <= 0;
            store_ab <= 0;
            product_out <= 0;
            valid_o <= 1'b0;
            ready_o <= 1'b0;
            last_o <= 1'b0;
        end else begin
            case (state)
                RESET: begin
                    // Reset accumulations and intermediate signals
                    acc <= 0;
                    store_ab <= 0;
                    valid_o <= 1'b0;
                    ready_o <= 1'b0;
                    last_o <= 1'b0;
                end
                
                MAC: begin
                    if (valid_i && ready_i) begin
                        store_ab <= pdt;  // Perform multiplication
                        acc <= accc;       // Accumulate the result
                        valid_o <= 1'b0;
                        ready_o <= 1'b0;
                        last_o <= 1'b0;
                    end
                end
                
                OUTPUT: begin
                    if (valid_i && ready_i && last_i) begin
                        product_out <= acc;  // Output the accumulated value
                        valid_o <= valid;    // Assert valid signal
                        ready_o <= ready;    // Assert ready signal
                        last_o <= last;      // Assert last signal
                    end
                end
            endcase
        end
    end

endmodule
