module  FAS (data_valid, data, clk, rst, fir_d, fir_valid, fft_valid, done, freq, fft_d1, fft_d2, fft_d3, fft_d4, fft_d5, fft_d6, fft_d7, fft_d8, fft_d9, fft_d10, fft_d11, fft_d12, fft_d13, fft_d14, fft_d15, fft_d0);

input				clk;
input				rst;
input				data_valid;
input		[15:0]	data; 

output	reg			fir_valid;
output	reg	[15:0]	fir_d;

output	reg			fft_valid;
output	reg	[31:0]	fft_d0;
output	reg	[31:0]	fft_d1;
output	reg [31:0]	fft_d2;
output	reg [31:0]	fft_d3;
output	reg [31:0]	fft_d4;
output	reg [31:0]	fft_d5;
output	reg [31:0]	fft_d6;
output	reg [31:0]	fft_d7;
output	reg [31:0]	fft_d8;
output	reg	[31:0]	fft_d9;
output	reg [31:0]	fft_d10;
output	reg [31:0]	fft_d11;
output	reg [31:0]	fft_d12;
output	reg [31:0]	fft_d13;
output	reg [31:0]	fft_d14;
output	reg [31:0]	fft_d15;

output	reg			done;
output	reg	[3:0]	freq;

reg			[11:0]	fir_counter;
reg			[3:0]	fft_counter;
reg			[5:0]	freq_counter;
reg					fft_start;
reg					fft_valid_enable;

reg		signed	[15:0]	data_reg[31:0];
reg     signed  [31:0]  fir_reg[15:0];
reg     signed  [31:0]  adder_tree_level3[3:0];
reg     signed  [31:0]  adder_tree_level5;

reg		signed	[15:0]	fft_reg_real[15:0];
reg		signed	[39:0]	fft_stage1_real[15:0];
reg     signed  [39:0]  fft_stage1_imag[15:0];
reg     signed  [63:0]  fft_stage2_real[15:0];
reg     signed  [63:0]  fft_stage2_imag[15:0];
reg     signed  [31:0]  fft_stage3_real[15:0];
reg     signed  [31:0]  fft_stage3_imag[15:0];
reg     signed  [31:0]  fft_stage4_real[15:0];
reg     signed  [31:0]  fft_stage4_imag[15:0];

reg		signed	[31:0]	fft_d0_real_square;
reg     signed  [31:0]  fft_d0_imag_square;
reg     signed  [31:0]  fft_d1_real_square;
reg     signed  [31:0]  fft_d1_imag_square;
reg     signed  [31:0]  fft_d15_real_square;
reg     signed  [31:0]  fft_d15_imag_square;

wire	signed	[15:0]	fir_coefficent[15:0];

wire	signed	[23:0]	fft_coefficent_real[7:0];
wire    signed  [23:0]  fft_coefficent_imag[7:0];

integer i;

assign	fir_coefficent[0]  = 16'hff9e;
assign  fir_coefficent[1]  = 16'hff86;
assign  fir_coefficent[2]  = 16'hffa7;
assign  fir_coefficent[3]  = 16'h003b;
assign  fir_coefficent[4]  = 16'h014b;
assign  fir_coefficent[5]  = 16'h024a;
assign  fir_coefficent[6]  = 16'h0222;
assign  fir_coefficent[7]  = 16'hffe4;
assign  fir_coefficent[8]  = 16'hfbc5;
assign  fir_coefficent[9]  = 16'hf7ca;
assign  fir_coefficent[10] = 16'hf74e;
assign  fir_coefficent[11] = 16'hfd74;
assign  fir_coefficent[12] = 16'h0b1a;
assign  fir_coefficent[13] = 16'h1dac;
assign  fir_coefficent[14] = 16'h2f9e;
assign  fir_coefficent[15] = 16'h3aa9;

assign	fft_coefficent_real[0] = 24'h010000;
assign	fft_coefficent_real[1] = 24'h00ec83;
assign	fft_coefficent_real[2] = 24'h00b504;
assign	fft_coefficent_real[3] = 24'h0061f7;
assign	fft_coefficent_real[4] = 24'h000000;
assign	fft_coefficent_real[5] = 24'hff9e09;
assign	fft_coefficent_real[6] = 24'hff4afc;
assign	fft_coefficent_real[7] = 24'hff137d;

assign	fft_coefficent_imag[0] = 24'h000000;
assign	fft_coefficent_imag[1] = 24'hff9e09;
assign	fft_coefficent_imag[2] = 24'hff4afc;
assign	fft_coefficent_imag[3] = 24'hff137d;
assign	fft_coefficent_imag[4] = 24'hff0000;
assign	fft_coefficent_imag[5] = 24'hff137d;
assign	fft_coefficent_imag[6] = 24'hff4afc;
assign	fft_coefficent_imag[7] = 24'hff9e09;

always@(posedge clk or posedge rst)begin
	if(rst)
		freq_counter <= 6'h0;
	else if(fft_valid && freq_counter == 6'h3f)
		freq_counter <= freq_counter + 1'h0;
	else if(fft_valid)
		freq_counter <= freq_counter + 1'h1;
end

always@(posedge clk or posedge rst)begin
	if(rst)
		freq <= 4'h0;
	else begin
		if(fft_valid)begin
			if(fft_d0_real_square + fft_d0_imag_square > fft_d1_real_square + fft_d1_imag_square)begin
				if(fft_d0_real_square + fft_d0_imag_square > fft_d15_real_square + fft_d15_imag_square)
					freq <= 4'h0;
				else if(fft_d0_real_square + fft_d0_imag_square < fft_d15_real_square + fft_d15_imag_square)
					freq <= 4'hf;
			end
			else if(fft_d0_real_square + fft_d0_imag_square < fft_d1_real_square + fft_d1_imag_square)begin
				if(fft_d1_real_square + fft_d1_imag_square > fft_d15_real_square + fft_d15_imag_square)
					freq <= 4'h1;
				else if(fft_d1_real_square + fft_d1_imag_square < fft_d15_real_square + fft_d15_imag_square)
					freq <= 4'hf;
			end
		end
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)
		done <= 1'h0;
	else begin
		if(fft_valid && freq_counter != 6'h3f)
			done <= 1'h1;
		else
			done <= 1'h0;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 16; i = i + 1)begin
			fft_d0_real_square <= 32'h0;
			fft_d0_imag_square <= 32'h0;
			fft_d1_real_square <= 32'h0;
			fft_d1_imag_square <= 32'h0;
			fft_d15_real_square <= 32'h0;
			fft_d15_imag_square <= 32'h0;
		end
	end
	else if(fft_start)begin
		fft_d0_real_square  <= $signed(fft_stage4_real[ 0][23:8]) * $signed(fft_stage4_real[ 0][23:8]);
		fft_d0_imag_square  <= $signed(fft_stage4_imag[ 0][23:8]) * $signed(fft_stage4_imag[ 0][23:8]);
		fft_d1_real_square  <= $signed(fft_stage4_real[ 8][23:8]) * $signed(fft_stage4_real[ 8][23:8]);
		fft_d1_imag_square  <= $signed(fft_stage4_imag[ 8][23:8]) * $signed(fft_stage4_imag[ 8][23:8]);
		fft_d15_real_square <= $signed(fft_stage4_real[15][23:8]) * $signed(fft_stage4_real[15][23:8]);
		fft_d15_imag_square <= $signed(fft_stage4_imag[15][23:8]) * $signed(fft_stage4_imag[15][23:8]);
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		fft_valid_enable <= 1'h0;
		fft_valid <= 1'h0;
	end
	else begin
		if(fft_start && fft_counter == 4'hf)
			fft_valid_enable <= 1'h1;
		else if(fft_start && fft_valid_enable && fft_counter == 4'h4)
			fft_valid <= 1'h1;
		else
			fft_valid <= 1'h0;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		fft_d0 <= 32'h0;
		fft_d1 <= 32'h0;
		fft_d2 <= 32'h0;
		fft_d3 <= 32'h0;
		fft_d4 <= 32'h0;
		fft_d5 <= 32'h0;
		fft_d6 <= 32'h0;
		fft_d7 <= 32'h0;
		fft_d8 <= 32'h0;
		fft_d9 <= 32'h0;
		fft_d10 <= 32'h0;
		fft_d11 <= 32'h0;
		fft_d12 <= 32'h0;
		fft_d13 <= 32'h0;
		fft_d14 <= 32'h0;
		fft_d15 <= 32'h0;
	end
	else begin
		if(fft_start)begin
			fft_d0 <=  {fft_stage4_real[ 0][23:8], fft_stage4_imag[ 0][23:8]};
			fft_d1 <=  {fft_stage4_real[ 8][23:8], fft_stage4_imag[ 8][23:8]};
			fft_d2 <=  {fft_stage4_real[ 4][23:8], fft_stage4_imag[ 4][23:8]};
			fft_d3 <=  {fft_stage4_real[12][23:8], fft_stage4_imag[12][23:8]};
			fft_d4 <=  {fft_stage4_real[ 2][23:8], fft_stage4_imag[ 2][23:8]};
			fft_d5 <=  {fft_stage4_real[10][23:8], fft_stage4_imag[10][23:8]};
			fft_d6 <=  {fft_stage4_real[ 6][23:8], fft_stage4_imag[ 6][23:8]};
			fft_d7 <=  {fft_stage4_real[14][23:8], fft_stage4_imag[14][23:8]};
			fft_d8 <=  {fft_stage4_real[ 1][23:8], fft_stage4_imag[ 1][23:8]};
			fft_d9 <=  {fft_stage4_real[ 9][23:8], fft_stage4_imag[ 9][23:8]};
			fft_d10 <= {fft_stage4_real[ 5][23:8], fft_stage4_imag[ 5][23:8]};
			fft_d11 <= {fft_stage4_real[13][23:8], fft_stage4_imag[13][23:8]};
			fft_d12 <= {fft_stage4_real[ 3][23:8], fft_stage4_imag[ 3][23:8]};
			fft_d13 <= {fft_stage4_real[11][23:8], fft_stage4_imag[11][23:8]};
			fft_d14 <= {fft_stage4_real[ 7][23:8], fft_stage4_imag[ 7][23:8]};
			fft_d15 <= {fft_stage4_real[15][23:8], fft_stage4_imag[15][23:8]};
		end
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 16; i = i + 1)begin
			fft_stage4_real[i] <= 32'h0;
			fft_stage4_imag[i] <= 32'h0;
		end
	end
	else begin
		if(fft_start)begin
			fft_stage4_real[ 0] <= fft_stage3_real[ 0] + fft_stage3_real[ 1];
			fft_stage4_real[ 1] <= fft_stage3_real[ 0] - fft_stage3_real[ 1];
			fft_stage4_real[ 2] <= fft_stage3_real[ 2] + fft_stage3_real[ 3];
			fft_stage4_real[ 3] <= fft_stage3_real[ 2] - fft_stage3_real[ 3];
			fft_stage4_real[ 4] <= fft_stage3_real[ 4] + fft_stage3_real[ 5];
			fft_stage4_real[ 5] <= fft_stage3_real[ 4] - fft_stage3_real[ 5];
			fft_stage4_real[ 6] <= fft_stage3_real[ 6] + fft_stage3_real[ 7];
			fft_stage4_real[ 7] <= fft_stage3_real[ 6] - fft_stage3_real[ 7];
			fft_stage4_real[ 8] <= fft_stage3_real[ 8] + fft_stage3_real[ 9];
			fft_stage4_real[ 9] <= fft_stage3_real[ 8] - fft_stage3_real[ 9];
			fft_stage4_real[10] <= fft_stage3_real[10] + fft_stage3_real[11];
			fft_stage4_real[11] <= fft_stage3_real[10] - fft_stage3_real[11];
			fft_stage4_real[12] <= fft_stage3_real[12] + fft_stage3_real[13];
			fft_stage4_real[13] <= fft_stage3_real[12] - fft_stage3_real[13];
			fft_stage4_real[14] <= fft_stage3_real[14] + fft_stage3_real[15];
			fft_stage4_real[15] <= fft_stage3_real[14] - fft_stage3_real[15];
			fft_stage4_imag[ 0] <= fft_stage3_imag[ 0] + fft_stage3_imag[ 1];
			fft_stage4_imag[ 1] <= fft_stage3_imag[ 0] - fft_stage3_imag[ 1];
			fft_stage4_imag[ 2] <= fft_stage3_imag[ 2] + fft_stage3_imag[ 3];
			fft_stage4_imag[ 3] <= fft_stage3_imag[ 2] - fft_stage3_imag[ 3];
			fft_stage4_imag[ 4] <= fft_stage3_imag[ 4] + fft_stage3_imag[ 5];
			fft_stage4_imag[ 5] <= fft_stage3_imag[ 4] - fft_stage3_imag[ 5];
			fft_stage4_imag[ 6] <= fft_stage3_imag[ 6] + fft_stage3_imag[ 7];
			fft_stage4_imag[ 7] <= fft_stage3_imag[ 6] - fft_stage3_imag[ 7];
			fft_stage4_imag[ 8] <= fft_stage3_imag[ 8] + fft_stage3_imag[ 9];
			fft_stage4_imag[ 9] <= fft_stage3_imag[ 8] - fft_stage3_imag[ 9];
			fft_stage4_imag[10] <= fft_stage3_imag[10] + fft_stage3_imag[11];
			fft_stage4_imag[11] <= fft_stage3_imag[10] - fft_stage3_imag[11];
			fft_stage4_imag[12] <= fft_stage3_imag[12] + fft_stage3_imag[13];
			fft_stage4_imag[13] <= fft_stage3_imag[12] - fft_stage3_imag[13];
			fft_stage4_imag[14] <= fft_stage3_imag[14] + fft_stage3_imag[15];
			fft_stage4_imag[15] <= fft_stage3_imag[14] - fft_stage3_imag[15];
		end
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 16; i = i + 1)begin
			fft_stage3_real[i] <= 32'h0;
			fft_stage3_imag[i] <= 32'h0;
		end
	end
	else begin
		if(fft_start)begin
			fft_stage3_real[ 0] <= fft_stage2_real[ 0][47:16] + fft_stage2_real[ 2][47:16];
			fft_stage3_real[ 1] <= fft_stage2_real[ 1][47:16] + fft_stage2_real[ 3][47:16];
			fft_stage3_real[ 2] <= fft_stage2_real[ 0][47:16] - fft_stage2_real[ 2][47:16];
			fft_stage3_real[ 3] <= fft_stage2_imag[ 1][47:16] - fft_stage2_imag[ 3][47:16];
			fft_stage3_real[ 4] <= fft_stage2_real[ 4][47:16] + fft_stage2_real[ 6][47:16];
			fft_stage3_real[ 5] <= fft_stage2_real[ 5][47:16] + fft_stage2_real[ 7][47:16];
			fft_stage3_real[ 6] <= fft_stage2_real[ 4][47:16] - fft_stage2_real[ 6][47:16];
			fft_stage3_real[ 7] <= fft_stage2_imag[ 5][47:16] - fft_stage2_imag[ 7][47:16];
			fft_stage3_real[ 8] <= fft_stage2_real[ 8][47:16] + fft_stage2_real[10][47:16];
			fft_stage3_real[ 9] <= fft_stage2_real[ 9][47:16] + fft_stage2_real[11][47:16];
			fft_stage3_real[10] <= fft_stage2_real[ 8][47:16] - fft_stage2_real[10][47:16];
			fft_stage3_real[11] <= fft_stage2_imag[ 9][47:16] - fft_stage2_imag[11][47:16];
			fft_stage3_real[12] <= fft_stage2_real[12][47:16] + fft_stage2_real[14][47:16];
			fft_stage3_real[13] <= fft_stage2_real[13][47:16] + fft_stage2_real[15][47:16];
			fft_stage3_real[14] <= fft_stage2_real[12][47:16] - fft_stage2_real[14][47:16];
			fft_stage3_real[15] <= fft_stage2_imag[13][47:16] - fft_stage2_imag[15][47:16];
			fft_stage3_imag[ 0] <= fft_stage2_imag[ 0][47:16] + fft_stage2_imag[ 2][47:16];
			fft_stage3_imag[ 1] <= fft_stage2_imag[ 1][47:16] + fft_stage2_imag[ 3][47:16];
			fft_stage3_imag[ 2] <= fft_stage2_imag[ 0][47:16] - fft_stage2_imag[ 2][47:16];
			fft_stage3_imag[ 3] <= fft_stage2_real[ 3][47:16] - fft_stage2_real[ 1][47:16];
			fft_stage3_imag[ 4] <= fft_stage2_imag[ 4][47:16] + fft_stage2_imag[ 6][47:16];
			fft_stage3_imag[ 5] <= fft_stage2_imag[ 5][47:16] + fft_stage2_imag[ 7][47:16];
			fft_stage3_imag[ 6] <= fft_stage2_imag[ 4][47:16] - fft_stage2_imag[ 6][47:16];
			fft_stage3_imag[ 7] <= fft_stage2_real[ 7][47:16] - fft_stage2_real[ 5][47:16];
			fft_stage3_imag[ 8] <= fft_stage2_imag[ 8][47:16] + fft_stage2_imag[10][47:16];
			fft_stage3_imag[ 9] <= fft_stage2_imag[ 9][47:16] + fft_stage2_imag[11][47:16];
			fft_stage3_imag[10] <= fft_stage2_imag[ 8][47:16] - fft_stage2_imag[10][47:16];
			fft_stage3_imag[11] <= fft_stage2_real[11][47:16] - fft_stage2_real[ 9][47:16];
			fft_stage3_imag[12] <= fft_stage2_imag[12][47:16] + fft_stage2_imag[14][47:16];
			fft_stage3_imag[13] <= fft_stage2_imag[13][47:16] + fft_stage2_imag[15][47:16];
			fft_stage3_imag[14] <= fft_stage2_imag[12][47:16] - fft_stage2_imag[14][47:16];
			fft_stage3_imag[15] <= fft_stage2_real[15][47:16] - fft_stage2_real[13][47:16];
		end
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 16; i = i + 1)begin
			fft_stage2_real[i] <= 64'h0;
			fft_stage2_imag[i] <= 64'h0;
		end
	end
	else begin
		if(fft_start)begin
			fft_stage2_real[ 0][63:8] <= fft_stage1_real[ 0] + fft_stage1_real[ 4];
			fft_stage2_real[ 1][63:8] <= fft_stage1_real[ 1] + fft_stage1_real[ 5];
			fft_stage2_real[ 2][63:8] <= fft_stage1_real[ 2] + fft_stage1_real[ 6];
			fft_stage2_real[ 3][63:8] <= fft_stage1_real[ 3] + fft_stage1_real[ 7];
			fft_stage2_real[ 4][63:8] <= fft_stage1_real[ 0] - fft_stage1_real[ 4];
			fft_stage2_real[ 5] <= $signed((fft_stage1_real[ 1][39:8] - fft_stage1_real[ 5][39:8])) * fft_coefficent_real[2];
			fft_stage2_real[ 6][63:8] <= fft_stage1_imag[ 2] - fft_stage1_imag[ 6];
			fft_stage2_real[ 7] <= $signed((fft_stage1_real[ 3][39:8] - fft_stage1_real[ 7][39:8])) * fft_coefficent_real[6];
			fft_stage2_real[ 8][63:8] <= fft_stage1_real[ 8] + fft_stage1_real[12];
			fft_stage2_real[ 9][63:8] <= fft_stage1_real[ 9] + fft_stage1_real[13];
			fft_stage2_real[10][63:8] <= fft_stage1_real[10] + fft_stage1_real[14];
			fft_stage2_real[11][63:8] <= fft_stage1_real[11] + fft_stage1_real[15];
			fft_stage2_real[12][63:8] <= fft_stage1_real[ 8] - fft_stage1_real[12];
			fft_stage2_real[13] <= $signed((fft_stage1_real[ 9][39:8] - fft_stage1_real[13][39:8])) * fft_coefficent_real[2] 
								 + $signed((fft_stage1_imag[13][39:8] - fft_stage1_imag[ 9][39:8])) * fft_coefficent_imag[2];
			fft_stage2_real[14][63:8] <= fft_stage1_imag[10] - fft_stage1_imag[14];
			fft_stage2_real[15] <= $signed((fft_stage1_real[11][39:8] - fft_stage1_real[15][39:8])) * fft_coefficent_real[6] 
								 + $signed((fft_stage1_imag[15][39:8] - fft_stage1_imag[11][39:8])) * fft_coefficent_imag[6];
			fft_stage2_imag[ 0][63:8] <= fft_stage1_imag[ 0] + fft_stage1_imag[ 4];
			fft_stage2_imag[ 1][63:8] <= fft_stage1_imag[ 1] + fft_stage1_imag[ 5];
			fft_stage2_imag[ 2][63:8] <= fft_stage1_imag[ 2] + fft_stage1_imag[ 6];
			fft_stage2_imag[ 3][63:8] <= fft_stage1_imag[ 3] + fft_stage1_imag[ 7];
			fft_stage2_imag[ 4][63:8] <= fft_stage1_imag[ 0] - fft_stage1_imag[ 4];
			fft_stage2_imag[ 5] <= $signed((fft_stage1_real[ 1][39:8] - fft_stage1_real[ 5][39:8])) * fft_coefficent_imag[2];
			fft_stage2_imag[ 6][63:8] <= fft_stage1_real[ 6] - fft_stage1_real[ 2];
			fft_stage2_imag[ 7] <= $signed((fft_stage1_real[ 3][39:8] - fft_stage1_real[ 7][39:8])) * fft_coefficent_imag[6];
			fft_stage2_imag[ 8][63:8] <= fft_stage1_imag[ 8] + fft_stage1_imag[12];
			fft_stage2_imag[ 9][63:8] <= fft_stage1_imag[ 9] + fft_stage1_imag[13];
			fft_stage2_imag[10][63:8] <= fft_stage1_imag[10] + fft_stage1_imag[14];
			fft_stage2_imag[11][63:8] <= fft_stage1_imag[11] + fft_stage1_imag[15];
			fft_stage2_imag[12][63:8] <= fft_stage1_imag[ 8] - fft_stage1_imag[12];
			fft_stage2_imag[13] <= $signed((fft_stage1_real[ 9][39:8] - fft_stage1_real[13][39:8])) * fft_coefficent_imag[2] 
								 + $signed((fft_stage1_imag[ 9][39:8] - fft_stage1_imag[13][39:8])) * fft_coefficent_real[2];
			fft_stage2_imag[14][63:8] <= fft_stage1_real[14] - fft_stage1_real[10];
			fft_stage2_imag[15] <= $signed((fft_stage1_real[11][39:8] - fft_stage1_real[15][39:8])) * fft_coefficent_imag[6] 
								 + $signed((fft_stage1_imag[11][39:8] - fft_stage1_imag[15][39:8])) * fft_coefficent_real[6];
		end
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 16; i = i + 1)begin
			fft_stage1_real[i] <= 40'h0;
			fft_stage1_imag[i] <= 40'h0;
		end
	end
	else begin
		if(fft_start)begin
			for(i = 0; i < 8; i = i + 1)
				fft_stage1_real[i][39:16] <= fft_reg_real[i] + fft_reg_real[i + 8];
			for(i = 8; i < 16; i = i + 1)begin
				fft_stage1_real[i] <= (fft_reg_real[i - 8] - fft_reg_real[i]) * fft_coefficent_real[i - 8];
				fft_stage1_imag[i] <= (fft_reg_real[i - 8] - fft_reg_real[i]) * fft_coefficent_imag[i - 8];
			end
		end
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 16; i = i + 1)
			fft_reg_real[i] <= 16'h0;
	end
	else begin
		if(fft_start)
			fft_reg_real[fft_counter] <= fir_d;
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)
		fft_counter <= 4'h0;
	else if(fir_counter == 11'h23)
		fft_counter <= 4'h0;
	else
		fft_counter <= fft_counter + 1'h1;
end

always@(posedge clk or posedge rst)begin
	if(rst)
		fft_start <= 1'h0;
	else if(fir_counter == 11'h23)
		fft_start <= 1'h1;
end

always@(posedge clk or posedge rst)begin
	if(rst)
		fir_d <= 16'h0;
	else begin
		if(adder_tree_level5[31])
			fir_d <= adder_tree_level5[31:16] + 1'h1;
		else
			fir_d <= adder_tree_level5[31:16];
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)
		fir_valid <= 1'h0;
	else if(fir_counter == 11'h23)
		fir_valid <= 1'h1;
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 4; i = i + 1)
			adder_tree_level3[i] <= 32'h0;
		adder_tree_level5 <= 32'h0;
	end
	else begin
		for(i = 0; i < 4; i = i + 1)
			adder_tree_level3[i] <= fir_reg[i] + fir_reg[i + 4] + fir_reg[i + 8] + fir_reg[i + 12];
		adder_tree_level5 <= adder_tree_level3[0] + adder_tree_level3[1] + adder_tree_level3[2] + adder_tree_level3[3];
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 32; i = i + 1)
			data_reg[i] <= 16'h0;
	end
	else begin
		data_reg[0] <= data;
		for(i = 1; i < 32; i = i + 1)
			data_reg[i] <= data_reg[i - 1];
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)begin
		for(i = 0; i < 16; i = i + 1)
			fir_reg[i] <= 32'h0;
	end
	else begin
		for(i = 0; i < 16; i = i + 1)
			fir_reg[i] <= (data_reg[i] + data_reg[31 - i]) * fir_coefficent[i];
	end
end

always@(posedge clk or posedge rst)begin
	if(rst)
		fir_counter <= 11'h0;
	else
		fir_counter <= fir_counter + 1'h1;
end

endmodule
