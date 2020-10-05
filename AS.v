module AS(sel, A, B, S, O);
input [3:0] A, B;
input sel;
output [3:0] S;
output O;
reg [3:0] S;
reg O;


always @(A, sel ,B)
begin
	if(sel)
	begin
		S=A-B;
		if(A<8 && B>7 && S>7)
			O=1;
		else if (A>7 && B<8 && S<8)
			O=1;
		else 
			O=0;
	end
	else
	begin
		S=A+B;
		if(A<8 && B<8 && S>7)
                        O=1;
                else if (A>7 && B>7 && S<8)
                        O=1;
                else
                        O=0;
	end
end

endmodule
