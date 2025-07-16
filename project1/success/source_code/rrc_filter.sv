`timescale 1ns / 1ps

module rrc_filter #(
	parameter WIDTH = 9
)(
	input logic clk,
	input logic rst,
	input logic signed [WIDTH-1:0] filter_in,

	output logic signed [WIDTH-1:0] filter_out
);
	
	logic signed [WIDTH-1:0] shift_reg_out [0:31];

	logic signed [2*WIDTH-1:0] mul_sum [0:32];

	logic signed [23:0] acc_sum;


	integer i;

	always @(posedge clk or posedge rst) begin
		if(rst) begin
			for(i = 0; i < 32; i=i+1) begin
				shift_reg_out[i] <= 9'b0;
			end
		end
		else begin
			shift_reg_out[0] <= filter_in;
			for(i = 0; i < 31; i=i+1) begin
				shift_reg_out[i+1] <= shift_reg_out[i];
			end
		end
	end

	multiplier_9b #(.WIDTH(9)) MUL0(.mul_in(filter_in), .coefficient(9'd0), .mul_out(mul_sum[0]));
	multiplier_9b #(.WIDTH(9)) MUL1(.mul_in(shift_reg_out[0]), .coefficient(-9'd1), .mul_out(mul_sum[1]));
	multiplier_9b #(.WIDTH(9)) MUL2(.mul_in(shift_reg_out[1]), .coefficient(9'd1),.mul_out(mul_sum[2]));
	multiplier_9b #(.WIDTH(9)) MUL3(.mul_in(shift_reg_out[2]), .coefficient(9'd0),.mul_out(mul_sum[3]));
	multiplier_9b #(.WIDTH(9)) MUL4(.mul_in(shift_reg_out[3]), .coefficient(-9'd1),.mul_out(mul_sum[4]));
	multiplier_9b #(.WIDTH(9)) MUL5(.mul_in(shift_reg_out[4]), .coefficient(9'd2),.mul_out(mul_sum[5]));
	multiplier_9b #(.WIDTH(9)) MUL6(.mul_in(shift_reg_out[5]), .coefficient(9'd0),.mul_out(mul_sum[6]));
	multiplier_9b #(.WIDTH(9)) MUL7(.mul_in(shift_reg_out[6]), .coefficient(-9'd2),.mul_out(mul_sum[7]));
	multiplier_9b #(.WIDTH(9)) MUL8(.mul_in(shift_reg_out[7]), .coefficient(9'd2),.mul_out(mul_sum[8]));
	multiplier_9b #(.WIDTH(9)) MUL9(.mul_in(shift_reg_out[8]), .coefficient(9'd0),.mul_out(mul_sum[9]));
	multiplier_9b #(.WIDTH(9)) MUL10(.mul_in(shift_reg_out[9]), .coefficient(-9'd6),.mul_out(mul_sum[10]));
	multiplier_9b #(.WIDTH(9)) MUL11(.mul_in(shift_reg_out[10]), .coefficient(9'd8),.mul_out(mul_sum[11]));
	multiplier_9b #(.WIDTH(9)) MUL12(.mul_in(shift_reg_out[11]), .coefficient(9'd10),.mul_out(mul_sum[12]));
	multiplier_9b #(.WIDTH(9)) MUL13(.mul_in(shift_reg_out[12]), .coefficient(-9'd28),.mul_out(mul_sum[13]));
	multiplier_9b #(.WIDTH(9)) MUL14(.mul_in(shift_reg_out[13]), .coefficient(-9'd14),.mul_out(mul_sum[14]));
	multiplier_9b #(.WIDTH(9)) MUL15(.mul_in(shift_reg_out[14]), .coefficient(9'd111),.mul_out(mul_sum[15]));
	multiplier_9b #(.WIDTH(9)) MUL16(.mul_in(shift_reg_out[15]), .coefficient(9'd196),.mul_out(mul_sum[16]));
	multiplier_9b #(.WIDTH(9)) MUL17(.mul_in(shift_reg_out[16]), .coefficient(9'd111),.mul_out(mul_sum[17]));
	multiplier_9b #(.WIDTH(9)) MUL18(.mul_in(shift_reg_out[17]), .coefficient(-9'd14),.mul_out(mul_sum[18]));
	multiplier_9b #(.WIDTH(9)) MUL19(.mul_in(shift_reg_out[18]), .coefficient(-9'd28),.mul_out(mul_sum[19]));
	multiplier_9b #(.WIDTH(9)) MUL20(.mul_in(shift_reg_out[19]), .coefficient(9'd10),.mul_out(mul_sum[20]));
	multiplier_9b #(.WIDTH(9)) MUL21(.mul_in(shift_reg_out[20]), .coefficient(9'd8),.mul_out(mul_sum[21]));
	multiplier_9b #(.WIDTH(9)) MUL22(.mul_in(shift_reg_out[21]), .coefficient(-9'd6),.mul_out(mul_sum[22]));
	multiplier_9b #(.WIDTH(9)) MUL23(.mul_in(shift_reg_out[22]), .coefficient(9'd0),.mul_out(mul_sum[23]));
	multiplier_9b #(.WIDTH(9)) MUL24(.mul_in(shift_reg_out[23]), .coefficient(9'd2),.mul_out(mul_sum[24]));
	multiplier_9b #(.WIDTH(9)) MUL25(.mul_in(shift_reg_out[24]), .coefficient(-9'd2),.mul_out(mul_sum[25]));
	multiplier_9b #(.WIDTH(9)) MUL26(.mul_in(shift_reg_out[25]), .coefficient(9'd0),.mul_out(mul_sum[26]));
	multiplier_9b #(.WIDTH(9)) MUL27(.mul_in(shift_reg_out[26]), .coefficient(9'd2),.mul_out(mul_sum[27]));
	multiplier_9b #(.WIDTH(9)) MUL28(.mul_in(shift_reg_out[27]), .coefficient(-9'd1),.mul_out(mul_sum[28]));
	multiplier_9b #(.WIDTH(9)) MUL29(.mul_in(shift_reg_out[28]), .coefficient(9'd0),.mul_out(mul_sum[29]));
	multiplier_9b #(.WIDTH(9)) MUL30(.mul_in(shift_reg_out[29]), .coefficient(9'd1),.mul_out(mul_sum[30]));
	multiplier_9b #(.WIDTH(9)) MUL31(.mul_in(shift_reg_out[30]), .coefficient(-9'd1),.mul_out(mul_sum[31]));
	multiplier_9b #(.WIDTH(9)) MUL32(.mul_in(shift_reg_out[31]), .coefficient(9'd0),.mul_out(mul_sum[32]));
	
	always_comb begin : accumulate_sum
		acc_sum = mul_sum[0] + mul_sum[1] + mul_sum[2] + mul_sum[3] + mul_sum[4] + 
		mul_sum[5] + mul_sum[6] + mul_sum[7] + mul_sum[8] + mul_sum[9] + 
		mul_sum[10] + mul_sum[11] + mul_sum[12] + mul_sum[13] + mul_sum[14] + 
		mul_sum[15] + mul_sum[16] + mul_sum[17] + mul_sum[18] + mul_sum[19] + 
		mul_sum[20] + mul_sum[21] + mul_sum[22] + mul_sum[23] + mul_sum[24] + 
		mul_sum[25] + mul_sum[26] + mul_sum[27] + mul_sum[28] + mul_sum[29] + 
		mul_sum[30] + mul_sum[31] + mul_sum[32];  
	end

	logic signed [15:0] trunc_frac_sum;
	assign trunc_frac_sum = acc_sum[23:8];

	always_ff @( posedge clk or posedge rst) begin : out_sum
		if(rst) begin
			filter_out <=0;
		end
		else if(trunc_frac_sum[15] == 0) begin
			filter_out <= {1'b0, trunc_frac_sum[7:0]};
		end
		else begin
			filter_out <= {1'b1, trunc_frac_sum[7:0]};
		end
	end

endmodule



module multiplier_9b #(
	parameter WIDTH = 9
)(
	input logic signed [WIDTH-1:0] mul_in,
	input logic signed [WIDTH-1:0] coefficient,

	output logic signed [2*WIDTH-1:0] mul_out
);
	

	assign mul_out = mul_in * coefficient;

endmodule