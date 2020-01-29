module alu32(sum,a,b,zout,gin);//ALU operation according to the ALU control line values
output [31:0] sum;
input [31:0] a,b; 
input [3:0] gin;//ALU control line
reg [31:0] sum;
reg [31:0] less;
output zout;
reg zout;
always @(a or b or gin)
begin
	case(gin)
	4'b0000: sum=a+b; 		//ALU control line=010, ADD
	4'b0001: sum=a+1+(~b);	//ALU control line=110, SUB
	4'b0010: begin less=a+1+(~b);	//ALU control line=111, set on less than
			if (less[31]) sum=1;	
			else sum=0;
		 end
	4'b0011: sum=a|b;		//ALU control line=001, OR
	4'b0100: sum=a & b;	//ALU control line=000, AND
	4'b0101: sum=~(a|b);	//ALU control line=101 NOR için
	
	4'b0110: begin sum=a+1+(~b); //BEQ
			if(~sum) sum=0;
			else sum = 1;
		 end
	4'b0111: begin if(a==b) sum = 1;	//BNE zout:1
			else sum = 0;
		 end
	4'b1000: begin	if((~a[31])|(a[31:0]==32'b0)) sum=0;	//BGEZ
		 	else sum=1;
		 end
	4'b1001: begin	if(~a[31] & ~(a[31:0]==32'b0)) sum=0;	//BGTZ
			else sum=1;
		 end
	4'b1010: begin  if((a[31])|((a[31:0]==32'b0))) sum=0;	//BLEZ
			else sum =1;
		 end
	4'b1011: begin  if(a[31]) sum=0;	//BLTZ
			else sum=1;
		 end
	default: sum=31'bx;
	endcase
zout=~(|sum);
end
endmodule
