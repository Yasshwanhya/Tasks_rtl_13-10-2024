
module Mac_TB();
   
   
     parameter int_a=6;
     parameter frac_a=8;
     parameter int_b=4;
     parameter frac_b=7;
     parameter dwa = int_a+frac_a;
		 parameter dwb = int_b+frac_b;
		 parameter out_int =  (int_a>=int_b)?(2*int_a):(2*int_b);    
		 parameter out_frac = (frac_a>=frac_b)?(2*frac_a):(2*frac_b) ;  
					
		 reg clock;
     reg rstn;
     reg signed [int_a+frac_a-1:0]a_data;
     reg a_valid;
     //reg a_ready;
     reg a_last;
     reg signed [int_b+frac_b-1:0]b_data;
     reg b_valid;
     //reg b_ready; 
     reg b_last;
     reg mac_axi_ready;
     wire signed [int_a+frac_a+int_b+frac_b-1:0]mac_axi_product;
     wire mac_axi_valid;
     wire mac_axi_last; 
          
     MAC_final#( int_a, frac_a, int_b, frac_b, dwa,dwb )taskcheck(
                          .clock(clock),
                          .rstn(rstn),
                          .a_data(a_data),
                          .a_valid(a_valid),
                          //.a_ready(a_ready),
                          .a_last(a_last),
                          .b_data(b_data),
                          .b_valid(b_valid),
                         //// .b_ready(b_ready),
                          .b_last(b_last),
                          .mac_axi_ready(mac_axi_ready),
                          .mac_axi_product(mac_axi_product),
                          .mac_axi_valid(mac_axi_valid),
                          .mac_axi_last(mac_axi_last)                   
                         );
           
           initial
           begin
               clock = 0;
               forever #10 clock = ~clock;
            end
            
            initial
            begin
               rstn = 0;
               #25;
               rstn = 1;
            end
            
            
            task a_write (input [1:0]state);
            begin
                
                case(state)
                   2'b00: begin
                                   repeat(1000)
                                   begin
                                        @(posedge clock) a_data = 14'b00001000000000 ;
                                        a_valid  = 1'b1;
                                        mac_axi_ready = 1'b1;
                                        a_last = 1'b0;
                                   end
                               end
                   2'b01:begin
                                   repeat(1000)
                                   begin
                                        //@(posedge clock) a_data = a_data+14'b00000100100000 ;
                                        a_valid  = 1'b1;
                                        mac_axi_ready = 1'b1;
                                        repeat(9)
                                        begin 
                                            @(posedge clock) a_data = a_data+14'b00000100100000 ;
                                            a_last = 1'b0;
                                        end
                                        a_last = 1'b1;
                                   end
                               end
                   2'b10:begin
                                   repeat(1000)
                                   begin
                                        ///@(posedge clock) a_data = a_data+14'b00010001100000 ;
                                        a_valid  = 1'b1;
                                        mac_axi_ready = 1'b1;
                                        repeat(7)
                                         begin 
                                            @(posedge clock) a_data = a_data+14'b00010001100000 ;
                                            a_last = 1'b0;
                                        end
                                        a_last = 1'b1;
                                   end
                               end
                    2'b11:begin
                                   repeat(1000)
                                   begin
                                       // @(posedge clock) a_data = a_data+14'b0000011100000 ;
                                        a_valid  = 1'b1;
                                        mac_axi_ready = 1'b1;
                                        repeat(7)@(posedge clock)
                                         begin 
                                            @(posedge clock) a_data = a_data+14'b0000011100000 ;
                                            a_last = 1'b0;
                                        end
                                        a_last = 1'b1;
                                   end
                               end
                     default:begin
                                      a_data = 14'd0;
                                      a_valid = 1'b0;
                                      mac_axi_ready = 1'b0;
                                      a_last = 1'b0; 
                                  end
                endcase
            end
            endtask    
            
            
            
            task b_write (input [1:0]state);
            begin
                
                case(state)
                   2'b00:begin
                                   repeat(1000)
                                   begin
                                        //@(posedge clock) b_data = b_data+12'b000001111000 ;
                                        b_valid  = 1'b1;
                                       mac_axi_ready = 1'b1;
                                        repeat(9)
                                        begin 
                                            @(posedge clock) b_data = b_data+12'b000001111000 ;
                                            b_last = 1'b0;
                                        end
                                        b_last = 1'b1;
                                   end
                               end
                   2'b01: begin
                                   repeat(1000)
                                   begin
                                        @(posedge clock) b_data = 12'b000010000000 ;
                                        b_valid  = 1'b1;
                                      mac_axi_ready = 1'b1;
                                        b_last = 1'b0;
                                   end
                               end
                    2'b10:begin
                                   repeat(1000)
                                   begin
                                        //@(posedge clock) b_data = b_data+12'b010001100000 ;
                                        b_valid  = 1'b1;
                                    mac_axi_ready = 1'b1;
                                        repeat(7)
                                        begin 
                                            @(posedge clock) b_data = b_data+12'b010001100000 ;
                                            b_last = 1'b0;
                                        end
                                        b_last = 1'b1;
                                   end
                               end
                    2'b11:begin
                                   repeat(1000)
                                   begin
                                        //@(posedge clock) b_data = b_data+12'b00000111000 ;
                                        b_valid  = 1'b1;
                                 mac_axi_ready = 1'b1;
                                        repeat(8)
                                        begin 
                                            @(posedge clock) b_data = b_data+12'b00000111000 ;
                                            b_last = 1'b0;
                                        end
                                        repeat(2)b_last = 1'b1;
                                   end
                               end
                     default:begin
                                      b_data = 14'd0;
                                      b_valid = 1'b0;
                                      mac_axi_ready = 1'b0;
                                      b_last = 1'b0; 
                                  end
                endcase
            end
            endtask    
            
            
            initial 
            begin      
            a_data=0;
            b_data=0;
            a_valid=0;
            b_valid=0;
            mac_axi_ready = 1'b0;
            a_last=0;
            b_last=0;
               a_write(2'b00);
               b_write(2'b00);
               #10;
               a_write(2'b01);
               b_write(2'b01);
               #10;
               a_write(2'b10);
               b_write(2'b10);
               #10;
               a_write(2'b11);
               b_write(2'b11);
            end           

           
            
            
endmodule
