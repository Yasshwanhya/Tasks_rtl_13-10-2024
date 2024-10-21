module fp_mul
#(   
       parameter int1=6,
       parameter frac1=8,
       parameter int2=6,
       parameter frac2=8,
       
             ) (
                     input clk,
                     input reset,
                     input signed [int1+frac1-1:0]a,
                     input signed [int2+frac2-1:0]b,
                     output  reg signed [out_int+out_frac-1:0]product
               );
localparam out_int=int1+int2;
localparam out_frac=frac1+frac2;
localparam int_max=(int1>=int2)?int1:int2;
localparam frac_max=(frac1>=frac2)?frac1:frac2;

 reg [int1-1:0]ai;
 reg [int_max-1:0]temp_ai;
 reg [frac1-1:0]af;
 reg [frac_max-1:0]temp_af;
 reg [int2-1:0]bi;
 reg [int_max-1:0]temp_bi;
 reg [frac2-1:0]bf;
 reg [frac_max-1:0]temp_bf;
 reg signed [int_max+frac_max-1:0]temp_a;
 reg signed [int_max+frac_max-1:0]temp_b;
       



always@(*)
 begin
 ai=a[int1+frac1-1:frac1];
 af=a[frac1-1:0];
 bi=b[int2+frac2-1:frac2];
 bf=b[frac2-1:0];
 end
 
 always@(posedge clk)
 begin
 
 if(int1==int2 && frac1==frac2)
 begin
    temp_ai=ai;
    temp_bi=bi;
    temp_af=af;
    temp_bf=bf;
 end
 else if(int1>int2 )
 begin
  temp_ai=ai;
  temp_bi={bi[int2-1],{(int1-int2){1'b0}},bi[int2-2:0]};
  if(frac1>=frac2)
  begin
    temp_af=af;
    temp_bf={bf,{(frac1-frac2){1'b0}}};
  end
  else if(frac2>frac1)
  begin  
    temp_bf=bf;
    temp_af={af,{(frac2-frac1){1'b0}}};
  end
 end
 else if(int2>int1)
   begin
   temp_bi=bi;
   temp_ai={ai[int1-1],{(int2-int1){1'b0}},ai[int1-2:0]};
    if(frac1>frac2)
    begin
      temp_af=af;
      temp_bf={bf,{(frac1-frac2){1'b0}}};
    end
    else if(frac2>frac1)
    begin  
      temp_bf=bf;
      temp_af={af,{(frac2-frac1){1'b0}}};
    end
   end
end

always @(*)
begin
   temp_a={temp_ai,temp_af};
   temp_b={temp_bi,temp_bf};
end
  

 

always@(posedge clk) begin
     if(reset) begin
        product_temp <= 'd0;
        product_temp_i <= 'd0;
        product_temp_f <= 'd0;
        
     end
     else begin
       product_temp = temp_a*temp_b;
      
     end
     
endmodule
