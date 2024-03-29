`timescale 1ns / 1ps

module i2c_master(clk, rst, sda, scl, rw, slave_address_ack, data_ack_slave, data_ack_master, 
address_slave, data_in, data_write, address_register);

input wire clk;
input wire rst;
inout wire sda;
output reg scl;

parameter idle=0, start=1, slave_address=2, ack_slave_address=3, slave_register_address=4, rw_state=5, 
write_data=6, read_data=7, ack_data_rcvd_by_slave=8, ack_data_by_master=9, stop=10;

input wire rw;               //sda=1 for write, sda=0 read
input wire slave_address_ack; //ack slave_address
input 	   data_ack_slave; //ack of data rcvd by slave
input	   data_ack_master; //ack of data rcvd by master

reg 	sda_temp;


reg 	   [10:0] state, state_nxt;
output reg [7:0] data_in; //data read
input wire [7:0] data_write;
input 	   [6:0] address_slave;
input 	   [6:0] address_register;
reg 	   [7:0] count;

assign scl = clk;


// Bidirectional SDA Line Handling
//wire sda_line;
//reg sda_drive; // Drive SDA when acting as a master transmitter
//assign sda = sda_drive ? sda_line : 1'bz;
//assign sda_line = sda;
//--------------------
assign sda = sda_temp;

always@(posedge clk) begin
	if (rst) 
	state_nxt <=idle;
	else	 
	state <=state_nxt;
	end

always@(posedge clk, posedge rst) begin
	if (rst) begin
    sda_temp<=1;
    state_nxt<=start; 
    end

    else begin
    case (state)
//state 0
//idle: begin
//sda_temp<=1;
//state_nxt<=start;
//end

//state 1
    start: begin
    sda_temp<=0;
    state_nxt<= slave_address;
    count<=6; 
    end //end state1

//state 2
//slave address
    slave_address: begin
    sda_temp<=address_slave[count];
    if (count==0) 
    state_nxt<= ack_slave_address;
    else begin 
    count<= count-1;
    state_nxt<= slave_address; 
    end
    end //end state2

//state 3
    ack_slave_address: begin
    if (sda_temp <= slave_address_ack) 
    begin
    state_nxt    <= slave_register_address ; 
    count<=6;
    end
    else begin
    state_nxt<=start;
    end   
    end  //end state3

//state 4
    slave_register_address: begin
    sda_temp<= address_register[count];
    if (count==0) 
    state_nxt<=rw_state;
    else 
    count <= count-1; 
    end //end state4

//state 5
    rw_state: begin
    sda_temp<=rw;
    if (rw) begin 
    state_nxt<=write_data; count<=7; 
    end ///ask a question here sda_temp not working properly why? but rw working
    else begin 
    state_nxt <=read_data; count<=7; 
    end
    end //end state5

//state 6
//master writing data into the slave
    write_data: begin
    sda_temp <= data_write[count];
    if (count==0) 
    state_nxt<= ack_data_rcvd_by_slave ;
    else begin 
    count <= count-1; 
    state_nxt<=write_data; 
    end
    end //end state6

//state7
    read_data: begin
    data_in [count] <= sda_temp;
    if (count==0) 
    state_nxt<= ack_data_by_master ;
    else begin 
    count<= count-1; 
    state_nxt <= read_data; 
    end
    end //end state7

//state 8
    ack_data_rcvd_by_slave: begin
    if ( data_ack_slave ) 
    begin 
    sda_temp <=1; state_nxt<=stop; 
    end
    else begin 
    sda_temp <=0; 
    state_nxt <=idle; 
    end 
    end //end state8

//state 9
    ack_data_by_master : begin
    if (data_ack_master) 
    begin 
    sda_temp<=1; state_nxt<=stop; 
    end
    else begin 
    sda_temp<=0; 
    state_nxt<=idle; 
    end
    end //end state9

//state 10
    stop: begin
    sda_temp<=1;
    state_nxt<=start;
    end //end stop
    endcase 
    end  
    end //end fsm
    endmodule
