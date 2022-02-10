`timescale 1ns / 100ps
//////////////////////////////////////////////////////////////////////////////////
//
//  Filename: tb_debounce.v
//
//  Author: Mike Wirthlin
//  
//  Description: 
//
//  Version 1.1
//
//  Change Log:
//   
//////////////////////////////////////////////////////////////////////////////////

module tb_debounce();

	reg clk, tb_noisy;
    wire tb_debounced;
    localparam MIN_WAIT_NS =  5000000;    // 10 ns = 500,000 clock cycles
    localparam MAX_WAIT_NS =  6000000;    // 10 ns = 600,000 clock cycles

	integer i, j, errors, max_error;
	time noisy_tt = 0; // noisy transition time
	time noisy_delay;

    reg reset;
	
	// Instance the DUT
    debounce debounce(.clk(clk), .noisy(tb_noisy), .debounced(tb_debounced), .reset(reset));

	// Oscilating clock
	initial begin
		#100 // wait 100 ns before starting clock (after inputs have settled)
		clk = 0;
		forever begin
			#5  clk = ~clk;
		end
	end	

// Things to do in testbench:
// - Make sure that a pulse is properly passed (if long enough)
// - Make sure that a pulse is properly filtered (if not long enough)
// - Make sure there are no extraneous pulses
	
	initial begin

        //shall print %t with scaled in ns (-9), with 2 precision digits, and would print the " ns" string
        $timeformat(-9, 0, " ns", 20);

		tb_noisy = 0;
        errors = 0;
        max_error = 0;

        @(negedge clk);
        @(negedge clk);
        reset = 1;
        @(negedge clk);
        reset = 0;
        @(negedge clk);
        
        // Each iteration will create a zero to one transition and then a one to zero transition
        // of a noisy button.
        
        // Wait a random number of clocks 
        repeat (1000) @ (negedge clk);
        for (i=0;i<4;i=i+1) begin
    		// Give a short "high" pulse
            tb_noisy = 1'b1;
            for (j=0;j<4;j=j+1) begin
                // wait for some clocks
                repeat ($urandom%(2000)) @ (negedge clk);                
                tb_noisy = 1'b0;
                repeat ($urandom%(2000)) @ (negedge clk);                
                tb_noisy = 1'b1;
            end
            repeat (2*MAX_WAIT_NS/10) @ (negedge clk);                
            tb_noisy = 1'b0;
            for (j=0;j<4;j=j+1) begin
                // wait for some clocks
                repeat ($urandom%(2000)) @ (negedge clk);                
                tb_noisy = 1'b1;
                repeat ($urandom%(2000)) @ (negedge clk);                
                tb_noisy = 1'b0;
            end
            repeat (2*MAX_WAIT_NS/10) @ (negedge clk);                            
        end
		
		
        repeat (MAX_WAIT_NS/10) @ (negedge clk);
                		
		$display("*** Simulation done with %0d errors at time %0t ***", errors, $time);
		$finish;

	end  // end initial begin

    // Identify the last time that the noisy has transitioned
	initial begin
		forever begin
		  @(posedge tb_noisy or negedge tb_noisy);
          noisy_tt = $time;
        end
    end

    // check to see if debounce signal is too short
    always@(negedge tb_debounced or posedge tb_debounced) begin
        max_error = 0;
        noisy_delay = $time-noisy_tt;   // the amount of time since the last noisy transition
         if ($time > 0 && noisy_delay < MIN_WAIT_NS  ) begin
            $display("*** Error: debounced signal has changed too soon (%0t delay) from noisy transition at time %0t ***",
                noisy_delay, $time);
             errors = errors + 1;
         end
    end
        
    // check that the debounce signal isn't waiting too long to transition
    always@(posedge clk) begin
        if (tb_noisy != tb_debounced) begin
            noisy_delay = $time-noisy_tt;   // the amount of time since the last noisy transition
            if (noisy_delay >= MAX_WAIT_NS && max_error == 0) begin
                max_error = 1;
        		$display("*** Error: debounced signal has not changed after %0t delay from noisy transition at time %0t ***",
        		  noisy_delay, $time);
             errors = errors + 1;
        	end
        end else begin
            // check to see if the 
        end
    end
	
endmodule