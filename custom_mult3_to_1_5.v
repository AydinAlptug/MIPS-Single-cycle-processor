module custom_mult3_to_1_5(out, i0,i1,i2,s0);
output [5:0] out;
input [4:0]i0,i1,i2;
input [1:0] s0;
//00 or 01 or 10
assign out[4:0] =  s0[1] ? i2: (s0[0] ? i1 : i0);

endmodule