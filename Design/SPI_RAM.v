module SPI_RAM #(parameter MEM_DEPTH = 256,parameter ADDR_SIZE = 8 ) (
    input wire [9:0] din,
    input wire clk,rst_n,
    input wire rx_valid,
    output reg [7:0] dout,
    output reg tx_valid
);
    reg [ADDR_SIZE-1:0] Address_Temp;
    reg [ADDR_SIZE-1:0] RAM [0:MEM_DEPTH-1];
    reg [3:0] Count_RAM;
    integer i;

    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            Address_Temp <= 'b0;
            for(i=0;i<MEM_DEPTH;i=i+1)
            begin
                RAM[i] <= 'b0;
            end
            tx_valid <= 'b0;
            dout <= 'b0;
        end
        else if(rx_valid)
        begin
        case (din[9:8])
            'b00:
            begin
                Address_Temp <= din[ADDR_SIZE-1:0];
            end
            'b01:
            begin
                RAM[Address_Temp] <= din[ADDR_SIZE-1:0];
            end
            'b10:
            begin
                Address_Temp <= din[ADDR_SIZE-1:0];
            end
            'b11:
            begin
                dout <= RAM[Address_Temp];
                tx_valid <= 'b1;
            end  
        endcase
        end
    end

 /*   always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            Count_RAM <= 4'b0;
        end
        else if(din[9:8] == 'b11)
        begin
            Count_RAM <= Count_RAM + 'b1;
        end
    end

  always @(*)
    begin
        if(Count_RAM == 'd10)
        begin
            tx_valid = 'b0;
        end
        else
        begin
            tx_valid = 'b1;
        end
    end
*/
endmodule

