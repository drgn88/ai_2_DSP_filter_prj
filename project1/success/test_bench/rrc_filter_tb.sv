`timescale 1ns / 1ps

module rrc_filter_tb;

    // Parameters
    localparam WIDTH = 9;
    localparam CLK_PERIOD = 10; // 10 ns for 100 MHz clock

    // Testbench signals
    logic clk;
    logic rst;
    logic signed [WIDTH-1:0] filter_in;
    logic signed [WIDTH-1:0] filter_out;

    // File I/O
    integer infile;
    integer outfile;
    integer scan_result;
    integer input_value;

    // Instantiate the Unit Under Test (UUT)
    rrc_filter #(
        .WIDTH(WIDTH)
    ) uut (
        .clk(clk),
        .rst(rst),
        .filter_in(filter_in),
        .filter_out(filter_out)
    );

    // Clock generation
    always begin
        clk = 1'b0;
        #(CLK_PERIOD / 2);
        clk = 1'b1;
        #(CLK_PERIOD / 2);
    end

    // Test sequence
    initial begin
        // Open input file
        infile = $fopen("ofdm_i_adc_serial_out_fixed_30dB.txt", "r");
        if (infile == 0) begin
            $display("Error: Could not open ofdm_i_adc_serial_out_fixed_30dB.txt"); // Corrected filename in error message
            $finish;
        end

        // Open output file
        outfile = $fopen("rrc_filter_out.txt", "w");
        if (outfile == 0) begin
            $display("Error: Could not open rrc_filter_out.txt");
            $fclose(infile);
            $finish;
        end

        // Initialize signals
        rst = 1'b1;
        filter_in = 0;
        #(CLK_PERIOD * 2); // Hold reset for a few clock cycles

        rst = 1'b0;
        #(CLK_PERIOD); // Wait one clock cycle after releasing reset

        $display("Starting RRC filter simulation...");
        $display("-----------------------------------");
        $display("Time (ns) | Input | Output");
        $display("-----------------------------------");

        // Read inputs from file and apply to filter
        while (!$feof(infile)) begin
            scan_result = $fscanf(infile, "%d", input_value);
            if (scan_result == 1) begin
                filter_in = input_value;
                #(CLK_PERIOD); // Wait one clock cycle for the filter to process
                $fwrite(outfile, "%d\n", filter_out); // Write output to file
                // Display filter_out to console as signed decimal
                $display("%0t | %d | %d", $time, filter_in, filter_out);
            end else if ($feof(infile)) begin
                // Reached end of file
                break;
            end else begin
                $display("Error: Invalid input format in ofdm_i_adc_serial_out_fixed_30dB.txt"); // Corrected filename in error message
                $fclose(infile);
                $fclose(outfile);
                $finish;
            end
        end

        $display("-----------------------------------");
        $display("Simulation finished. Output written to rrc_filter_out.txt");

        // Close files
        $fclose(infile);
        $fclose(outfile);

        $finish; // End simulation
    end

endmodule
