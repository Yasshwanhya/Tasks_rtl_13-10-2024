
module axi #(
             parameter dw = 8
				 )
				 (
				   input clock,
					input resetn,
					
					//Slave interface
					input [dw-1:0]s_tdata,
					input s_tvalid,
					output reg s_tready,
					input s_tlast,
					
					//Master interface
					output reg [dw-1:0]m_tdata,
					output reg m_tvalid,
					input m_tready,
					output reg m_tlast
				 );
				 
				 reg [dw-1:0]register;
				 reg valid,ready,last;
				 
				 always @(posedge clock)
				 begin
				   if(!resetn)
					begin
					  register <= 8'd0;
					  valid <= 1'b0;
					  ready <= 1'b0;
					  
					end
					else
					begin
					  if (s_tvalid && m_tready)
					  begin
					    register <= s_tdata;
					    valid <= 1'b1;
					    ready <= 1'b1;
					
					  end
					  else if (s_tvalid && !m_tready)
					  begin
					    register <= s_tdata;
					    valid <= 1'b1;
					    ready <= 1'b0;
					   
					  end
					  else
					  begin
					    register <= 8'd0;
					    valid <= 1'b0;
					    ready <= 1'b0;
					    
					  end
				   end
			    end
				 
				 
				 always @(posedge clock)
				 begin
				   if(!resetn)
					begin
					  m_tdata <= 8'd0;
					  m_tvalid <= 1'b0;
					  s_tready <= 1'b0;
					  m_tlast <= 1'b0;
					end
					else
					begin
					  if(s_tvalid && m_tready)
					  begin
					    m_tdata <= register;
					    m_tvalid <= valid;
					    s_tready <= ready;
					    m_tlast <= s_tlast;
					  end
					  else
					  begin
    				    m_tdata <= 8'd0;
					    m_tvalid <= 1'b0;
					    s_tready <= 1'b0;
					    m_tlast <= 1'b0;
					  end
					end
				 end
				 
endmodule
		

