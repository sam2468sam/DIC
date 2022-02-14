module PSE ( clk,reset,Xin,Yin,point_num,valid,Xout,Yout);
input			clk;
input			reset;
input	[9:0]	Xin;
input	[9:0]	Yin;
input	[2:0]	point_num;
output			valid;
output	[9:0]	Xout;
output	[9:0]	Yout;

reg		[1:0]	CurrentState;
reg		[1:0]	NextState;

reg		[2:0]	counter;
reg		[2:0]	counter_i;
reg     [2:0]   counter_j;

reg				load;
reg             sort;
reg             write;
reg				valid;

reg		[9:0]	coordinate_x[5:0];
reg		[9:0]	coordinate_y[5:0];

reg		[9:0]   Xout;
reg		[9:0]   Yout;

//wire    signed  [10:0]  edge_x[4:0];
//wire    signed  [10:0]  edge_y[4:0];

reg		signed  [10:0]  multiplier1;
reg     signed  [10:0]  multiplier2;
wire	signed	[20:0]	multiplier3;
reg     signed  [20:0]  result;

assign	multiplier3 = multiplier1 * multiplier2;

//assign  edge_x[0] = coordinate_x[1] - coordinate_x[0];
//assign  edge_x[1] = coordinate_x[2] - coordinate_x[0];
//assign  edge_x[2] = coordinate_x[3] - coordinate_x[0];
//assign  edge_x[3] = coordinate_x[4] - coordinate_x[0];
//assign  edge_x[4] = coordinate_x[5] - coordinate_x[0];
//
//assign  edge_y[0] = coordinate_y[1] - coordinate_y[0];
//assign  edge_y[1] = coordinate_y[2] - coordinate_y[0];
//assign  edge_y[2] = coordinate_y[3] - coordinate_y[0];
//assign  edge_y[3] = coordinate_y[4] - coordinate_y[0];
//assign  edge_y[4] = coordinate_y[5] - coordinate_y[0];

always@(posedge clk or posedge reset)begin//valid
	if(reset)
		valid = 1'h0;
	else if(write && counter == point_num)
		valid = 1'h0;
	else if(write)
		valid = 1'h1;
end

always@(posedge clk or posedge reset)begin//output
	if(reset)begin
		Xout <= 10'h0;
		Yout <= 10'h0;
	end
	else if(write)begin
		Xout <= coordinate_x[counter];
		Yout <= coordinate_y[counter];
	end
end

always@(posedge clk or posedge reset)begin//multiplier1
	if(reset)begin
		multiplier1 <= 11'h0;
		multiplier2 <= 11'h0;
		result <= 21'h0;
	end
	else if(sort)begin
		case(counter)
			3'h0:begin
				multiplier1 <= coordinate_x[counter_j + 1'h1] - coordinate_x[0];
				multiplier2 <= coordinate_y[counter_i + 1'h1] - coordinate_y[0];
			end
			3'h1:begin
				result <= multiplier3;
			end
			3'h2:begin
				multiplier1 <= coordinate_x[counter_i + 1'h1] - coordinate_x[0];
				multiplier2 <= coordinate_y[counter_j + 1'h1] - coordinate_y[0];
			end
			3'h3:begin
				result <= result - multiplier3;
			end
		endcase
	end
end

always@(posedge clk or posedge reset)begin//coordinate
	if(reset)begin
		coordinate_x[0] <= 10'h0;
		coordinate_x[1] <= 10'h0;
		coordinate_x[2] <= 10'h0;
		coordinate_x[3] <= 10'h0;
		coordinate_x[4] <= 10'h0;
		coordinate_x[5] <= 10'h0;
		coordinate_y[0] <= 10'h0;
		coordinate_y[1] <= 10'h0;
		coordinate_y[2] <= 10'h0;
		coordinate_y[3] <= 10'h0;
		coordinate_y[4] <= 10'h0;
		coordinate_y[5] <= 10'h0;
	end
	else if(load)begin
		coordinate_x[counter] <= Xin;
		coordinate_y[counter] <= Yin;
	end
	else if(sort && counter == 3'h4)begin
		if(result > 0)begin
			coordinate_x[counter_j + 1] <= coordinate_x[counter_i + 1];
			coordinate_x[counter_i + 1] <= coordinate_x[counter_j + 1];
			coordinate_y[counter_j + 1] <= coordinate_y[counter_i + 1];
			coordinate_y[counter_i + 1] <= coordinate_y[counter_j + 1];
		end
	end
end

always@(posedge clk or posedge reset)begin//counter_j
	if(reset)
		counter_j <= 3'h0;
	else if(sort && (counter_i == point_num - 2'h2) && (counter_j == point_num - 2'h3) && (counter == 3'h4))
		counter_j <= 3'h0;
	else if(sort && (counter_i == point_num - 2'h2) && (counter == 3'h4))
		counter_j <= counter_j + 1'h1;
end

always@(posedge clk or posedge reset)begin//counter_i
	if(reset)
		counter_i <= 3'h1;
	else if(sort && (counter_i == point_num - 2'h2) && (counter_j == point_num - 2'h3) && (counter == 3'h4))
		counter_i <= 3'h1;
	else if(sort && (counter_i == point_num - 2'h2) && (counter == 3'h4))
		counter_i <= counter_j + 2'h2;
	else if(sort && counter == 3'h4)
		counter_i <= counter_i + 1'h1;
end

always@(posedge clk or posedge reset)begin//counter
	if(reset)
		counter <= 3'h0;
	else if(load && counter == point_num - 1'h1)
		counter <= 3'h0;
	else if(load)
		counter <= counter + 1'h1;
	else if(sort && counter == 3'h4)
		counter <= 3'h0;
	else if(sort)
		counter <= counter + 1'h1;
	else if(write && counter == point_num)
		counter <= 3'h0;
	else if(write)
		counter <= counter + 1'h1;
end

always@(posedge clk or posedge reset)begin
	if(reset)
		CurrentState <= 2'h0;
	else
		CurrentState <= NextState;
end

always@(*)begin
	case(CurrentState)
		2'h0:begin//reset
			NextState = 2'h1;
		end
		2'h1:begin//load
			if(counter == point_num - 1'h1)
				NextState = 2'h2;
			else
				NextState = 2'h1;
		end
		2'h2:begin//sort
			if((counter_i == point_num - 2'h2) && (counter_j == point_num - 2'h3) && (counter == 3'h4))
				NextState = 2'h3;
			else
				NextState = 2'h2;
		end
		default:begin//write
			if(counter == point_num)
				NextState = 2'h1;
			else
				NextState = 2'h3;
		end
	endcase
end

always@(*)begin
	case(CurrentState)
		2'h0:begin//reset
			load = 1;
			sort = 0;
			write = 0;
		end
		2'h1:begin//load
			load = 1;
			sort = 0;
			write = 0;
		end
		2'h2:begin//sort
			load = 0;
			sort = 1;
			write = 0;
		end
		default:begin//write
			load = 0;
			sort = 0;
			write = 1;
		end
	endcase
end


endmodule

