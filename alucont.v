module alucont(aluop1,aluop0,f3,f2,f1,f0,gout,isBgez);//Figure 4.12 
input aluop1,aluop0,f3,f2,f1,f0,isBgez; //isBgez added to differ from the bltz
output [3:0] gout;
reg [3:0] gout;
always @(aluop1 or aluop0 or f3 or f2 or f1 or f0)
begin
if(~(aluop1|aluop0))  gout=4'b0000;
if(aluop0)gout=4'b0001;
if(aluop1)//R-type
	begin
	if (~(f3|f2|f1|f0))gout=4'b0000; 	//function code=0000,ALU control=0000 (add)
	if (f1&~(f3))gout=4'b0001;		//function code=0x10,ALU control=0001 (sub)
	if (f1&f3)gout=4'b0010;			//function code=1x1x,ALU control=0010 (set on less than)
	if (f2&f0)gout=4'b0011;			//function code=x1x1,ALU control=0011 (or)
	if (f2&~(f0))gout=4'b0100;		//function code=x1x0,ALU control=0100 (and)
	
	if (~(f3|f2|f1)&f0)gout=4'b0101;	//function code=0001,ALU control=0101 (nor)
	$monitor("adad");
	end
if(~aluop1)
	begin
	if(f3&(~f2&~f1&~f0)) gout=4'b0000;			//opcode : 00 1000 ADDi
	if(f3&f2&(~f1)&(~f0)) gout=4'b0100;			//opcode : 00 1100 ANDi
	if(f3&f2&(~f1)&f0) gout=4'b0011;			//opcode: 00 1101 ORi
	if(~f3&f2&(~f1)&(~f0)) gout=4'b0110;			//opcode: 00 0100 BEQ
	if(~f3&f2&(~f1)&(f0)) gout=4'b0111;			//opcode: 00 0101 BNE
	if(~f3&(~f2)&(~f1)&(f0)&(isBgez)) gout=4'b1000;		//opcode: 00 0001 BGEZ
	if(~f3&(f2)&(f1)&(f0)) gout=4'b1001;			//opcode: 00 0111 BGTZ	
	if(~f3&(f2)&(f1)&(~f0)) gout=4'b1010;			//opcode: 00 0110 BLEZ
	if(~f3&(~f2)&(~f1)&(f0)&(~isBgez)) gout=4'b1011;	//opcode: 00 0001 BLTZ
	end

end
endmodule
