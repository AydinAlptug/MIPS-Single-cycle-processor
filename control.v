module control(in,regdest,alusrc,memtoreg,regwrite,memread,memwrite,branch,aluop1,aluop2,jump,funct);
input [5:0] in,funct;
output reg alusrc,regwrite,memread,memwrite,branch,aluop1,aluop2;//jump signal added for jump operations
output reg [1:0] jump,regdest,memtoreg; 	//turned to two bits for JR and JAL
reg rformat,lw,sw,beq;

//additionally jump and funt passed for j,jal and jr operations

always @(in) begin
	aluop2 =1;
	aluop1=0;
	 case (in)

	  	6'b000000:	//R-TYPE
	 	begin
		 if((~funct[4])&(~funct[4])&(funct[3])&(~funct[2])&(~funct[1])&(~funct[0]))  //JR
			begin
			 jump = 2'b10;
			 memwrite = 1'b0;  
		 	 regwrite = 1'b0;  
		 	 end
		 else   begin
			rformat=~|in;
		 	lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
		 	sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
		 	beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
			regdest=rformat;
		 	alusrc=lw|sw;
		 	memtoreg=lw;
			regwrite=rformat|lw;
		 	memread=lw;
		 	memwrite=sw;
		 	branch=beq;
		 	aluop1=rformat;
		 	aluop2=beq; 
		 	jump = 2'b00;  
			end
		end

		6'b000010:	//J
		begin
			regdest = 2'b00;  
			memtoreg = 2'b00;    
			jump = 2'b01;  
			branch = 1'b0;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b0;  
			regwrite = 1'b0;
			aluop1= 1'b0;
			aluop2=1'b0;  
		end
		6'b000011:	//JAL
		begin
			regdest = 2'b10;  
			memtoreg = 2'b10;    
			jump = 2'b01;    
			memwrite = 1'b0;    
			regwrite = 1'b1;
			aluop1= 1'b0;
			aluop2=1'b0; 

		end
		6'b101011:	//SW
		begin
			regdest = 2'b00;  
			memtoreg = 2'b00;   
			jump = 2'b00;  
			branch = 1'b0;  
			memread = 1'b0;  
			memwrite = 1'b1;  
			alusrc = 1'b1;  
			regwrite = 1'b0;
			aluop1= 1'b0;
			aluop2=1'b0; 
		end

		6'b100011:	//LW
		begin 
			regdest = 2'b00;  
			memtoreg = 2'b01;  
			jump = 2'b00;  
			branch = 1'b0;  
			memread = 1'b1;  
			memwrite = 1'b0;  
			alusrc = 1'b1;  
			regwrite = 1'b1;
			aluop1= 1'b0;
			aluop2=1'b0; 
		end

		 6'b001000:	//ADDI
		begin 
			regdest = 2'b00;  
			memtoreg = 2'b00;    
			jump = 2'b00;  
			branch = 1'b0;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b1;  
			regwrite = 1'b1;
			aluop1=1'b0;
			aluop2=1'b0;
		end

		6'b001100:	//ANDI
		begin
			regdest = 2'b00;  
			memtoreg = 2'b00;    
			jump = 2'b00;  
			branch = 1'b0;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b1;  
			regwrite = 1'b1;
			aluop1=1'b0;
			aluop2=1'b1;
		end

	  6'b001101:	//ORI
		begin 
			regdest = 2'b00;  
			memtoreg = 2'b00;   
			jump = 2'b00;  
			branch = 1'b0;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b1;  
			regwrite = 1'b1;
			aluop1= 1'b0;
			aluop2=1'b0;
		end

		6'b000100:	//BEQ
		begin 
			regdest = 2'b00;  
			memtoreg = 2'b00;    
			jump = 2'b00;  
			branch = 1'b1;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b0;  
			regwrite = 1'b0;  
			aluop1= 1'b0;
			aluop2=1'b0;
		end

		6'b000101:	//BNE
		begin
			regdest = 2'b00;  
			memtoreg = 2'b00;   
			jump = 2'b00;  
			branch = 1'b1;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b0;  
			regwrite = 1'b0;  
			aluop1= 1'b0;
			aluop2=1'b0; 
		end
		6'b000001:	//BGEZ
		begin
			regdest = 2'b00;  
			memtoreg = 2'b00;   
			jump = 2'b00;  
			branch = 1'b1;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b0;  
			regwrite = 1'b0;  
			aluop1= 1'b0;
			aluop2=1'b0;
		end
		6'b000111:	//BGTZ
		begin
			regdest = 2'b00;  
			memtoreg = 2'b00;   
			jump = 2'b00;  
			branch = 1'b1;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b0;  
			regwrite = 1'b0;  
			aluop1= 1'b0;
			aluop2=1'b0;
		end
		6'b000110:	//BLEZ
		begin
			regdest = 2'b00;  
			memtoreg = 2'b00;    
			jump = 2'b00;  
			branch = 1'b1;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b0;  
			regwrite = 1'b0;  
			aluop1= 1'b0;
			aluop2=1'b0;
		end
		6'b000001:	//BLTZ
		begin
			regdest = 2'b00;  
			memtoreg = 2'b00;    
			jump = 2'b00;  
			branch = 1'b1;  
			memread = 1'b0;  
			memwrite = 1'b0;  
			alusrc = 1'b0;  
			regwrite = 1'b0;  
			aluop1= 1'b0;
			aluop2=1'b0;
		end
		default:
		begin
		 rformat=~|in;
		 lw=in[5]& (~in[4])&(~in[3])&(~in[2])&in[1]&in[0];
		 sw=in[5]& (~in[4])&in[3]&(~in[2])&in[1]&in[0];
		 beq=~in[5]& (~in[4])&(~in[3])&in[2]&(~in[1])&(~in[0]);
		 regdest=rformat;
		 alusrc=lw|sw;
		 memtoreg=lw;
		 regwrite=rformat|lw;
		 memread=lw;
		 memwrite=sw;
		 branch=beq;
		 aluop1=rformat;
		 aluop2=beq; 
		 jump = 2'b00;
		end
	 endcase
end

endmodule
