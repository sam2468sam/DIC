`timescale 1ns/10ps

module MFE(clk,reset,busy,ready,iaddr,idata,data_rd,data_wr,addr,wen);

input				clk;
input				reset;
output	reg			busy;	
input				ready;	
output	reg	[13:0]	iaddr;
input		[7:0]	idata;	
input		[7:0]	data_rd;
output	reg	[7:0]	data_wr;
output	reg	[13:0]	addr;
output	reg			wen;

reg			[2:0]	CurrentState;
reg			[2:0]	NextState;

reg			[3:0]	counter;
reg			[2:0]	round;
reg			[3:0]	index;

reg					data_read;
reg					sort;

reg			[7:0]	data_unsorted[8:0];
reg         [7:0]   data_sorting[8:0];

always@(posedge clk or posedge reset)begin
	if(reset)
		data_wr <= 8'h0;
	else if(sort && counter == 4'ha)
		data_wr <= data_sorting[4];
end

always@(posedge clk or posedge reset)begin
	if(reset)
		index <= 4'h4;
	else if(data_read)begin
		if(round == 3'h3)begin//addr = 0 or 16256 //left-top & left-down
			case(counter)
				4'h1:
					index <= index + 2'h2;
				4'h3:
					index <= index - 2'h3;
				default:
					index <= index + 1'h1;
			endcase
		end
		else if(round == 3'h1)begin//addr < 127 or > 16256 //top & down
			case(counter)
				4'h0:
					index <= index + 2'h3;
				default:
					index <= index - 2'h3;
			endcase
		end
		else if(round == 3'h0)begin//addr[6:0] = 127 //right
			if(addr == 7'h7f)
				index <= index - 3'h4;
			else
				index <= index - 1'h1;
		end
		else if(round == 3'h5)begin//addr[6:0] = 0 //left
			case(counter)
				4'h1:
					index <= index + 2'h2;
				4'h3:
					index <= index + 2'h2;
				4'h5:
					index <= index - 3'h6;
				default:
					index <= index + 1'h1;
			endcase
		end
		else if(round == 3'h2)begin//other
			case(counter)
				3'h2:
					index <= index - 3'h6;
				default:
					index <= index + 2'h3;
			endcase
		end
	end
end

always@(posedge clk or posedge reset)begin
	if(reset)begin
		data_sorting[0] <= 8'h0;
		data_sorting[1] <= 8'h0;
		data_sorting[2] <= 8'h0;
		data_sorting[3] <= 8'h0;
		data_sorting[4] <= 8'h0;
		data_sorting[5] <= 8'h0;
		data_sorting[6] <= 8'h0;
		data_sorting[7] <= 8'h0;
		data_sorting[8] <= 8'h0;
	end
	else if(sort && counter == 4'h0)begin
		if(addr == 14'h0)begin//left-top
			data_sorting[0] <= 8'h0;
			data_sorting[1] <= 8'h0;
			data_sorting[2] <= 8'h0;
			data_sorting[3] <= 8'h0;
			data_sorting[4] <= data_unsorted[4];
			data_sorting[5] <= data_unsorted[5];
			data_sorting[6] <= 8'h0;
			data_sorting[7] <= data_unsorted[7];
			data_sorting[8] <= data_unsorted[8];
		end
		else if(addr == 7'h7f)begin//right-top
			data_sorting[0] <= 8'h0;
			data_sorting[1] <= 8'h0;
			data_sorting[2] <= 8'h0;
			data_sorting[3] <= data_unsorted[3];
			data_sorting[4] <= data_unsorted[4];
			data_sorting[5] <= 8'h0;
			data_sorting[6] <= data_unsorted[6];
			data_sorting[7] <= data_unsorted[7];
			data_sorting[8] <= 8'h0;
		end
		else if(addr == 14'h3f80)begin//left-down
			data_sorting[0] <= 8'h0;
			data_sorting[1] <= data_unsorted[1];
			data_sorting[2] <= data_unsorted[2];
			data_sorting[3] <= 8'h0;
			data_sorting[4] <= data_unsorted[4];
			data_sorting[5] <= data_unsorted[5];
			data_sorting[6] <= 8'h0;
			data_sorting[7] <= 8'h0;
			data_sorting[8] <= 8'h0;
		end
		else if(addr == 14'h3fff)begin//right-down
			data_sorting[0] <= data_unsorted[0];
			data_sorting[1] <= data_unsorted[1];
			data_sorting[2] <= 8'h0;
			data_sorting[3] <= data_unsorted[3];
			data_sorting[4] <= data_unsorted[4];
			data_sorting[5] <= 8'h0;
			data_sorting[6] <= 8'h0;
			data_sorting[7] <= 8'h0;
			data_sorting[8] <= 8'h0;
		end
		else if(addr[13:7] == 7'h0)begin//top
			data_sorting[0] <= 8'h0;
			data_sorting[1] <= 8'h0;
			data_sorting[2] <= 8'h0;
			data_sorting[3] <= data_unsorted[3];
			data_sorting[4] <= data_unsorted[4];
			data_sorting[5] <= data_unsorted[5];
			data_sorting[6] <= data_unsorted[6];
			data_sorting[7] <= data_unsorted[7];
			data_sorting[8] <= data_unsorted[8];
		end
		else if(addr[6:0] == 7'h0)begin//left
			data_sorting[0] <= 8'h0;
			data_sorting[1] <= data_unsorted[1];
			data_sorting[2] <= data_unsorted[2];
			data_sorting[3] <= 8'h0;
			data_sorting[4] <= data_unsorted[4];
			data_sorting[5] <= data_unsorted[5];
			data_sorting[6] <= 8'h0;
			data_sorting[7] <= data_unsorted[7];
			data_sorting[8] <= data_unsorted[8];
		end
		else if(addr[6:0] == 7'h7f)begin//right
			data_sorting[0] <= data_unsorted[0];
			data_sorting[1] <= data_unsorted[1];
			data_sorting[2] <= 8'h0;
			data_sorting[3] <= data_unsorted[3];
			data_sorting[4] <= data_unsorted[4];
			data_sorting[5] <= 8'h0;
			data_sorting[6] <= data_unsorted[6];
			data_sorting[7] <= data_unsorted[7];
			data_sorting[8] <= 8'h0;
		end
		else if(addr[13:7] == 7'h7f)begin//down
			data_sorting[0] <= data_unsorted[0];
			data_sorting[1] <= data_unsorted[1];
			data_sorting[2] <= data_unsorted[2];
			data_sorting[3] <= data_unsorted[3];
			data_sorting[4] <= data_unsorted[4];
			data_sorting[5] <= data_unsorted[5];
			data_sorting[6] <= 8'h0;
			data_sorting[7] <= 8'h0;
			data_sorting[8] <= 8'h0;
		end
		else begin//other
			data_sorting[0] <= data_unsorted[0];
			data_sorting[1] <= data_unsorted[1];
			data_sorting[2] <= data_unsorted[2];
			data_sorting[3] <= data_unsorted[3];
			data_sorting[4] <= data_unsorted[4];
			data_sorting[5] <= data_unsorted[5];
			data_sorting[6] <= data_unsorted[6];
			data_sorting[7] <= data_unsorted[7];
			data_sorting[8] <= data_unsorted[8];
		end
	end
	else if(sort && counter == 4'ha)begin
		data_sorting[0] <= data_sorting[0];
	end
	else if(sort && counter[0] == 1'h0)begin
		if(data_sorting[0] > data_sorting[1])begin
			data_sorting[0] <= data_sorting[1];
			data_sorting[1] <= data_sorting[0];
		end
		if(data_sorting[2] > data_sorting[3])begin
			data_sorting[2] <= data_sorting[3];
			data_sorting[3] <= data_sorting[2];
		end
		if(data_sorting[4] > data_sorting[5])begin
			data_sorting[4] <= data_sorting[5];
			data_sorting[5] <= data_sorting[4];
		end
		if(data_sorting[6] > data_sorting[7])begin
			data_sorting[6] <= data_sorting[7];
			data_sorting[7] <= data_sorting[6];
		end
	end
	else if(sort && counter[0] == 1'h1)begin
		if(data_sorting[1] > data_sorting[2])begin
			data_sorting[1] <= data_sorting[2];
			data_sorting[2] <= data_sorting[1];
		end
		if(data_sorting[3] > data_sorting[4])begin
			data_sorting[3] <= data_sorting[4];
			data_sorting[4] <= data_sorting[3];
		end
		if(data_sorting[5] > data_sorting[6])begin
			data_sorting[5] <= data_sorting[6];
			data_sorting[6] <= data_sorting[5];
		end
		if(data_sorting[7] > data_sorting[8])begin
			data_sorting[7] <= data_sorting[8];
			data_sorting[8] <= data_sorting[7];
		end
	end
end

always@(posedge clk or posedge reset)begin
	if(reset)begin
		data_unsorted[0] <= 8'h0;
		data_unsorted[1] <= 8'h0;
		data_unsorted[2] <= 8'h0;
		data_unsorted[3] <= 8'h0;
		data_unsorted[4] <= 8'h0;
		data_unsorted[5] <= 8'h0;
		data_unsorted[6] <= 8'h0;
		data_unsorted[7] <= 8'h0;
		data_unsorted[8] <= 8'h0;
	end
	else if(data_read)begin
		if(round != 3'h0)
			data_unsorted[index] <= idata;
	end
	else if(sort && counter == 4'h0)begin
		data_unsorted[0] <= data_unsorted[1];
		data_unsorted[1] <= data_unsorted[2];
		data_unsorted[3] <= data_unsorted[4];
		data_unsorted[4] <= data_unsorted[5];
		data_unsorted[6] <= data_unsorted[7];
		data_unsorted[7] <= data_unsorted[8];
	end
end

always@(posedge clk or posedge reset)begin
	if(reset)
		iaddr <= 14'h0;
	else if(data_read)begin
		if(round == 3'h0)begin//addr[6:0] = 127 //right
			if(addr == 7'h7f)
				iaddr <= iaddr - 8'h80;
		end
		else if(round == 3'h3)begin//addr = 0 or 16256 //left-up & left-down
			case(counter)
				4'h1:
					iaddr <= iaddr + 8'h7f;
				4'h3:
					iaddr <= iaddr - 8'h7f;
				default:
					iaddr <= iaddr + 1'h1;
			endcase
		end
		else if(round == 3'h5)begin//addr[6:0] = 0 //left
			case(counter)
				4'h1:
					iaddr <= iaddr + 8'h7f;
				4'h3:
					iaddr <= iaddr + 8'h7f;
				4'h5:
					iaddr <= iaddr - 8'hff;
				default:
					iaddr <= iaddr + 1'h1;
			endcase
		end
		else if(round == 3'h1)begin//addr < 127 or > 16256 //up & down
			case(counter)
				4'h0:
					iaddr <= iaddr + 8'h80;
				default:
					iaddr <= iaddr - 8'h7f;
			endcase
		end
		else if(round == 3'h2)begin//other
			case(counter)
				4'h2:
					iaddr <= iaddr - 8'hff;
				default:
					iaddr <= iaddr + 8'h80;
			endcase
		end
	end
end

always@(posedge clk or posedge reset)begin
	if(reset)
		addr <= 14'h0;
	else if(wen)
		addr <= addr + 1'h1;
end

always@(posedge clk or posedge reset)begin
	if(reset)//addr = 0 // left-up
		round <= 3'h3;
	else if(wen)begin
		if(addr == 14'h3f7f)//addr = 16256 //left-down
			round <= 3'h3;
		else if(addr[6:0] == 7'h7e)//addr[6:0] = 127 //right
			round <= 3'h0;
		else if(addr[6:0] == 7'h7f)//addr[6:0] = 128 //left
			round <= 3'h5;
		else if(addr[13:7] == 7'h0)//addr < 127 //up
			round <= 3'h1;
		else if(addr[13:7] == 7'h7f)//addr > 16256 //down
			round <= 3'h1;
		else//other 
			round <= 3'h2;
	end
end

always@(posedge clk or posedge reset)begin
	if(reset)
		counter <= 4'h0;
	else if(data_read && counter == round)
		counter <= 4'h0;
	else if(data_read)
		counter <= counter + 1'h1;
	else if(sort && counter == 4'ha)
		counter <= 4'h0;
	else if(sort)
		counter <= counter + 1'h1;
end

always@(posedge clk or posedge reset)begin
	if(reset)
		CurrentState <= 3'h0;
	else
		CurrentState <= NextState;
end

always@(*)begin
	case(CurrentState)
		3'h0:begin//reset
			if(ready)
				NextState = 3'h5;
			else
				NextState = 3'h0;
		end
		3'h1:begin//read
			if(counter == round)
				NextState = 3'h2;
			else
				NextState = 3'h1;
		end
		3'h2:begin//sort
			if(counter == 4'ha)
				NextState = 3'h3;
			else
				NextState = 3'h2;
		end
		3'h3:begin//write
			if(addr == 14'h3fff)
				NextState = 3'h4;
			else
				NextState = 3'h1;
		end
		3'h5:begin
			NextState = 3'h1;
		end
		default:begin//finish
			NextState = 3'h4;
		end
	endcase
end

always@(*)begin
    case(CurrentState)
		3'h0:begin//reset
			data_read = 0;
			sort = 0;
			wen = 0;
			busy = 0;
		end
		3'h1:begin//read
			data_read = 1;
			sort = 0;
			wen = 0;
			busy = 1;
		end
		3'h2:begin//sort
			data_read = 0;
			sort = 1;
			wen = 0;
			busy = 1;
		end
		3'h3:begin//write
			data_read = 0;
			sort = 0;
			wen = 1;
			busy = 1;
		end
		3'h5:begin
			data_read = 0;
			sort = 0;
			wen = 0;
			busy = 1;
		end
		default:begin//finish
			data_read = 0;
			sort = 0;
			wen = 0;
			busy = 0;
		end
	endcase
end
	
endmodule
