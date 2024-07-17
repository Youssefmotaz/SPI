module SPI_Wrapper #(parameter MEM_DEPTH = 256,parameter ADDER_SIZE = 8) (
    input wire clk,rst_n,
    input wire MOSI,
    input wire SS_n,
    output wire MISO
);
    wire [9:0] rx_data;
    wire rx_valid;
    wire [7:0] tx_data;
    wire tx_valid;

    SPI_Slave SPI_Slave_Wrapper(
        .clk(clk),
        .rst_n(rst_n),
        .MOSI(MOSI),
        .SS_n(SS_n),
        .tx_data(tx_data),
        .tx_valid(tx_valid),
        .MISO(MISO),
        .rx_data(rx_data),
        .rx_valid(rx_valid)
    );

    SPI_RAM SPI_RAM_Wrapper(
        .clk(clk),
        .rst_n(rst_n),
        .din(rx_data),
        .rx_valid(rx_valid),
        .dout(tx_data),
        .tx_valid(tx_valid)
    );
endmodule