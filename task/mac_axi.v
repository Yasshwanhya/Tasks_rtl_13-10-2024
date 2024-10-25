

module mac_axi#(
                                parameter  intA = 3,   
                                           fracA = 5, 
                                           intB = 4,          
                                           fracB = 6,         
                                           outint = 4,
                                           outfrac = 12,
                                           bitadd = 10 
                            ) 
                            (
                                input clk,
                                input rstn,
                     
                                //A channel
                                input signed [ (intA+fracA)-1 :0]a_tdata,
                                input a_tvalid,
                                output reg a_ready,
                                input a_tlast,
                                
                                //B channel
                                input signed [ (intB+fracB)-1 :0]b_tdata,
                                input b_tvalid,
                                output reg b_ready,
                                input b_tlast,
                                
                                //Mac output channel
                                output signed [ (outint + outfrac)-1 :0]mac_axi_tdata,
                                output mac_axi_tvalid,
                                input mac_axi_tready,
                                output mac_axi_tlast,
                                
                                input of_sat_flag,
                                input uf_sat_flag,
                                
                                output overflow,
                                output underflow                    
                            );


            localparam acc_int =  intA+intB ;
            localparam acc_frac =  fracA+fracB ; 
            
            reg [1:0]current_state,next_state;
            localparam IDLE=2'd0, 
                               MULT_ACC=2'd1,
                               OUTPUT=2'd2;

            reg valid,ready,last;
            reg final_last;  
            reg signed [acc_int+acc_frac-1:0]product,pdt_reg;
            reg signed [acc_int+acc_frac+bitadd-1:0]data;  
            reg signed [acc_int+acc_frac+bitadd-1:0]accumulate;  
            wire signed [acc_int+acc_frac+bitadd-1:0]accum; 
            wire of,uf;
            reg signed [ (intA+fracA)-1 :0]a;
            reg signed [ (intB+fracB)-1 :0]b;
            
            bit_adjust#(acc_int+bitadd, acc_frac, outint, outfrac) test1
                               (
                                    .clk(clk),
                                    .resetn(rstn),
                                    .data_in(data),
                                    .final_Data(mac_axi_tdata),
                                    .acc_manp(accum),
                                    .of_flag(of_sat_flag),
                                    .uf_flag(uf_sat_flag),
                                    .overflow(of),
                                    .underflow(uf)
                                );
    
      
            always@(posedge clk) 
            begin
                if(!rstn) current_state <= IDLE;
                else current_state <= next_state;
            end


            always@(*)
            begin
                case(current_state)
                    IDLE: begin
                                    if(!rstn)  next_state <= IDLE ;
                                    else  next_state <= MULT_ACC;
                             end
            
                    MULT_ACC:  begin
                                            if(last) next_state <= OUTPUT;
                                            else 
                                            begin
                                                if(!rstn) next_state <= IDLE;
                                                else next_state <= MULT_ACC;
                                            end
                                         end
            
                    OUTPUT: begin  
                                        if(mac_axi_tready) 
                                        begin
                                            if(!rstn) next_state <= IDLE;
                                            else if(last) next_state <= OUTPUT;
                                            else next_state <= MULT_ACC;
                                        end 
                                        else 
                                        begin
                                            next_state <= OUTPUT;
                                        end
                                    end
                        
                    default: begin
                                    next_state <=IDLE;
                                  end
                endcase
            end
            
            
            always@(posedge clk) 
            begin 
                if(!rstn)
                begin
                    a <= 'b0;
                    b <= 'b0;
                end
                else 
                begin
                    a <= (a_tvalid && a_ready ) ? a_tdata : a;
                    b <= (b_tvalid && b_ready ) ? b_tdata : b;
                end
            end

            always@(posedge clk) 
            begin
                if(!rstn)  last <= 'd0; 
                else  last <= a_tlast || b_tlast;
            end
            
            always@(*) 
            begin
                if(!rstn)    
                begin
                    valid <= 'd0;
                    pdt_reg<='d0;
		        end
		        else 
		        begin 
		            valid <= a_tvalid & b_tvalid;
		            pdt_reg <= (mac_axi_tready)? 'd0: ((last)? product:pdt_reg);
		        end
		    end 
		    
		    always @(posedge clk)
		    begin
		          if(!rstn) 
		          begin
		              a_ready <= 'd0;
		              b_ready <= 'd0;
		              ready <= 'd0;
		          end
		          else
		          begin
		              case(current_state)
		                  MULT_ACC: begin
		                                          ready<= 'd1;
		                                          a_ready<= ready && b_tvalid;
		                                          b_ready<= ready && a_tvalid;
		                                      end
		                  default: ready<='d0;
		              endcase
		          end
		    end
		    
		                
            always@(posedge clk) 
            begin
                if(!rstn) 
                begin
                    product <= 'd0;
                    data <= 'd0;
                    accumulate <= 'd0;
                end
                else 
                begin     
                    case(next_state)
                        IDLE:begin
                                   accumulate <= accumulate;
                                   product <=product;
                                end
                        MULT_ACC: begin
                                               if(valid && ready) 
                                               begin
                                                    product <= a  * b ;
                                                    accumulate <= accumulate + product; 
                                               end
                                               else 
                                               begin
                                                    product <= product;
                                                    accumulate <= accumulate ;
                                               end
                                            end
                        OUTPUT :   begin
                                               product <= 'd0;
                                               data <= accumulate+pdt_reg;
                                               accumulate <= (mac_axi_tready) ?'d0 :accumulate; ; 
                                           end
                    endcase
                end
            end
            
            
            assign mac_axi_tvalid = (current_state == OUTPUT ? 1'd1 :1'd0);
            assign overflow = of;
            assign underflow = uf;
            assign mac_axi_tlast = (mac_axi_tready && mac_axi_tvalid) ? ((current_state == OUTPUT)? 'd1: 'd0): 'd0;

endmodule



