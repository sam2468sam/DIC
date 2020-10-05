`timescale 1ns / 10ps
module div(out, in1, in2, dbz);
parameter width = 8;
input  	[width-1:0] in1; // Dividend
input  	[width-1:0] in2; // Divisor
output  [width-1:0] out; // Quotient
output dbz;

reg [width-1:0] out,temp,temp2;
reg dbz;

/********************************

You need to write your code at here

********************************/
always @(in1, in2)
begin
        if(in2==0)
		dbz=1;
        else
        begin
		dbz=0;
		temp=in1>>7;
		temp2=in1;
		if(temp>=in2)
		begin
			out[7]=1;
			temp2=temp2-(in2<<7);
		end
		else
			out[7]=0;
		temp=temp2>>6;
		if(temp>=in2)
                begin
                        out[6]=1;
                        temp2=temp2-(in2<<6);
                end
                else
                        out[6]=0;
		temp=temp2>>5;
                if(temp>=in2)
                begin
                        out[5]=1;
                        temp2=temp2-(in2<<5);
                end
                else
                        out[5]=0;
		temp=temp2>>4;
                if(temp>=in2)
                begin
                        out[4]=1;
                        temp2=temp2-(in2<<4);
                end
                else
                        out[4]=0;
		temp=temp2>>3;
                if(temp>=in2)
                begin
                        out[3]=1;
                        temp2=temp2-(in2<<3);
                end
                else
                        out[3]=0;
		temp=temp2>>2;
                if(temp>=in2)
                begin
                        out[2]=1;
                        temp2=temp2-(in2<<2);
                end
                else
                        out[2]=0;
		temp=temp2>>1;
                if(temp>=in2)
                begin
                        out[1]=1;
                        temp2=temp2-(in2<<1);
                end
                else
                        out[1]=0;
		temp=temp2;
                if(temp>=in2)
                        out[0]=1;
                else
                        out[0]=0;
        end
end


endmodule
