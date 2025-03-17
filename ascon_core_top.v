

// synopsys translate_off
//`include "timescale.v"
// synopsys translate_on
// `include "gpio_defines.v"

// any function-specific ports should be defined here

module hs_top(
	// WISHBONE Interface
	wb_clk_i, wb_rst_i, wb_cyc_i, wb_adr_i, wb_dat_i, wb_sel_i, wb_we_i, wb_stb_i,
	wb_dat_o, wb_ack_o, wb_err_o, wb_inta_o
);

parameter dw = 32;
parameter aw = 10;
//
// WISHBONE Interface
//
input             wb_clk_i;	// Clock
input             wb_rst_i;	// Reset
input             wb_cyc_i;	// cycle valid input
input   [aw-1:0]	wb_adr_i;	// address bus inputs
input   [dw-1:0]	wb_dat_i;	// input data bus
input	  [3:0]     wb_sel_i;	// byte select inputs
input             wb_we_i;	// indicates write transfer
input             wb_stb_i;	// strobe input
output  [dw-1:0]  wb_dat_o;	// output data bus
output            wb_ack_o;	// normal termination
output            wb_err_o;	// termination w/ error
output            wb_inta_o;	// Interrupt request output



//register addr define
parameter key_addr = 0;
parameter nonce_addr = 16;
parameter Din_addr = 32;
parameter encrypt_addr = 48;
parameter last_block_addr = 52;
parameter sel_data_addr = 56;
parameter Dout_addr = 60;
parameter start_addr = 76;
parameter busy_addr = 80;
parameter finished_addr = 84;
parameter dinReq_addr = 88;


// read and write enable
wire ce;
wire we;
wire re;
wire clk;
wire rst;

assign clk = wb_clk_i;
assign rst = wb_rst_i;
assign re = ce && ~wb_we_i;
assign we = wb_we_i && ce;
assign ce = wb_cyc_i && wb_stb_i;

assign wb_err_o = 1'b0;
assign wb_inta_o = 1'b0;


//output reg
reg wb_ack_r;
reg [31:0] wb_dat_o_r;

assign wb_ack_o = wb_ack_r;
assign wb_dat_o = wb_dat_o_r;


//register
reg [127:0] key;
reg [127:0] nonce;
reg [127:0] Din;

reg [31:0]  encrypt;
reg [31:0]  last_block;
reg [31:0]  sel_data;
reg [127:0] Dout;

reg [31:0]  start;
reg [31:0]  busy;
reg finished;



wire doReq;
wire doAck;
reg dinReq;
wire dinAck; 


wire encrypt_hs;
wire last_block_hs;
wire sel_data_hs;

wire [127:0] Dout_hs;

wire start_hs;
wire busy_hs;
wire finished_hs;


assign doAck = 1'b1;
assign encrypt_hs = encrypt[0];
assign last_block_hs = last_block[0];
assign sel_data_hs = sel_data[0];
assign start_hs = start[0];






always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        key<='b0;
    else if(wb_adr_i == key_addr && we)
        key[31:0]<=wb_dat_i;
    else if(wb_adr_i == (key_addr + 4) && we)
        key[63:32]<=wb_dat_i;
    else if(wb_adr_i == (key_addr + 8) && we)
        key[95:64]<=wb_dat_i;
    else if(wb_adr_i == (key_addr + 12) && we)
        key[127:96]<=wb_dat_i;
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        nonce<='b0;
    else if(wb_adr_i == nonce_addr && we)
        nonce[31:0]<=wb_dat_i;
    else if(wb_adr_i == (nonce_addr + 4) && we)
        nonce[63:32]<=wb_dat_i;
    else if(wb_adr_i == (nonce_addr + 8) && we)
        nonce[95:64]<=wb_dat_i;
    else if(wb_adr_i == (nonce_addr + 12) && we)
        nonce[127:96]<=wb_dat_i;
end


always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        Din<='b0;
    else if(wb_adr_i == Din_addr && we)
        Din[31:0]<=wb_dat_i;
    else if(wb_adr_i == (Din_addr + 4) && we)
        Din[63:32]<=wb_dat_i;
    else if(wb_adr_i == (Din_addr + 8) && we)
        Din[95:64]<=wb_dat_i;
    else if(wb_adr_i == (Din_addr + 12) && we)
        Din[127:96]<=wb_dat_i;
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        encrypt<='b0;
    else if(wb_adr_i == encrypt_addr && we)
        encrypt[31:0]<=wb_dat_i;
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        last_block<='b0;
    else if(wb_adr_i == last_block_addr && we)
        last_block[31:0]<=wb_dat_i;
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        sel_data<='b0;
    else if(wb_adr_i == sel_data_addr && we)
        sel_data[31:0]<=wb_dat_i;
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        Dout<='b0;
    else if(doReq)
        Dout<=Dout_hs;
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        start<='b0;
    else if(wb_adr_i == start_addr && we)
        start[31:0]<=wb_dat_i;
    else
        start <= 'b0;
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        busy<='b0;
    else
        busy[31:0]<={31'b0,busy_hs};
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        finished<='b0;
    else if(~finished)
        finished<=finished_hs;
    else if(wb_adr_i == finished_addr && re && wb_ack_r)
        finished<='b0;
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        dinReq<='b0;
    else if(wb_adr_i == dinReq_addr && we && ~dinReq && ~wb_ack_r)
        dinReq <= 1'b1;
    else if(dinAck)
        dinReq <= 1'b0;
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        wb_ack_r<='b0;
    else if(wb_ack_r)
        wb_ack_r<=1'b0;
    else if(ce && wb_adr_i!=dinReq_addr)
        wb_ack_r<=1'b1;
    else if(ce && wb_adr_i==dinReq_addr)begin
        if(dinReq && dinAck)
            wb_ack_r<=1'b1;
        else
            wb_ack_r<=1'b0;
    end
end

always@(posedge clk or  posedge rst)begin
    if(rst == 1'b1)
        wb_dat_o_r<='b0;
    else if(re)begin
        case(wb_adr_i[6:0])
            Dout_addr:wb_dat_o_r<=Dout[31:0];
            (Dout_addr+4):wb_dat_o_r<=Dout[63:32];
            (Dout_addr+8):wb_dat_o_r<=Dout[95:64];
            (Dout_addr+12):wb_dat_o_r<=Dout[127:96];
            busy_addr:wb_dat_o_r<=busy;
            finished_addr:wb_dat_o_r<={31'b0,finished};
            default:wb_dat_o_r<='b0;
        endcase
    end
end


Ascon_core u_ascon_core(
    .clk(clk),
    .rstn(~rst),
    .key(key),       // 128 bit key
    .nonce(nonce),     // 128 bit nonce
    .Din(Din),       // 128 bit data input port
    .dinReq(dinReq),    // Req for din
    .dinAck(dinAck),    // Ack for din
    .encrypt(encrypt_hs),    // 1 = encrypt, 0 = decrypt
    .last_block(last_block_hs),// true when din is last block of data
    .sel_data(sel_data_hs),  // 0 = associated, 1 = text
    .Dout(Dout_hs),      // 128 bit out data port
    .doReq(doReq),     // dout req
    .doAck(doAck),     // dout ack
    .start(start_hs),     // 1 means start if idle
    .busy(busy_hs),      // when started becomes busy
    .finished(finished_hs)   // active when operation finishes
);



endmodule

