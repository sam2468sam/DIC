`timescale 1ns/10ps
module CS(Y, X, reset, clk);

input clk, reset; 
input 	[7:0] X;
output 	[9:0] Y;

//--------------------------------------
//  \^o^/   Write your code here~  \^o^/
//--------------------------------------

reg [7:0] x0,x1,x2,x3,x4,x5,x6,x7,x8,D,Appr;
reg [9:0] Y;
reg [14:0] Sum,T,Avg;
reg [3:0] counter,i;

always @(posedge clk)
begin
	if(reset)
	begin
		counter=0;
		i=0;
		x0=0;
		x1=0;
                x2=0;
                x3=0;
                x4=0;
                x5=0;
                x6=0;
                x7=0;
                x8=0;
	/*	Sum=0;
		Avg=0;*/
	end
	else
	begin
		case(i)
			0:x0=X;
			1:x1=X;
                        2:x2=X;
                        3:x3=X;
                        4:x4=X;
                        5:x5=X;
                        6:x6=X;
                        7:x7=X;
                        default:x8=X;
		endcase
		if(i<8)
			i=i+1;
		else
			i=0;
		if(counter<8)
			counter=counter+1;
		else
		begin
			Sum=Sum+x0;
			Sum=Sum+x1;
			Sum=Sum+x2;
                        Sum=Sum+x3;
                        Sum=Sum+x4;
                        Sum=Sum+x5;
                        Sum=Sum+x6;
                        Sum=Sum+x7;
                        Sum=Sum+x8;
			Avg=Sum/9;
			D=255;
			if(Avg-x0<D)
			begin
				D=Avg-x0;
				Appr=x0;
			end
			else
				D=D;
                        if(Avg-x1<D)
                        begin
                                D=Avg-x1;
                                Appr=x1;
                        end
			else
                                D=D;
			if(Avg-x2<D)
                        begin
                                D=Avg-x2;
                                Appr=x2;
                        end
                        else
                                D=D;
                        if(Avg-x3<D)
                        begin
                                D=Avg-x3;
                                Appr=x3;
                        end
                        else
                                D=D;
			if(Avg-x4<D)
                        begin
                                D=Avg-x4;
                                Appr=x4;
                        end
                        else
                                D=D;
                        if(Avg-x5<D)
                        begin
                                D=Avg-x5;
                                Appr=x5;
                        end
                        else
                                D=D;
                        if(Avg-x6<D)
                        begin
                                D=Avg-x6;
                                Appr=x6;
                        end
                        else
                                D=D;
                        if(Avg-x7<D)
                        begin
                                D=Avg-x7;
                                Appr=x7;
                        end
                        else
                                D=D;
                        if(Avg-x8<D)
                        begin
                                D=Avg-x8;
                                Appr=x8;
                        end
                        else
                                D=D;
			T=Appr*9;
			Sum=Sum+T;
			Y=Sum>>3;
			Sum=0;
		end
	end
end

endmodule
