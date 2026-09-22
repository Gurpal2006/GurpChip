module counter (
    input  wire       clk,
    input  wire       rst_n,
    input  wire       load,
    input  wire       output_enable,
    input  wire [7:0] data_in,

    output wire [7:0] count_out
);

    // Internal 8-bit counter register
    reg [7:0] count;


    // ---------------------------------------------------
    // Counter logic
    //
    // rst_n = 0  -> reset immediately
    // load = 1   -> load data_in on next rising clock edge
    // otherwise  -> count upward
    // ---------------------------------------------------

    always @(posedge clk or negedge rst_n) begin

        if (!rst_n)
            count <= 8'h00;

        else if (load)
            count <= data_in;

        else
            count <= count + 8'd1;

    end


    // ---------------------------------------------------
    // Tri-state output
    //
    // output_enable = 1 -> output counter value
    // output_enable = 0 -> high impedance (Z)
    // ---------------------------------------------------

    assign count_out = output_enable
                     ? count
                     : 8'bzzzzzzzz;


endmodule