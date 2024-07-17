module SPI_Slave (
    input wire clk,rst_n,
    input wire MOSI,
    input wire SS_n,
    input wire tx_valid,
    input wire [7:0] tx_data,
    output reg MISO,
    output reg rx_valid,
    output reg [9:0] rx_data
    );

    localparam IDLE = 3'b000;
    localparam CHK_CMD = 3'b001;
    localparam Read_Data = 3'b010;
    localparam Read_Address = 3'b011;
    localparam Write = 3'b100;

    reg [2:0] Current_State;
    reg [2:0] Next_State;
    reg [4:0] Count;
    reg [7:0] Shift_Reg;
    reg registered;
    reg Read_Data_State;

    always @(posedge clk or negedge rst_n)
        begin
            if(!rst_n)
            begin
            Current_State <= IDLE;
            end
            else
            begin
            Current_State <= Next_State;
            end
        end
    
    always @(*)
    begin
        case (Current_State)
            IDLE:
            begin
                registered = 'b0;
                if(SS_n)
                begin
                Next_State = IDLE;
                end
                else
                begin
                Next_State = CHK_CMD;
                end
            end 
            CHK_CMD:
            begin
                if(!SS_n && !MOSI )
                begin
                    Next_State = Write;
                end
                else if(!SS_n && MOSI && !Read_Data_State)
                begin
                    Next_State = Read_Address ;
                end
                else if(!SS_n && MOSI && Read_Data_State)
                begin
                    Next_State = Read_Data;
                end
                else
                begin
                    Next_State = IDLE;
                end
            end
            Write:
            begin
                if(SS_n)
                begin
                    Next_State = IDLE;
                end
                else
                begin
                    Next_State = Write;
                end
            end
            Read_Address:
            begin
                if(SS_n)
                begin
                    Next_State = IDLE;
                end
                else
                begin
                    Next_State = Read_Address;
                end
                if (Count == 'd10) begin
                    Read_Data_State = 'b1;
                end
                else begin
                    Read_Data_State = 'b0;
                end
            end
            Read_Data:
            begin
                if(SS_n)
                begin
                    Next_State = IDLE;
                end
                else
                begin
                    Next_State = Read_Data;
                end
                if(Count == 'd20) begin
                  Read_Data_State = 'b0;
                end
                else begin
                  Read_Data_State = 'b1;
                end
            end
            default:
            begin
                Next_State = IDLE;
            end
        endcase
    end

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            rx_data <= 'b0;
            rx_valid <= 'b0;
            MISO <= 'b0;
            Read_Data_State <= 'b0;
            registered <= 'b0;
        end
        if(Count < 'd10&& Current_State != CHK_CMD)
        begin
            rx_data <= {rx_data[8:0],MOSI};
        end
        else if(tx_valid && !registered)
        begin
            Shift_Reg <= tx_data;
            registered <= 'b1;
        end
        else if(tx_valid && registered)
        begin
            {Shift_Reg[6:0],MISO} <= Shift_Reg;
        end
    end

    always @(posedge clk or negedge rst_n)
    begin
        if(!rst_n || SS_n)
        begin
            Count <= 4'b0;
        end
        else if(Current_State != CHK_CMD && Current_State != IDLE )
        begin
            Count <= Count + 'b1;
        end
    end

    always @(*)
    begin
        if(Count == 'd10)
        begin
            rx_valid = 'b1;
        end
        else
        begin
            rx_valid = 'b0;
        end
    end

endmodule