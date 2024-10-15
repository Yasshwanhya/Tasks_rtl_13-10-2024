


module axi_MAC #( 
		parameter int_a=6,
		parameter frac_a=8,
		parameter int_b=6,
		parameter frac_b=8,
		parameter out_int = (int_a>=int_b)?(2*int_a):(2*int_b),   
		parameter out_frac = (frac_a>=frac_b)?(2*frac_a):(2*frac_b)   
		)
  		(
		input clock,
		input rstn,
						 
		//Input signals
		input signed [int_a+frac_a-1:0]a,
		input signed [int_b+frac_b-1:0]b,
		input valid_i,
		input ready_i,
		input last_i,
						 
		 //Output signals
		output reg signed [out_int+out_frac-1:0]product_out,
		output reg ready_o,
		output reg valid_o,
		output reg last_o
	);
		
		//intermediate registers
		reg signed [out_int+out_frac-1:0]store_ab,acc ;
		reg valid,last,ready;
		
		//State logics
		/*
		      The state considerations are 
				state-1 RESET    - when reset is activated,
			                      store_a,acc is loaded with zero
				state-2 MACstate - when valid_i and ready_i are high
										 a*b is to be done and stored to store_ab
										 then acc is loaded as 
										 acc <= acc+store_ab;
				state-3 OUTPUT   - when valid_i, ready_i a,d last_i are high
								       and output <= acc;	*/	 

	wire signed [out_frac+out_int-1:0]product,pdt,accc;

fp_mul #(int_a , frac_a , int_b , frac_b , out_int , out_frac )
mult(clock,rstn,a,b,product);
	fp_add #(int_a , frac_a , int_b , frac_b , out_int , out_frac ) addt(clock,rstn,pdt,accc,product);
		//************** Multiply-Accumulate Logic **************//
		always @(posedge clock or negedge rstn) 
		begin
        if (!rstn) 
		    begin
			   // Reset logic      
				acc <= 0;      
				store_ab <= 0;
			 end 
			 else if (valid_i && ready_i) 
			 begin
   		   // Perform the multiplication and accumulate
				store_ab <= pdt;      
				acc <= accc ;
				valid <= valid_i;
				ready<=ready_i;
				last <= 1'b0;
			 end
		end
		
		//********** Output Logic and State Management **********//
		always @(posedge clock or negedge rstn) 
		begin    
		  if (!rstn) 
		    begin      
			   // Reset the output and control signals
				product_out <= 0;
				valid_o <= 1'b0;
				ready_o<=1'b0;
				last_o <= 1'b0;    
			 end 
		  else 
		    begin      
			   if (valid_i && ready_i && last_i) 
				  begin
   			    // Output the accumulated value when last_i is high
					 product_out <= acc;
					 valid_o <= valid;  // Signal that the output is valid
					 ready_o<=ready;
					 last_o <= last;   // Indicate it's the last output
				  end 
				else 
				  begin 
				  product_out <= product_out;
				  valid_o <= 0;
				  ready_o<=0;
				  last_o <= 0;
				  end
	 		 end
		end

endmodule
		
						

