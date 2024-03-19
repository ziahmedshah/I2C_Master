//a module that writes data into slave.
module master(clk, rst, address, data_write, data_read, sda, scl , wen, ren);
    input wire clk, rst;
    input wire wen; // Write enable
    input wire ren; // Read enable
    input wire [7:0] data_write;
    output reg [7:0] data_read;
    output reg sda;
    output reg scl;
    input wire [6:0] address;

    parameter IDLE=0, START=1, ADDR=2, RW=3, ACK_ADDR=4, //READ_DATA=5, 
    DATA=5, ACK_DATA=6, STOP=7;

    reg [2:0] state;
    reg [7:0] count;
    reg [6:0] address_out;
    //reg save_state;
    

    always @(posedge clk or posedge rst)
    begin
	
        if (rst) begin
            sda <= 1'b1;
            scl <= 1'b1;
            state <= IDLE;
        end
        else begin
            scl <= clk; // Synchronize scl with clk
            case (state)
                IDLE: begin
                    sda <= 1'b1;
                    state <= START;
                end
                START: begin
                    sda <= 1'b0;
                    count <= 7;
                    state <= ADDR;
                end
                ADDR: begin
		    
                    address_out <= address[count];
                    if (count == 0)
                        state <= RW;
                    else
                        count <= count - 1; // Non-blocking assignment
			sda<=count;
                end
                RW: begin 
                    //count <= 7;
                    /*if (ren) begin 
                        sda <= 1; // Read
                        state <= ACK_ADDR;
                        save_state <= READ_DATA;
                    end
                    else*/ if (wen) begin 
                        sda <= 0; // Write
                        state <= ACK_ADDR;
                        //save_state <= DATA;
                    end
                    else begin 
                        state <= STOP; 
                    end
                end
                ACK_ADDR: begin
                    if (!sda) 
                       state <= DATA;
                   else
                        state <= ACK_ADDR;
                end
                /*DATA: begin
                    count<=7;
                    data_read[count] <= sda;
                    if (count == 0)
                        state <= ACK_DATA;
                    else begin 
                        count <= count - 1; 
                        state <= READ_DATA; 
                    end
                end*/
                DATA: begin
                    count<=7;
                    sda <= data_write[count];
                    if (count == 0)
                        state <= ACK_DATA;
                    else begin
                        count <= count - 1; 
                        state <= DATA; 
                    end
                end
                ACK_DATA: begin
                    sda <= 0; // Acknowledgement
                    state <= STOP;
                end
                STOP: begin
                    sda <= 1;
                    scl <= 1;
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule

