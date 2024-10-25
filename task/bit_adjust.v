
module bit_adjust#(
                                    parameter  int = 5, 
                                                        frac = 11,      
                                                        int_o = 6,     
                                                        frac_o = 11   
                                ) 
                               (
                                    input clk,
                                    input resetn,
                                    input signed [ (int+frac)-1 :0]data_in,
                                    output signed [ (int_o+frac_o)-1 :0]final_Data,
                                    output signed [ (int+frac)-1 :0]acc_manp,
                                    input of_flag,
                                    input uf_flag,
                                    output overflow,
                                    output underflow
                                );
    

            localparam signed o_of_p_i = {1'b0,{(int_o-1){1'b1}}};
            localparam signed o_of_n_i = {1'b1,{(int_o-1){1'b0}}};
            localparam signed o_of_p_f = {{(frac_o){1'b1}}};
            localparam signed o_of_n_f = {{(frac_o-1){1'b0}},1'b1};
            localparam signed o_uf = {(frac_o){1'b1}};
            

            reg [int-1:0]data_in_i;  
            reg [frac-1:0]data_in_f; 
            reg signed [(int_o+frac_o)-1:0]data_in_temp; 
            reg signed [(int+frac)-1:0]acc_manpr; 
            reg [int_o-1:0]data_in_temp_i;
            reg [frac_o-1:0]data_in_temp_f; 
            reg OF,UF;
            
            
            always @(posedge clk) 
            begin
                if(!resetn)
                begin
                    data_in_i = 'd0;
                    data_in_f = 'd0;
                end
                else
                begin
                    data_in_i = data_in[(int+frac-1):frac];
                    data_in_f = data_in[(frac-1):0];
                end
            end
            
            always @(*)
            begin
                if(!resetn) OF <= 'd0;
                else
                begin
                    if((frac!=frac_o)&&(frac>frac_o)) UF = |data_in_f[frac-frac_o-1:0];
                    else UF = 'd0;
                end                
            end
            
            always @(*) 
            begin
                if(!resetn) OF <= 0;
                else 
                begin
                    if(int_o>int) OF <=0;
                    else if(data_in[int+frac-1]==0)   OF <=|data_in[int+frac-1: frac+int_o-1];
                    else if(data_in[int+frac-1]==1)   OF <=(~(&data_in[int+frac-1: frac+int_o-1]));
                    else   OF <=0;
                end    
            end
            
            
            
            
            always @(*) 
            begin
                if(!resetn) data_in_temp = 'd0;
                else  //data_in_temp = {data_in_temp_i,data_in_temp_f};
                begin
                    case({of_flag,overflow})
                        4'b11: begin
                                     if(data_in_i[int-1]==0) 
                                     begin
                                        data_in_temp_i =o_of_p_i ;
                                        data_in_temp_f =o_of_p_f ;
                                     end
                                     else
                                     begin
                                        data_in_temp_i =o_of_n_i ;
                                        data_in_temp_f =o_of_n_f ;
                                     end
                                   end
                        4'b10: begin
                                     if(int>int_o) 
                                     begin
                                        data_in_temp_i ={data_in_i[int-1],data_in_i[int_o-1]} ;
                                        data_in_temp_f = (underflow)?o_uf:data_in_f;
                                     end
                                     else 
                                     begin
                                        data_in_temp_i = {{(int_o-int){data_in_i[int-1]}},data_in_i};
                                        data_in_temp_f = (underflow)?o_uf:data_in_f;
                                     end
                                   end
                        default: begin
                                         data_in_temp_i = data_in_i;
                                         data_in_temp_f = data_in_f;
                                     end
                    endcase
                    case({uf_flag,underflow})
                        4'b11: begin
                                      data_in_temp_f = o_uf;
                                      data_in_temp_i = 'd0;
                                   end
                        4'b10: begin
                                     if(frac>frac_o) 
                                     begin
                                        data_in_temp_f =data_in_f[frac-1:frac-frac_o] ;
                                        if (overflow) data_in_temp_i = (data_in_i[int-1])?o_of_n_i:o_of_p_i ;
                                        else data_in_temp_i = data_in_i;
                                     end
                                     else
                                     begin
                                        data_in_temp_f = {data_in_f,{(int_o-int){1'b0}}};
                                        if (overflow) data_in_temp_i = (data_in_i[int-1])?o_of_n_i:o_of_p_i ;
                                        else data_in_temp_i = data_in_i;
                                     end
                                   end
                        default: begin
                                         data_in_temp_i = data_in_i;
                                         data_in_temp_f = data_in_f;
                                     end
                    endcase
                 end         
            end
            
            
            always @(*)
            begin
                if(!resetn) data_in_temp <= 'd0;
                else data_in_temp <= {data_in_temp_i,data_in_temp_f};
            end

            assign final_Data = data_in_temp;
            assign overflow = OF;
            assign underflow = UF;

endmodule
