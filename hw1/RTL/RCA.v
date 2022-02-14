module RCA(s, c_out, x, y, c_in);
input  [3:0] x, y;
output [3:0] s;
input  c_in;
output c_out;
wire c1 ,c2, c3;

FA FA1(.s(s[0]), .c_out(c1), .x(x[0]), .y(y[0]), .c_in(c_in));
FA FA2(.s(s[1]), .c_out(c2), .x(x[1]), .y(y[1]), .c_in(c1));
FA FA3(.s(s[2]), .c_out(c3), .x(x[2]), .y(y[2]), .c_in(c2));
FA FA4(.s(s[3]), .c_out(c_out), .x(x[3]), .y(y[3]), .c_in(c3));

endmodule

