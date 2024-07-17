module SPI_Wrapper_tb();

/////////////////////////////////////////////////////////
///////////////////// Parameters ////////////////////////
/////////////////////////////////////////////////////////
parameter MEM_DEPTH=256;
parameter ADDER_SIZE=8;
parameter IDLE=3'b000;
parameter CHK_CMD=3'b001;
parameter WRITE=3'b010;
parameter READ_ADD=3'b011;
parameter READ_DATA=3'b100;

/////////////////////////////////////////////////////////
//////////////////// DUT Signals ////////////////////////
/////////////////////////////////////////////////////////
reg SS_n_tb;
reg MOSI_tb;
reg clk_tb;
reg rst_n_tb;
wire MISO_tb;
integer i;
reg [3:0] counter=0;

/////////////////////////////////////////////////////////
//////////////// Design Instaniation ////////////////////
/////////////////////////////////////////////////////////
SPI_Wrapper #(MEM_DEPTH,ADDER_SIZE) DUT(
.MOSI(MOSI_tb),
.MISO(MISO_tb),
.SS_n(SS_n_tb),
.clk(clk_tb),
.rst_n(rst_n_tb)
);

/////////////////////////////////////////////////////////
/////////////////// generate clock  /////////////////////
/////////////////////////////////////////////////////////
initial begin
clk_tb = 0;
forever #1 clk_tb =~ clk_tb;	
end

////////////////////////////////////////////////////////
////////////////// initial block /////////////////////// 
////////////////////////////////////////////////////////
initial begin
rst_n_tb=0;
SS_n_tb=1;
MOSI_tb=0;
repeat(5) @(negedge clk_tb);
rst_n_tb=1;
repeat(5) @(negedge clk_tb);

//WRITE (WRITE ADDRESS)
//write address (8'hFF) in ADDER_reg (internal signal in RAM)
SS_n_tb=0;
@(negedge clk_tb);
MOSI_tb=0;
repeat(3) @(negedge clk_tb);
MOSI_tb=1;
repeat(8) @(negedge clk_tb);
SS_n_tb=1;
repeat(2)@(negedge clk_tb);
if(DUT.SPI_RAM_Wrapper.Address_Temp==8'hFF)begin
	$display("Write Address Case is succeeded");
end
else begin
	$display("Write Address Case is failed");
end

//WRITE (WRITE DATA)
//write value (8'hFF) in RAM[ADDER_reg] where ADDER_reg=8'hFF
SS_n_tb=0;
@(negedge clk_tb);
MOSI_tb=0;
repeat(2) @(negedge clk_tb);
MOSI_tb=1;
repeat(9) @(negedge clk_tb);
SS_n_tb=1;
repeat(2) @(negedge clk_tb);
if(DUT.SPI_RAM_Wrapper.RAM[255]==8'hFF)begin
	$display("Write Data    Case is succeeded");
end
else begin
	$display("Write Data    Case is failed");
end


//READ (READ ADDRESS)
//ADDER_reg(internal signal in RAM) will hold the address that we read the value in this address in next stage
SS_n_tb=0;
@(negedge clk_tb);
MOSI_tb=1;
repeat(2) @(negedge clk_tb);
MOSI_tb=0;
@(negedge clk_tb);
MOSI_tb=1;
repeat(8) @(negedge clk_tb);
SS_n_tb=1;
repeat(2) @(negedge clk_tb);
if(DUT.SPI_RAM_Wrapper.Address_Temp==8'hFF)begin
	$display("Read Address  Case is succeeded");
end
else begin
	$display("Read Address  Case is failed");
end



//READ (READ DATA)
//Check din[9:8] equal 2'b11 to send the vlaue in Ram[ADDER_reg] to dout(parellal) then SPI Read it ( convet it to serial) 
SS_n_tb=0;
@(negedge clk_tb);
MOSI_tb=1;
repeat(3) @(negedge clk_tb);
MOSI_tb=1;
repeat(9) @(negedge clk_tb);
//dealy for convert data
#3
for(i=0; i<8; i=i+1)begin
	@(negedge clk_tb);
	if(MISO_tb==1'b1)begin
		counter=counter+1;
	end
end
if(counter==8)begin
	$display("Read Data     Case is succeeded");
end
else begin
	$display("Read Data     Case is failed");
end
SS_n_tb=1;
repeat(5) @(negedge clk_tb);

#100;
$stop;	
end

endmodule


