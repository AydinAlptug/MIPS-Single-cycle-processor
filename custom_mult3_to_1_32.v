module custom_mult3_to_1_32(out, i0,i1,i2,s0);
output [31:0] out;
input [31:0]i0,i1,i2;
input [1:0] s0;
//00 or 01 or 10
assign out =  s0[1] ? i2: (s0[0] ? i1 : i0);

endmodule
