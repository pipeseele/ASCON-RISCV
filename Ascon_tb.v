`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/08/13 11:37:52
// Design Name: 
// Module Name: Ascon_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


//module Ascon_tb(

//    );
//endmodule

//reg clk;
//reg Din;
//reg key;
//reg nonce;
//wire Dout;

//Ascon_core uut (

//)


module Ascon_core_tb;
// Inputs
reg clk;
reg rstn;
reg [127:0] key;
reg [127:0] nonce;
reg [127:0] Din, LastData, read_data;
reg dinReq;
reg encrypt;
reg last_block;
reg sel_data;
wire doAck;
reg start;
reg [3:0] state;

// Outputs
wire dinAck;
wire [127:0] Dout;
wire doReq;
wire busy;
wire finished;

Ascon_core uut (
    .clk(clk),
    .rstn(rstn),
    .key(key),
    .nonce(nonce),
    .Din(Din),
    .dinReq(dinReq),
    .dinAck(dinAck),
    .encrypt(encrypt),
    .last_block(last_block),
    .sel_data(sel_data),
    .Dout(Dout),
    .doReq(doReq),
    .doAck(doAck),
    .start(start),
    .busy(busy),
    .finished(finished)
);


always #5 clk = ~clk;

initial begin
    clk = 0;
    rstn = 0;
#100 rstn  = 1;
end

//    #10;
//    rstn = 1;

//    //encryption
//    #10;
//    start = 1;
//    #10;
//    start = 0;

//    wait(busy == 1);
//    #10;


//    dinReq = 1;
//    #10;
//    dinReq = 0;


//    wait(doReq == 1);    
//    #10;
    
//    // Ack output data
//    doAck = 1;
//    #10;
//    doAck = 0;

 
//    wait(finished == 1);   
//    #10;

//    $stop;
//end


always @(posedge clk or negedge rstn)
begin
  if (!rstn) begin
    key <= 128'h000102030405060708090a0b0c0d0e0f;
    nonce = 128'h000102030405060708090a0b0c0d0e0f;
    Din <= nonce;
    LastData <= 0;
    LastData[127] <= 1'b1;
    dinReq <= 0;
    encrypt <= 1; // 1 en,0 de
    last_block <= 0;
    sel_data <= 0; // 1 text, 0 AD
    start <= 0;
    state <= 0;
  end else
  begin
    start <= 0;
    if (state==0) begin     //state=`IVS busy=1
      start  <= 1;
      state <= 1;
    end else
    if (state==1) begin
      dinReq <= 1;
      state <= 2;
    end else
    if (state==2) begin
      if (dinAck) begin
        dinReq <= 0;
        state <= 3;
      end
    end else
    if (state==3) begin
       dinReq <= 1;
       Din <= LastData;
       last_block <= 1;
       state <= 4;
    end else
    if (state==4) begin
      if (dinAck) begin
        dinReq <= 0;
        state <= 5;
      end
    end else
    if (state==5) begin
      dinReq <= 1;
      Din <= nonce;
      sel_data <= 1;
      last_block <= 0;
      state <= 6;
    end else
    if (state==6) begin
      if (dinAck) begin
        dinReq <= 0;
        state <= 7;
      end
    end else
    if (state==7) begin
      dinReq <= 1;
      Din <= LastData;
      sel_data <= 1;
      last_block <= 1;
      state <= 8;
    end else
    if (state==8) begin
      if (dinAck) begin
        dinReq <= 0;
        state <= 9;
      end
    end else
    if (state==9) begin
      if (finished) state <= 0;
    end
  end
end

assign doAck = doReq;

always @(posedge clk or negedge rstn)
begin
  if (!rstn) begin
    read_data <= 0;
  end else
  if (doReq) begin
    read_data <= Dout;
  end
end


endmodule
