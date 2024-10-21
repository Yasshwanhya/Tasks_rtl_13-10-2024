
module MAC_final#( 
                        parameter int_a=6,
			parameter frac_a=8,
			parameter int_b=6,
			parameter frac_b=8,
			parameter dwa = int_a+frac_a,
			parameter dwb = int_b+frac_b,
			parameter out_int = (int_a>=int_b)?(2*int_a):(2*int_b),    
			parameter out_frac = (frac_a>=frac_b)?(2*frac_a):(2*frac_b)
		 )(
                          input clock,
                          input rstn,
                                  
                          //data_a
                           input signed [int_a+frac_a-1:0]a_data,
                           input a_valid,
                           //input a_ready,
                           input a_last,
                           
                           //data_b
                           input signed [int_b+frac_b-1:0]b_data,
                           input b_valid,
                           //input b_ready,
                           input b_last,
                           
                           //MAC_AXI
                           input mac_axi_ready,
                           output signed [int_a+frac_a+int_b+frac_b-1:0]mac_axi_product,
                           output mac_axi_valid,
                           output mac_axi_last                   
                         );
                         
          //internal connections declaration
          //************** data_a **************//               
          wire  [int_a+frac_a-1:0]data_a;
          wire valid_a;
          wire ready_a;
          wire last_a;
          
          //************** data_b **************//               
          wire [int_b+frac_b-1:0]data_b;
          wire valid_b;
          wire ready_b;
          wire last_b;
          
          //************ MAC AXI *************// 
          reg valid_mac_axi, ready_mac_axi, last_mac_axi;     
          
          //*********** axi for data A***********//     
           axi #(dwa) adata (
				   .clock(clock),
					.resetn(rstn),
					.s_tdata(a_data),
					.s_tvalid(a_valid),
					.s_tready(ready_a),
					.s_tlast(a_last),
					.m_tdata(data_a),
					.m_tvalid(valid_a),
					.m_tready(mac_axi_ready),
					.m_tlast(last_a)
				 );
			
			
			//*********** axi for data B***********//     
           axi #(dwb) bdata (
				   .clock(clock),
					.resetn(rstn),
					.s_tdata(b_data),
					.s_tvalid(b_valid),
					.s_tready(ready_b),
					.s_tlast(b_last),
					.m_tdata(data_b),
					.m_tvalid(valid_b),
					.m_tready(mac_axi_ready),
					.m_tlast(last_b)
				 );	    
                               
               //***********mac axi data***********//           
               always @(posedge clock)
               begin
                   if(!rstn)
                   begin 
                       valid_mac_axi<=0;
                       ready_mac_axi<=0;
                       last_mac_axi<=0; 
                   end
                   else
                   begin
                       if(valid_a && valid_b && ready_a && ready_b)
                       begin
                          valid_mac_axi<=valid_a&&valid_b;
                          ready_mac_axi<=ready_a&&ready_b;
                          last_mac_axi<=last_a||last_b; 
                       end
                       else
                       begin
                           valid_mac_axi<=0;
                           ready_mac_axi<=0;
                           last_mac_axi<=0; 
                       end
                    end
               end   
               
                      
                 //************* mac axi *************//      
                 axi_MAC #(  int_a, frac_a, int_b,  frac_b,out_int,out_frac ) final_dut
					 (
					    .clock(clock),
						 .rstn(rstn),
						 .a(data_a),
						 .b(data_b),
						 .valid_i(valid_mac_axi),
						 .ready_i(ready_mac_axi),
						 .last_i(last_mac_axi),
						 .product_out(mac_axi_product),
						 .valid_o(mac_axi_valid),
						 .last_o(mac_axi_last)
					 );
		
                 
                 
                     
                        
endmodule
