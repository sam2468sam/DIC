module booth(out, in1, in2);

parameter width = 6;

input  	[width-1:0] in1;   //multiplicand
input  	[width-1:0] in2;   //multiplier
output  [2*width-1:0] out; //product

reg [2*width-1:0] out;
reg [2*width:0] P;
reg [1:0] L;

always @(in1,in2)
begin
   P[2*width:width+1] = 6'b000000;
   P[width:1] = in2;
   P[0] = 1'b0;

   case (P[1:0])
      2'b00: P[2*width:width+1] = P[2*width:width+1] + 0;
      2'b01: P[2*width:width+1] = P[2*width:width+1] + in1;
      2'b10: P[2*width:width+1] = P[2*width:width+1] - in1;
      2'b11: P[2*width:width+1] = P[2*width:width+1] + 0;
   endcase

   P[2*width-1:0]=P[2*width:1];
   
   case (P[1:0])
      2'b00: P[2*width:width+1] = P[2*width:width+1] + 0;
      2'b01: P[2*width:width+1] = P[2*width:width+1] + in1;
      2'b10: P[2*width:width+1] = P[2*width:width+1] - in1;
      2'b11: P[2*width:width+1] = P[2*width:width+1] + 0;
   endcase

   P[2*width-1:0]=P[2*width:1];

   case (P[1:0])
      2'b00: P[2*width:width+1] = P[2*width:width+1] + 0;
      2'b01: P[2*width:width+1] = P[2*width:width+1] + in1;
      2'b10: P[2*width:width+1] = P[2*width:width+1] - in1;
      2'b11: P[2*width:width+1] = P[2*width:width+1] + 0;
   endcase

   P[2*width-1:0]=P[2*width:1];

   case (P[1:0])
      2'b00: P[2*width:width+1] = P[2*width:width+1] + 0;
      2'b01: P[2*width:width+1] = P[2*width:width+1] + in1;
      2'b10: P[2*width:width+1] = P[2*width:width+1] - in1;
      2'b11: P[2*width:width+1] = P[2*width:width+1] + 0;
   endcase

   P[2*width-1:0]=P[2*width:1];

   case (P[1:0])
      2'b00: P[2*width:width+1] = P[2*width:width+1] + 0;
      2'b01: P[2*width:width+1] = P[2*width:width+1] + in1;
      2'b10: P[2*width:width+1] = P[2*width:width+1] - in1;
      2'b11: P[2*width:width+1] = P[2*width:width+1] + 0;
   endcase

   P[2*width-1:0]=P[2*width:1];

   case (P[1:0])
      2'b00: P[2*width:width+1] = P[2*width:width+1] + 0;
      2'b01: P[2*width:width+1] = P[2*width:width+1] + in1;
      2'b10: P[2*width:width+1] = P[2*width:width+1] - in1;
      2'b11: P[2*width:width+1] = P[2*width:width+1] + 0;
   endcase

   P[2*width-1:0]=P[2*width:1];

   out[2*width-1:0] = P[2*width:1];
end

endmodule
