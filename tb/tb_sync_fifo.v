`timescale 1ns/1ps

module tb_sync_fifo;

    parameter DATA_WIDTH = 8;
    parameter DEPTH = 16;

    reg clk = 0;
    reg rst = 1;
    reg wr_en = 0;
    reg rd_en = 0;
    reg [DATA_WIDTH-1:0] data_in = 0;

    wire [DATA_WIDTH-1:0] data_out;
    wire full, empty, almost_full, almost_empty;

    integer errors = 0;
    integer i;

    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) DUT (
        .clk(clk),
        .rst(rst),
        .wr_en(wr_en),
        .rd_en(rd_en),
        .data_in(data_in),
        .data_out(data_out),
        .full(full),
        .empty(empty),
        .almost_full(almost_full),
        .almost_empty(almost_empty)
    );

    always #5 clk = ~clk;

    task write_data(input [7:0] data);
    begin
        @(negedge clk);
        wr_en = 1;
        rd_en = 0;
        data_in = data;
        @(negedge clk);
        wr_en = 0;
    end
    endtask

    task read_check(input [7:0] expected);
    begin
        @(negedge clk);
        rd_en = 1;
        wr_en = 0;
        @(posedge clk);
        #1;
        if (data_out !== expected) begin
            $display("FAIL: Expected %h, got %h", expected, data_out);
            errors = errors + 1;
        end
        else
            $display("PASS: Read %h", data_out);

        @(negedge clk);
        rd_en = 0;
    end
    endtask

    task simultaneous(input [7:0] new_data,
                      input [7:0] expected);
    begin
        @(negedge clk);
        wr_en = 1;
        rd_en = 1;
        data_in = new_data;

        @(posedge clk);
        #1;

        if (data_out !== expected) begin
            $display("FAIL: Simultaneous read expected %h got %h",
                     expected, data_out);
            errors = errors + 1;
        end
        else
            $display("PASS: Simultaneous read %h", data_out);

        @(negedge clk);
        wr_en = 0;
        rd_en = 0;
    end
    endtask

    initial begin
        $dumpfile("simulation/fifo.vcd");
        $dumpvars(0, tb_sync_fifo);

        repeat (2) @(negedge clk);
        rst = 0;

        // TEST 1: Reset flags
        if (empty && !full && almost_empty)
            $display("PASS: Reset flags");
        else begin
            $display("FAIL: Reset flags");
            errors = errors + 1;
        end

        // TEST 2: Basic write/read
        write_data(8'hA5);
        read_check(8'hA5);

        // TEST 3: Almost-full flag
        for (i = 0; i < DEPTH-1; i = i+1)
            write_data(i);

        if (almost_full)
            $display("PASS: Almost full");
        else begin
            $display("FAIL: Almost full");
            errors = errors + 1;
        end

        // TEST 4: Full flag
        write_data(8'hF0);

        if (full)
            $display("PASS: Full flag");
        else begin
            $display("FAIL: Full flag");
            errors = errors + 1;
        end

        // TEST 5: Simultaneous read/write at full
        simultaneous(8'hAA, 8'h00);

        // TEST 6: Drain remaining FIFO data
        for (i = 1; i < DEPTH-1; i = i+1)
            read_check(i);

        read_check(8'hF0);
        read_check(8'hAA);

        // TEST 7: Empty flag
        if (empty)
            $display("PASS: Empty flag");
        else begin
            $display("FAIL: Empty flag");
            errors = errors + 1;
        end

	// TEST 8: Pointer wrap-around

	// Fill FIFO
	for (i = 0; i < DEPTH; i = i+1)
    	write_data(i);

	// Read first 8 entries
	for (i = 0; i < 8; i = i+1)
   	 read_check(i);

	// Write 8 more entries.
	// Write pointer must wrap around.
	for (i = 16; i < 24; i = i+1)
   	    write_data(i);

	// Read remaining 16 entries in FIFO order
	for (i = 8; i < 24; i = i+1)
    	read_check(i);

        // TEST 9: Simultaneous operation in partially filled FIFO
        write_data(8'h31);
        write_data(8'h32);
        simultaneous(8'h33, 8'h31);
        read_check(8'h32);
        read_check(8'h33);

	// TEST 10: Simultaneous read/write when FIFO is empty

	// Ensure FIFO is empty
	if (!empty) begin
    	$display("FAIL: FIFO should be empty before TEST 10");
    	errors = errors + 1;
	end

	@(negedge clk);
	wr_en = 1;
	rd_en = 1;
	data_in = 8'h55;

	@(posedge clk);
	#1;

	// Read must be rejected, write must be accepted
	if (empty) begin
    	$display("FAIL: Write was not accepted when FIFO was empty");
    	errors = errors + 1;
	end
	else
    	$display("PASS: Write accepted during simultaneous operation at empty");

	// Deassert both enables
	@(negedge clk);
	wr_en = 0;
	rd_en = 0;

	// Read back the written value
	read_check(8'h55);	

        if (errors == 0)
            $display("\n========== ALL TESTS PASSED ==========");
        else
            $display("\n========== %0d TESTS FAILED ==========", errors);

        $finish;
    end

endmodule
