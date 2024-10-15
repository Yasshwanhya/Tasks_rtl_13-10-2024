module fp_add#(
    parameter int1=4,
    parameter frac1=5,
    parameter int2=3,
    parameter frac2=5,
    parameter out_int=(int1>=int2)?(2*int1):(2*int2), 
    parameter out_frac=(frac1>frac2)?frac1:frac2
  )
  (
       input clk,
       input rst,
       input signed [int1+frac1-1:0]a,
       input signed [int2+frac2-1:0]b,
       output reg overflow,
       output  reg signed [out_int+out_frac-1:0]sum
  );
 
 
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
 reg signed [int_max+frac_max:0]temp_sum;
 reg [out_int-1:0]temp_sumi;
 reg [out_frac-1:0]temp_sumf;
 wire signed [3:0] max_int ;
 reg [out_int-1:0]out_i;
 reg [out_frac-1:0]out_f;

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
  temp_bi={{(int1-int2){bi[int2-1]}},bi};
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
   temp_ai={{(int2-int1){ai[int1-1]}},ai};
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
  

 
always@(posedge clk)
begin
     if(rst==0)
     begin
          temp_sum <= 0;
          out_i<=0;
          out_f<=0;
          overflow=0;
          underflow=0;
     end
     else     
     begin
          temp_sum = temp_a+temp_b;
          temp_sumi = temp_sum[int_max+frac_max:frac_max];
          temp_sumf = temp_sum[frac_max:0];
     end
     
     if(out_int>int_max)
        overflow=0;
     else if(temp_sum[int_max+frac_max]==0)
        overflow=|temp_sum[int_max+frac_max:(int_max+frac_max-(int_max-(out_int-1)))];
     else if(out_int==int_max)
        overflow=(temp_a[int_max+frac_max-1]^temp_sum[int_max+frac_max-1]) &&
                 (temp_b[int_max+frac_max-1]^temp_sum[int_max+frac_max-1]); 
     else if(temp_sum[int_max+frac_max]==1)
        overflow=(~(&temp_sum[int_max+frac_max:frac_max+out_int-1]));
     else
        overflow=0;  
end

always@(posedge clk) begin
    out_f <= temp_sumf[frac_max-1:frac_max-out_frac];
    if(overflow)begin
        if(temp_sum[int_max+frac_max] == 0) begin
            out_i <= {temp_sum[int_max+frac_max],{(out_int-1){1'b1}}};
        end
        else if( temp_sum[int_max+frac_max] == 1) begin
           out_i <= {temp_sum[int_max+frac_max],{(out_int-1){1'b0}}};
        end
     end
     else begin
        out_i <= temp_sumi[out_int-1:0];
     end
     out <= {out_i,out_f};
end
    

endmodule
