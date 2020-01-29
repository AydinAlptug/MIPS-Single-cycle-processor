module processor;
reg [31:0] pc; //32-bit prograom counter
reg clk; //clock
reg [7:0] datmem[0:31],mem[0:31]; //32-size data and instruction memory (8 bit(1 byte) for each location)
wire [31:0] 
dataa,	//Read data 1 output of Register File
datab,	//Read data 2 output of Register File
out2,		//Output of mux with ALUSrc control-mult2
out3,		//Output of mux with MemToReg control-mult3
out4,		//Output of mux with (Branch&ALUZero) control-mult4
out5,		//Output of mux with Jump control-mult5
sum,		//ALU result
extad,		//Output of sign-extend unit
adder1out,	//Output of adder which adds PC and 4-add1
adder2out,	//Output of adder which adds PC+4 and 2 shifted sign-extend result-add2
sextad,		//Output of shift left 2 unit
jump_address,copy_out4,	//Jump address and mux input for mult5
inst25_0;	//this is used for jump operation


wire [5:0] inst31_26;	//31-26 bits of instruction
wire [4:0] 
inst25_21,	//25-21 bits of instruction
inst20_16,	//20-16 bits of instruction
inst15_11;	//15-11 bits of instruction
		//Write data input of Register File
wire [5:0] out1;

wire [15:0] inst15_0;	//15-0 bits of instruction
wire [31:0] instruc,	//current instruction
dpack;	//Read data output of memory (data read from memory)

wire [3:0] gout;	//Output of ALU control unit

wire zout,	//Zero output of ALU
pcsrc,	//Output of AND gate with Branch and ZeroOut inputs
//Control signals
alusrc,regwrite,memread,memwrite,branch,aluop1,aluop0;
wire [1:0] jump,regdest,memtoreg; //jump,regdest,memtoreg---->[1:0] 


//32-size register file (32 bit(1 word) for each register)
reg [31:0] registerfile[0:31];

integer i;

// datamemory connections

always @(posedge clk)
//write data to memory
if (memwrite)
begin 
//sum stores address,datab stores the value to be written
datmem[sum[4:0]+3]=datab[7:0];
datmem[sum[4:0]+2]=datab[15:8];
datmem[sum[4:0]+1]=datab[23:16];
datmem[sum[4:0]]=datab[31:24];
end

//instruction memory
//4-byte instruction
 assign instruc={mem[pc[4:0]],mem[pc[4:0]+1],mem[pc[4:0]+2],mem[pc[4:0]+3]};
 assign inst31_26=instruc[31:26];
 assign inst25_21=instruc[25:21];
 assign inst20_16=instruc[20:16];
 assign inst15_11=instruc[15:11];
 assign inst15_0=instruc[15:0];
 assign inst25_0[25:0] = instruc[25:0];	//for finding the jump address


// registers

assign dataa=registerfile[inst25_21];//Read register 1
assign datab=registerfile[inst20_16];//Read register 2
always @(posedge clk)
 registerfile[out1]= regwrite ? out3:registerfile[out1];//Write data to register

//read data from memory, sum stores address
assign dpack={datmem[sum[5:0]],datmem[sum[5:0]+1],datmem[sum[5:0]+2],datmem[sum[5:0]+3]};

//multiplexers
//mux with RegDst control
//mult2_to_1_5  mult1(out1, instruc[20:16],instruc[15:11],regdest);
wire [5:0]thirty_one;
assign thirty_one = 5'b11110;
custom_mult3_to_1_5 mult1(out1, instruc[20:16],instruc[15:11],thirty_one,regdest);

//mux with ALUSrc control
mult2_to_1_32 mult2(out2, datab,extad,alusrc);

//mux with MemToReg control
//mult2_to_1_32 mult3(out3, sum,dpack,memtoreg); //this is extended below.

wire [31:0] copy_adder1out;
assign copy_adder1out = adder1out;
custom_mult3_to_1_32 mult3(out3,sum,dpack,copy_adder1out,memtoreg);

//mux with (Branch&ALUZero) control
mult2_to_1_32 mult4(out4, adder1out,adder2out,pcsrc);


assign jump_address[31:26] = adder1out[31:26]; 
//mux with Jump control
//mult2_to_1_32 mult5(out5,copy_out4,jump_address,jump);

assign copy_out4=out4;
custom_mult3_to_1_32 mult5(out5,copy_out4,jump_address,dataa,jump);	//this is overwritten for jr operation
// load pc
always @(posedge clk)
pc=out5;

// alu, adder and control logic connections

//ALU unit
alu32 alu1(sum,dataa,out2,zout,gout);

//adder which adds PC and 4
adder add1(pc,32'h4,adder1out);

//adder which adds PC+4 and 2 shifted sign-extend result
adder add2(adder1out,sextad,adder2out);


//Control unit
control cont(instruc[31:26],regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,
aluop1,aluop0,jump,instruc[5:0]);

//Sign extend unit
signext sext(instruc[15:0],extad);


//choosing parameters for alucont
wire[3:0] temp;
reg check_I_or_R;
always @* begin//
if(instruc[31] |instruc[30] | instruc[29] | instruc[28] |instruc[27] | instruc[26])
check_I_or_R =1;
else
check_I_or_R=0;
end//
//mult2_to_1_5 mult_for_I_or_R_Type(temp,instruc[3:0],instruc[29:26],check_I_or_R); //For R types funct fields are used in alucont,
custom_mult2_to_1_4 mult_for_I_or_R_Type(temp,instruc[3:0],instruc[29:26],check_I_or_R); //for I types opcode fields are used in alucont


/*reg temp3,temp2,temp1,temp0; //without mux
always @*
	begin
	if(~(instruc[31] |instruc[30] | instruc[29] | instruc[28] |instruc[27] | instruc[26]))		//R
		begin
		assign temp3 = instruc[3];
		assign temp2 = instruc[2];
		assign temp1 = instruc[1];
		assign temp0 = instruc[0];
		end
	else if((instruc[31] |instruc[30] | instruc[29] | instruc[28] |instruc[27] | instruc[26]))	//I
		begin
		assign temp3 = instruc[29];
		assign temp2 = instruc[28];
		assign temp1 = instruc[27];
		assign temp0 = instruc[26];
		end
	end
alucont acont(aluop1,aluop0,temp3,temp2, temp1, temp0 ,gout,instruc[16]);
*/

alucont acont(aluop1,aluop0,temp[3],temp[2], temp[1], temp[0] ,gout,instruc[16]);


//ALU control unit
//alucont acont(aluop1,aluop0,instruc[3],instruc[2], instruc[1], instruc[0] ,gout);

//Shift-left 2 unit
shift shift2(sextad,extad);

//this operation is to shift inst25_0
shift shift3(jump_address,inst25_0);	

//AND gate
assign pcsrc=branch && zout; 

//initialize datamemory,instruction memory and registers
//read initial data from files given in hex
initial
begin
$readmemh("initDm.dat",datmem); //read Data Memory
$readmemh("initIM.dat",mem);//read Instruction Memory
$readmemh("initReg.dat",registerfile);//read Register File

	for(i=0; i<31; i=i+1)
	$display("Instruction Memory[%0d]= %h  ",i,mem[i],"Data Memory[%0d]= %h   ",i,datmem[i],
	"Register[%0d]= %h",i,registerfile[i]);
end

initial
begin
pc=0;
#400 $finish;
	
end
initial
begin
clk=0;
//40 time unit for each cycle
forever #20  clk=~clk;
end
initial 
begin
  $monitor($time,"PC %h",pc,"  SUM %h",sum,"   INST %h",instruc[31:0],
"   REGISTER %h %h %h %h ",registerfile[4],registerfile[5], registerfile[6],registerfile[1] );
end
endmodule

