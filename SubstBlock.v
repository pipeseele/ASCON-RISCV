`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 
// Design Name: 
// Module Name: SubstBlock
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


//module SubstBlock(
//input wire [4:0] inp,
//output reg [4:0] opt
//    );
////assign opt[0] = (((~(inp[0]^inp[4]))&inp[1])^(inp[4]^inp[3])) ^ ((inp[0]^inp[4])^(~inp[1]&(inp[1]^inp[2])));
////assign opt[1] = ((inp[0]^inp[4])^(~inp[1]&(inp[1]^inp[2])))^(inp[1]^(~(inp[1]^inp[2]))&inp[3]);
////assign opt[2] = ~((inp[1]^inp[2])^(~inp[3]&(inp[3]^inp[4])));
////assign opt[3] = (inp[3]^(~(inp[3]^inp[4])&(inp[0]^inp[4])))^((inp[1]^inp[2])^(~inp[3]&(inp[3]^inp[4])));
////assign opt[4] = (inp[3]^inp[4])^((~inp[0]^inp[4])&inp[1]);


////    always @(*) begin // to be unblock
////    opt[0] = (((~(inp[0]^inp[4]))&inp[1])^(inp[4]^inp[3])) ^ ((inp[0]^inp[4])^(~inp[1]&(inp[1]^inp[2])));
////    opt[1] = ((inp[0]^inp[4])^(~inp[1]&(inp[1]^inp[2])))^(inp[1]^(~(inp[1]^inp[2]))&inp[3]);
////    opt[2] = ~((inp[1]^inp[2])^(~inp[3]&(inp[3]^inp[4])));
////    opt[3] = (inp[3]^(~(inp[3]^inp[4])&(inp[0]^inp[4])))^((inp[1]^inp[2])^(~inp[3]&(inp[3]^inp[4])));
////    opt[4] = (inp[3]^inp[4])^((~inp[0]^inp[4])&inp[1]);
////end



    
//reg x0, x0_1, x0_2, x0_out;
//reg x1, x1_1, x1_out;
//reg x2, x2_1, x2_2, x2_out;
//reg x3, x3_1, x3_out;     
//reg x4, x4_1, x4_2, x4_out;

//assign inp = {x4,x3,x2,x1,x0};

//x0_1 = x0^x4;
//x2_1 = x1^x2;
//x4_1 = x3^x4;

//x0_2 = x0_1^(~x1&x2_1);
//x1_1 = x1^(~x2_1&x3);
//x2_2 = x2_1^(~x3&x4_1);
//x3_1 = (~(x4_1&x0_1))^x3;
//x4_2 = x4_1^(~x0_1&x1);

//x0_out = x0_2^x4_2;
//x1_out = x1_1 ^ x0_2;
//x2_out = x2_2^1;
//x3_out = x2_2^x3_1
//x4_out = x4_2;
module SubstBlock(
    input  wire [4:0] inp,   
    output wire [4:0] opt    
);

//    reg x0, x0_1, x0_2, x0_out;
//    reg x1, x1_1, x1_out;
//    reg x2, x2_1, x2_2, x2_out;
//    reg x3, x3_1, x3_out;
//    reg x4, x4_1, x4_2, x4_out;
wire [4:0] x1, x2, x3;

assign x1 = inp ^ {inp[3], 1'b0, inp[1], 1'b0, inp[4]};
assign x2 = (~x1)&{x1[0], x1[4:1]};
assign x3 = x1 ^ {x2[0], x2[4:1]};
assign opt = x3 ^ {1'b0, x3[2], 1'b1, x3[0], x3[4]};

//    always @(*) begin
//        x4 = inp[4]; //assign inputs
//        x3 = inp[3];
//        x2 = inp[2];
//        x1 = inp[1];
//        x0 = inp[0];

//        x0_1 = x0 ^ x4;
//        x2_1 = x1 ^ x2;
//        x4_1 = x3 ^ x4;

//        x0_2 = x0_1 ^ (~x1 & x2_1);
//        x1_1 = x1 ^ (~x2_1 & x3);
//        x2_2 = x2_1 ^ (~x3 & x4_1);
//        x3_1 = (~(x4_1 & x0_1)) ^ x3;
//        x4_2 = x4_1 ^ (~x0_1 & x1);


//        x0_out = x0_2 ^ x4_2; //assign outputs
//        x1_out = x1_1 ^ x0_2;
//        x2_out = x2_2 ^ 1'b1; 
//        x3_out = x2_2 ^ x3_1;
//        x4_out = x4_2;
//    end


//    assign opt = {x4_out, x3_out, x2_out, x1_out, x0_out};

endmodule



    
    
    
    
    
    
    
    
    
    

