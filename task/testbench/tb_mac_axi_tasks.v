

module tb_mac_axi_tasks();

            parameter  intA = 4;           
        parameter fracA = 14;      
        parameter intB =3;         
        parameter fracB = 13;         
        parameter outint = 6;
        parameter outfrac = 28;
        localparam num_a = 6;
        localparam num_b = 4;
        localparam num_o = 40;
        localparam num_final = (num_a >= num_b) ? num_a : num_b ;
        parameter bitadd = $clog2(num_final)+1;
        reg clk;
        reg rstn;
        
        reg signed [ (intA+fracA)-1 :0]a_tdata;
        reg a_tvalid;
        wire a_ready;
        reg a_tlast;
        
        reg signed [ (intB+fracB)-1 :0]b_tdata;
        reg b_tvalid;
        wire b_ready;
        reg b_tlast;
        
        wire signed [ (outint + outfrac)-1 :0]mac_axi_tdata;
        wire mac_axi_tvalid;
        reg mac_axi_tready;
        wire mac_axi_tlast;
        
        reg of_sat_flag;
        reg uf_sat_flag;
        
        wire overflow;
        wire underflow;
        
        mac_axi#( intA, fracA, intB, fracB, outint, outfrac, bitadd ) 
                 dut (
                           .clk(clk),
                           .rstn(rstn),
                           .a_tdata(a_tdata),
                           .a_tvalid(a_tvalid),
                           .a_ready(a_ready),
                           .a_tlast(a_tlast),
                           .b_tdata(b_tdata),
                           .b_tvalid(b_tvalid),
                           .b_ready(b_ready),
                           .b_tlast(b_tlast),
                           .mac_axi_tdata(mac_axi_tdata),
                           .mac_axi_tvalid(mac_axi_tvalid),
                           .mac_axi_tready(mac_axi_tready),
                           .mac_axi_tlast(mac_axi_tlast),
                           .of_sat_flag(of_sat_flag),
                           .uf_sat_flag(uf_sat_flag),
                           .overflow(overflow),
                           .underflow(underflow)                    
                            );
            initial 
            begin
                clk = 0;
                forever #5 clk = ~clk;
            end
            
            //task reset
            task reset_op(input fin_num);
            integer i;
            begin
                for(i=1;i<fin_num;i=i+1)
                begin
                    rstn = 1;
                end
               
            end
            endtask
            
            //task A-input drive
            task a_input_drive(
                                          input a_num,
                                          input [1:0]acase,
                                          input signed [intA+fracA-1:0]data,
                                          input integer throttle
                                       );
                integer i,j;
                integer var;
                reg [intA+fracA-1:0]cdata;
                begin
                    
                    a_tvalid = 'd1;
                    case(acase)
                        2'd1: cdata = data;
                        2'd2: cdata = data+'d1;
                        2'd3: cdata = $random;
                        default: cdata = data;
                    endcase
                    var = $urandom%throttle;
                    for(i=1;i<a_num;i=i+1)
                    begin
                        #10;
                        while(!a_ready)
                        begin
                            #30;
                        end
                        for(j=1;j==var;j=j+1)
                        begin
                            a_tdata = (a_tvalid)?cdata:a_tdata;
                            a_tvalid = (j%var  == 0) ? ~a_tvalid: a_tvalid;
                        end
                    end
                    a_tlast = 'd1;
                    #20;
                    a_tlast = 'd0;
                    a_tdata = 'd0;
                    a_tvalid = 'd0;
                end
            endtask
            
            //task B-input drive
            task b_input_drive(
                                          input b_num,
                                          input [1:0]bcase,
                                          input signed [intB+fracB-1:0]data,
                                          input integer throttle
                                       );
                integer i,j;
                integer var;
                reg [intA+fracA-1:0]cdata;
                begin
                    
                    a_tvalid = 'd1;
                    case(bcase)
                        2'd1: cdata = data+'d1;
                        2'd2: cdata = data;
                        2'd3: cdata = $random;
                        default: cdata = data;
                    endcase
                    var = $urandom%throttle;
                    for(i=1;i<b_num;i=i+1)
                    begin
                        #10;
                        while(!b_ready)
                        begin
                            #30;
                        end
                        for(j=1;j==var;j=j+1)
                        begin
                            b_tdata = (b_tvalid)?cdata:b_tdata;
                            b_tvalid = (j%var  == 0) ? ~b_tvalid: b_tvalid;
                        end
                    end
                    b_tlast = 'd1;
                    #20;
                    b_tlast = 'd0;
                    b_tdata = 'd0;
                    b_tvalid = 'd0;
                end
            endtask
            
            //output drive
            task output_drive(input o_num);
                begin: start
                    integer i;
                    @(posedge clk);
                    for ( i= 0; i<o_num;i=i+1)
                    begin
                        #20;
                        mac_axi_tready = (i==o_num-1)?1'd1:1'd0;
                    end
                    #20;
                    mac_axi_tready = 'd0;
                end
            endtask
            
            //Stimulus
            initial 
            begin
                // Initialize signals    
                //rstn = 0;
                a_tdata = 0;
                a_tvalid = 0;
                a_tlast = 0;
                b_tdata = 0;
                b_tvalid = 0;
                b_tlast = 0;
                mac_axi_tready = 0;
                of_sat_flag = 0;
                uf_sat_flag = 0;
            end
            
            //task calling
            initial
            begin
                reset_op(num_final);
                #20;
                //case-1 a_data constant, b_data varied
                repeat(4) @(posedge clk);
                fork
                    a_input_drive(num_a,2'd1,18'b0110_1000_0000_0000_00,0);
                    b_input_drive(num_b,2'd1,16'b001_1100_0000_0000_0,0);
                    output_drive(num_o);
                join
                a_tdata = 18'b0001_0000_0000_0000_00;
                b_tdata = 16'b001_0000_0000_0000_0;
                
                //case-2 a_data varied, b_data constant
                repeat(6) @(posedge clk);
                fork
                    a_input_drive(num_a,2'd2,18'b0110_1010_0000_0000_00,0);
                    b_input_drive(num_b,2'd2,16'b001_1000_0000_0000_0,0);
                    output_drive(num_o);
                join
                a_tdata = 18'b0001_0000_0000_0000_00;
                b_tdata = 16'b001_0000_0000_0000_0;
                
                //case-3 a_data varied, b_data varied
                repeat(6) @(posedge clk);
                fork
                    a_input_drive(num_a,2'd3,18'b0110_1000_0000_1100_00,0);
                    b_input_drive(num_b,2'd3,16'b001_1000_0110_0000_0,0);
                    output_drive(num_o);
                join
                a_tdata = 18'b0001_0000_0000_0000_00;
                b_tdata = 16'b001_0000_0000_0000_0;
                
                //case-4 a_data varied, b_data varied, throttle assigned to a_tvalid
                repeat(6) @(posedge clk);
                fork
                    a_input_drive(num_a,2'd3,18'b0110_1000_0000_1100_00,10);
                    b_input_drive(num_b,2'd3,16'b001_1000_0110_0000_0,0);
                    output_drive(num_o);
                join
                a_tdata = 18'b0001_0000_0000_0000_00;
                b_tdata = 16'b001_0000_0000_0000_0;
                
                //case-5 a_data varied, b_data varied, throttle assigned to b_tvalid
                repeat(6) @(posedge clk);
                fork
                    a_input_drive(num_a,2'd3,18'b0110_1000_0000_1100_00,0);
                    b_input_drive(num_b,2'd3,16'b001_1000_0110_0000_0,10);
                    output_drive(num_o);
                join
                a_tdata = 18'b0001_0000_0000_0000_00;
                b_tdata = 16'b001_0000_0000_0000_0;
                
                //case-6 a_data varied, b_data varied, throttle assigned to both b_tvalid & a_tvalid
                repeat(6) @(posedge clk);
                fork
                    a_input_drive(num_a,2'd3,18'b0110_1000_0000_1100_00,10);
                    b_input_drive(num_b,2'd3,16'b001_1000_0110_0000_0,10);
                    output_drive(num_o);
                join
                a_tdata = 18'b0001_0000_0000_0000_00;
                b_tdata = 16'b001_0000_0000_0000_0;
                
                
            end
            
endmodule
