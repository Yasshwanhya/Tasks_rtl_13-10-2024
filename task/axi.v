
module axi#(
                                    parameter dw = 8
                              )
                             (
                                    input clk,
                                    input rstn,
                                    
                                    input [dw-1:0]s_tdata,
                                    input s_tvalid,
                                    output reg s_tready,
                                    input s_tlast,
                                    
                                    output reg [dw-1:0]m_tdata,
                                    output reg m_tvalid,
                                    input m_tready,
                                    output reg m_tlast
                              );
                              
                 reg [dw-1:0]data_reg;
                 reg valid, ready, last;
                 wire ready1;
                 //**************** ALWAYS_BLOCK_ONE ****************//
                 //   data and control signals controlled registering
                 assign ready1 = m_tready;
                 always @(posedge clk)
                 begin
                        if(!rstn)
                        begin
                                data_reg <= 0;
                                valid <= 0;
                                ready <= 0;
                                last <= 0;
                        end
                        else
                        begin
                                if (s_tvalid)
                                begin
                                        ready <= ready1;
                                        if (ready)
                                        begin
                                            valid <= s_tvalid;
                                            last <= s_tlast;
                                        end
                                        if(s_tvalid && m_tready)
                                            data_reg <= s_tdata;
                                        else
                                            data_reg <= data_reg;                     
                                            
                                end
                                else
                                begin
                                    data_reg <= data_reg;
                                    valid <= 0;
                                    ready <= 0;
                                    last <= 0;
                                end
                        end
                 end
                 
                 
                  //**************** ALWAYS_BLOCK_TWO ****************//
                 //   controlled transfer of registered data and control signals 
                 
                 always @(posedge clk)
                 begin
                        if(!rstn)
                        begin
                                m_tdata  <= 0;
                                m_tvalid <= 0;
                                s_tready  <= 0;
                                m_tlast   <= 0;
                        end
                        else
                        begin
                                if( valid && ready )
                                begin
                                        m_tdata  <= data_reg;
                                        m_tvalid <= valid;
                                        s_tready  <= ready;
                                        m_tlast   <= last;
                                end
                                else if( valid && !ready )
                                begin
                                        m_tdata  <= m_tdata;
                                        m_tvalid <= 1'b1;
                                        s_tready  <= 1'b0;
                                        m_tlast   <= 1'b0;                                
                                end
                                else
                                begin
                                        m_tdata  <= m_tdata;
                                        m_tvalid <= 0;
                                        s_tready  <= 0;
                                        m_tlast   <= 0;                                
                                end     
                        end
                 end
                 
                 
                 
endmodule
