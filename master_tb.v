module master_tb;
  reg clk = 0; // Clock signal
  reg rst = 1; // Reset signal
  reg wen = 0; // Write enable signal
  reg ren = 0; // Read enable signal
  reg [7:0] data_write ; // Data to be written
  wire [7:0] data_read; // Data read from the module
  wire sda; // I2C data line
  wire scl; // I2C clock line
  reg [6:0] address; // Address

  // Instantiate the I2C master module
  master dut (
    .clk(clk),
    .rst(rst),
    .wen(wen),
    .ren(ren),
    .address(address),
    .data_write(data_write),
    .data_read(data_read),
    .sda(sda),
    .scl(scl)
  );

  // Clock generation
  always #5 clk = ~clk;

  // Reset generation
  initial begin
    #10; 
    rst = 0; 
  end
  // Stimulus
  initial begin  
    
    data_write = 8'b1000_0111; // Write data
    address = 7'b0000_010; // Address
    wen = 1; // Enable write
    ren = 0;

    #1000;
    $finish;
  end
endmodule

