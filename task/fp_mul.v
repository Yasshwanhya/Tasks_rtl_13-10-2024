module fp_mul
#(   
       parameter int1=6,
       parameter frac1=8,
       parameter int2=6,
       parameter frac2=8,
       parameter out_int=6,
       parameter out_frac=12
             ) (
                     input clk,
                     input reset,
                     input signed [int1+frac1-1:0]a,
                     input signed [int2+frac2-1:0]b,
                     output  reg signed [out_int+out_frac-1:0]product
               );
 
localparam int_max=(int1>=int2)?int1:int2;
localparam frac_max=(frac1>=frac2)?frac1:frac2;
reg overflow, underflow;
reg [int_max+frac_max:0]product_temp;
reg [int_max:0]product_temp_i;
reg [frac_max-1:0]product_temp_f;

reg [out_int-1:0]product_i;
reg [out_frac-1:0]product_f;

always@(posedge clk) begin
     if(reset) begin
        product_temp <= 'd0;
        product_temp_i <= 'd0;
        product_temp_f <= 'd0;
        overflow <= 'd0;
        underflow <= 'd0;
     end
     else begin
       product_temp = a*b;
       product_temp_i = product_temp[int_max+frac_max:frac_max];
       product_temp_f = product_temp[frac_max:0];
     end
     if(out_frac>int_max)
     underflow = |product_temp_f[out_frac-frac_max-1:0];
     else if(out_frac<int_max)
     underflow = |product_temp_f[frac_max-out_frac-1:0];
     else
     underflow = |product_temp_f[out_frac-1:0];
     if(out_frac>int_max)
        overflow=0;
     else if(product_temp[int_max+frac_max]==0)
        overflow=|product_temp[int_max+frac_max:(int_max+frac_max-(int_max-(out_int-1)))];
     else if(product_temp[int_max+frac_max]==1)
        overflow=(~(&product_temp[int_max+frac_max:frac_max+out_int-1]));
     else
        overflow=0;  
end

always@(posedge clk) begin
   // product_f <= product_temp_f[frac_max-1:frac_max-out_frac];
    product_f <= product_temp_f[frac_max-1:frac_max-out_frac];
    if(overflow)begin
        if(product_temp[int_max+frac_max] == 0) begin
            product_i <= {product_temp[int_max+frac_max],{(out_int-1){1'b1}}};
        end
        else if( product_temp[int_max+frac_max] == 1) begin
            product_i <= {product_temp[int_max+frac_max],{(out_int-1){1'b0}}};
        end
     end
     else begin
        product_i <= product_temp_i[out_int-1:0];
     end
     product <= {product_i,product_f};
end

endmodule
