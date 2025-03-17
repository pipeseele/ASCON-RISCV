`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: hs
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


//module hs(

//    );
//endmodule
module Ascon_core (
input  wire         clk,
input  wire         rstn,
input  wire [127:0] key,       // 128 bit key
input  wire [127:0] nonce,     // 128 bit nonce
input  wire [127:0] Din,       // 128 bit data input port
input  wire         dinReq,    // Req for din
output reg          dinAck,    // Ack for din
input  wire         encrypt,    // 1 = encrypt, 0 = decrypt
input  wire         last_block,// true when din is last block of data
input  wire         sel_data,  // 0 = associated, 1 = text
output reg [ 127:0] Dout,      // 128 bit out data port
output reg          doReq,     // dout req
input  wire         doAck,     // dout ack
input  wire         start,     // 1 means start if idle
output reg          busy,      // when started becomes busy
output reg          finished   // active when operation finishes
);


reg [63:0]  S0, S1, S2, S3, S4;

reg [4:0] state, substate, nextstate;
reg [3:0] perms;
reg [5:0] count;

`define IDLE  5'b00000
`define IVS   5'b00001
`define PERM  5'b00010
`define WAIT  5'b00011

//
`define ARK   5'b00100
`define AKL   5'b00101
`define SUBST 5'b00110
`define DIFF  5'b00111
`define AKU   5'b01000
`define XOR1  5'b01001
`define TAG   5'b01010
`define WAITF 5'b01011

//
//            sbox[0] = in[0] ^ (in[4] & in[3]) ^ (in[2] & in[1] & in[0]);
//            sbox[1] = in[1] ^ (in[0] & in[4]) ^ (in[3] & in[2] & in[1]);
//            sbox[2] = in[2] ^ (in[1] & in[0]) ^ (in[4] & in[3] & in[2]);
//            sbox[3] = in[3] ^ (in[2] & in[1]) ^ (in[0] & in[4] & in[3]);
//            sbox[4] = in[4] ^ (in[3] & in[2]) ^ (in[1] & in[0] & in[4]);
//function Permutation (4:0 value - 4:0 value comes out);
wire [4:0] sub;
SubstBlock Permutor (
.inp ({S4[count], S3[count], S2[count], S1[count], S0[count]}),
.opt (sub)
);
//x0 = (((~(S0[count]^S4[count]))&S1[count])^(S4[count]^S3[count])) ^ ((S0[count]^S4[count])^(~S1[count]&(S1[count]^S2[count])))
//x1 = ((x0^x4)^(~x1&(x1^x2)))^(x1^(~(x1^x2))&x3)
//x2 = ~((x1^x2)^(~x3&(x3^x4)))
//x3 = (x3^(~(x3^x4)&(x0^x4)))^((x1^x2)^(~x3&(x3^x4)))
//x4 = (x3^x4)^((~x0^x4)&x1)

//assign x={S4[count],S3[count],S2[count],S1[count],S0[count]};
//x1= x0^{x0[3],x0[1],x0[4]};
//x2=(~x1)&{x1[0],x1[4],x1[3],x1[2],x1[1]};
//x3=x2^{x2[0],x2[4:1]};
//x4=x3^{0,x3[2],1,x3[0],x3[4]};
//S4[count]<=x4[4];
//S3[count]<=x4[3];
always @(posedge clk or negedge rstn) begin

  if (!rstn) begin
    S0 <= 0;
    S1 <= 0;
    S2 <= 0;
    S3 <= 0;
    S4 <= 0;
    dinAck <= 0;
    doReq <= 0;
    state <= `IDLE;
  
  end else
  begin
    // clear output request when acknowledged  
    if (doReq&&doAck) doReq <= 0;
    finished <= 0;
    dinAck <= 0;
    
    if (state==`IDLE) begin
      S0 <= 0;
      S1 <= 0;
      S2 <= 0;
      S3 <= 0;
      S4 <= 0;
      busy <= 0;
      if (start) begin
        state <= `IVS;
        busy <= 1;
      end
    end else
    
    if (state==`IVS) begin
      S0 <= 64'h80800c0800000000;
      S1 <= key[127:64];
      S2 <= key[63:0];
      S3 <= nonce[127:64];
      S4 <= nonce[63:0];
      state <= `PERM;
      substate <= `ARK;
      nextstate <= `AKL;
      perms <= 0;
    end else
    
    if (state==`PERM) begin
      if (substate==`ARK) begin
        S2[7:0] <= S2[7:0] ^ {(~perms), perms};
        substate <= `SUBST;
        count <= 0;
      end else
      if (substate==`SUBST) begin
        S0[count] <= sub[0];
        S1[count] <= sub[1];
        S2[count] <= sub[2];
        S3[count] <= sub[3];
        S4[count] <= sub[4];
        if (count==63) substate <= `DIFF;
        else count <= count + 1;
      end else
      if (substate==`DIFF) begin
        S0 <= S0 ^ {S0[18:0], S0[63:19]} ^ {S0[27:0], S0[63:28]}; 
        S1 <= S1 ^ {S1[60:0], S1[63:61]} ^ {S1[38:0], S1[63:39]};
        S2 <= S2 ^ {S2[0]   , S2[63:01]} ^ {S2[05:0], S2[63:06]};
        S3 <= S3 ^ {S3[09:0], S3[63:10]} ^ {S3[16:0], S3[63:17]};
        S4 <= S4 ^ {S4[06:0], S4[63:07]} ^ {S4[40:0], S4[63:41]};
        if (perms == 11) state <= nextstate;
        else begin
          perms <= perms + 1;
          substate <= `ARK;
        end
      end
    end else
    
    if (state==`AKL) begin
      S3 <= S3 ^ key[ 127:64];
      S4 <= S4 ^ key[63:0];
      state <= `WAIT;
    end else

    if (state==`WAIT) begin
      if (dinReq&&(!doReq)) begin
        if (encrypt||(!sel_data)) begin  // 11 01 00
          S0 <= S0 ^ Din[127:64];
          S1 <= S1 ^ Din[63:0];
          dinAck <= 1;
        end
        if (sel_data) begin
          Dout[127:64] <= S0^ Din[127:64];
          Dout[63:0] <= S1 ^ Din[63:0];
          doReq <= 1;
          dinAck <= 1;
        end
        if ((!encrypt)&&sel_data) begin  // 01
          S0 <= Din[127:64];
          S1 <= Din[63:0];
          dinAck <= 1;
        end
        if (last_block&&sel_data) state <= `AKU; // ?
        else begin 
          state <= `PERM;
          perms <= 4;  // ?
          substate <= `ARK;
          if ((!sel_data)&&last_block) nextstate <= `XOR1; // 01
          else nextstate <= `WAIT;
        end
      end
    end else
    
    if (state==`XOR1) begin
      S4 <= S4 ^ 1;
      state <= `WAIT;
    end else
    
    if (state==`AKU) begin
      S3 <= S3 ^ key[127:64];
      S4 <= S4 ^ key[63:0];
      state <= `PERM;
      perms <= 0;
      substate <= `ARK;
      nextstate <= `TAG;
    end else
  
    if (state==`TAG) begin
      Dout <= {S3, S4} ^ key;
      doReq <= 1;
      state <= `WAITF;
    end else
    
    if (state==`WAITF) begin
      if ((!doReq)&&(!dinReq)) begin
        state <= `IDLE;
        busy <= 0;
        finished <= 1;
      end
    end
  end
end

endmodule
