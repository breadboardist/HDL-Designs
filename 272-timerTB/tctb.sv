////////////////////////////////////////////////////
//Testbench for 8-bit timer/counter0 of ATMega328 //
////////////////////////////////////////////////////
`timescale 1ns/10ps
//////////////////////////
//Interface Declaration //
//////////////////////////
interface tci;

  logic clk;
  logic rst;
  logic write;
  logic [7:0] addr;
  logic [7:0] wdata;
  logic read;
  logic [7:0] rdata;
  logic t0;
  logic oca_data,ocb_data;
  logic interrupt_request;
  logic status_reg_interrupt_enable;
  logic interrupt_executed;

  modport tc(input clk, input rst, input write, input addr,
             input wdata, input read, output rdata,input t0,output oca_data,
             output ocb_data,input status_reg_interrupt_enable,
             output interrupt_request,input interrupt_executed);

endinterface

////////////////
//Test Module //
////////////////
module top();

  reg debug=1;

  reg test1_running=0;
  reg test2_running=0;
  reg test3_running=0;
  reg test4_running=0;
  reg test5_running=0;
  reg test6_running=0;
  reg test7_running=0;
  reg test8_running=0;
  reg test9_running=0;
  reg test10_running=0;
  reg test11_running=0;
  reg test12_running=0;
  reg test13_running=0;
  int death;

  tci ai();

  default clocking defclk @(posedge(ai.clk));
  endclocking

  const reg [7:0] A_tccra=8'h24;
  const reg [7:0] A_tccra1=8'h44;
  const reg [7:0] A_tccrb=8'h25;
  const reg [7:0] A_tccrb1=8'h45;
  const reg [7:0] A_ocra=8'h27;
  const reg [7:0] A_ocra1=8'h47;
  const reg [7:0] A_ocrb=8'h28;
  const reg [7:0] A_ocrb1=8'h48;
  const reg [7:0] A_tcnt=8'h26;
  const reg [7:0] A_tcnt1=8'h46;
  const reg [7:0] A_timsk=8'h6e;
  const reg [7:0] A_tifr=8'h15;
  const reg [7:0] A_tifr1=8'h35;

  int div=8;

  string test="none";

  tc t(ai);

  initial begin
    ai.clk=0;
    forever #5 ai.clk = ~ai.clk;
  end

  initial begin
    if(debug) begin
      $dumpfile("tc.vcd");
      $dumpvars(9,top);
    end
  end

  /////////////////////////////////
  //Tasks required for testbench //
  /////////////////////////////////
  task die(input string str);
    begin
        $display();
        $display();
        $display("%s: %s",test,str);
        $display();
        $display();
        $error("Try again after fixing things");
        #10;
        $finish();
      end
  endtask

  task wreg(input [7:0] addr, input [7:0] datax);
    begin
        ai.addr = addr;
        ai.wdata = datax;
        ai.write=1;
        ##1 #1;
        ai.write=0;
        ai.addr=0;
        ai.wdata=0;
      end
  endtask

  task rreg(input [7:0] addr, input [7:0] datax);
    begin
        ai.addr = addr;
        ai.read=1;
        ##1 #1;
        if(ai.rdata !== datax) begin
          $display("Error reading address %h --- got %h, expected %h",
            addr,
            ai.rdata,
            datax);
          die("Register read error");
        end
    end
  endtask

  task easyplay();
    begin
        wreg(A_ocra,8'h05);
        wreg(A_ocrb,8'h77);
        wreg(A_tccra,8'h2);
        wreg(A_tccrb,8'h2);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h07);
        rreg(A_ocra,8'h05);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h2);
        rreg(A_ocra1,8'h5);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h2);
        rreg(A_tifr,06);
        rreg(A_timsk,7);
        rreg(A_tifr1,06);
        rreg(A_ocrb,8'h77);
        rreg(A_ocrb1,8'h77);
        ai.status_reg_interrupt_enable=1;
      end
  endtask

  task test1(input string tname);
    begin
        test=tname;
        easyplay();
        // Check the basic counting
        ai.addr=A_tcnt;
        ai.read=1;
        ##10 #1;
        test1_running=1;
        ##1000 #1;
        test1_running=0;
        ##480 #1;
        ai.read=0;
      end
  endtask

  task test2(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h15);
        wreg(A_ocrb,8'h77);
        wreg(A_tccra1,8'h2);
        wreg(A_tccrb1,8'h2);
        rreg(A_ocra,8'h15);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h2);
        rreg(A_ocra1,8'h15);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h2);
        rreg(A_ocrb,8'h77);
        rreg(A_ocrb1,8'h77);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h07);
        ai.addr=A_tcnt1;
        ai.read=1;
        ##10 #1;
        test2_running=1;
        ##4000 #1;
        test2_running=0;
        ##1480 #1;
        ai.read=0;

      end
  endtask

  task test3(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h18);
        wreg(A_ocrb,8'h16);
        wreg(A_tccra1,8'h2);
        wreg(A_tccrb1,8'h2);
        rreg(A_ocra,8'h18);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h2);
        rreg(A_ocra1,8'h18);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h2);
        rreg(A_ocrb,8'h16);
        rreg(A_ocrb1,8'h16);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h02);
        ai.addr=A_tcnt;
        ai.read=1;
        ##10 #1;
        test3_running=1;
        ##4000 #1;
        test3_running=0;
        ##1480 #1;
        ai.read=0;

      end
  endtask

  task test4(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h18);
        wreg(A_ocrb,8'h16);
        wreg(A_tccra1,8'h2);
        wreg(A_tccrb1,8'h2);
        rreg(A_ocra,8'h18);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h2);
        rreg(A_ocra1,8'h18);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h2);
        rreg(A_ocrb,8'h16);
        rreg(A_ocrb1,8'h16);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h04);
        ai.addr=A_tcnt;
        ai.read=1;
        ##10 #1;
        test4_running=1;
        ##4000 #1;
        test4_running=0;
        ##1480 #1;
        ai.read=0;

      end
  endtask

  task test5(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h18);
        wreg(A_ocrb,8'h16);
        wreg(A_tccra1,8'h2);
        wreg(A_tccrb1,8'h2);
        rreg(A_ocra,8'h18);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h2);
        rreg(A_ocra1,8'h18);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h2);
        rreg(A_ocrb,8'h16);
        rreg(A_ocrb1,8'h16);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h07);
        ai.addr=A_tcnt;
        ai.read=1;
        ##10 #1;
        test5_running=1;
        ##4000 #1;
        test5_running=0;
        ##1480 #1;
        ai.read=0;

      end
  endtask

  task test6(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h18);
        wreg(A_ocrb,8'h16);
        wreg(A_tccra1,8'h2);
        wreg(A_tccrb1,8'h3);
        rreg(A_ocra,8'h18);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h3);
        rreg(A_ocra1,8'h18);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h3);
        rreg(A_ocrb,8'h16);
        rreg(A_ocrb1,8'h16);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h07);
        wreg(A_tcnt,8'h00);
        ai.status_reg_interrupt_enable=1;
        ai.addr=A_tcnt;
        ai.read=1;
        ##10 #1;
        test6_running=1;
        ##4000 #1;
        test6_running=0;
        ##1480 #1;
        ai.read=0;

      end
  endtask

  task test7(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h18);
        wreg(A_ocrb,8'h16);
        wreg(A_tccra1,8'h2);
        wreg(A_tccrb1,8'h4);
        rreg(A_ocra,8'h18);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h4);
        rreg(A_ocra1,8'h18);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h4);
        rreg(A_ocrb,8'h16);
        rreg(A_ocrb1,8'h16);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h07);
        wreg(A_tcnt,8'h00);
        ai.addr=A_tcnt;
        ai.read=1;
        ##10 #1;
        test7_running=1;
        ##4000 #1;
        test7_running=0;
        ##1480 #1;
        ai.read=0;

      end
  endtask

  task test8(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h18);
        wreg(A_ocrb,8'h16);
        wreg(A_tccra1,8'h2);
        wreg(A_tccrb1,8'h5);
        rreg(A_ocra,8'h18);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h5);
        rreg(A_ocra1,8'h18);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h5);
        rreg(A_ocrb,8'h16);
        rreg(A_ocrb1,8'h16);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h07);
        wreg(A_tcnt,8'h00);
        ai.status_reg_interrupt_enable=1;
        ai.addr=A_tcnt;
        ai.read=1;
        ##10 #1;
        test8_running=1;
        ##5000 #1;
        test8_running=0;
        ##2480 #1;
        ai.read=0;

      end
  endtask

  task test9(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h18);
        wreg(A_ocrb,8'h16);
        wreg(A_tccra1,8'h2);
        wreg(A_tccrb1,8'h6);
        rreg(A_ocra,8'h18);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h6);
        rreg(A_ocra1,8'h18);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h6);
        rreg(A_ocrb,8'h16);
        rreg(A_ocrb1,8'h16);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h07);
        wreg(A_tcnt,8'h00);
        ai.status_reg_interrupt_enable=1;
        ai.addr=A_tcnt;
        ai.read=1;
        ##10 #1;
        ##10 ai.t0=1;
        ##10 ai.t0=0;
        ##10 ai.t0=1;
        ##10 ai.t0=0;
        ##10 ai.t0=1;
        ##10 ai.t0=0;
        ##10 ai.t0=1;
        ##10 ai.t0=0;
        ##10 ; 
        if (ai.rdata!=8'h4) begin
                            die("Wrong negative edge counting"); 
                          end
        ##10 #1; 
        ai.read=0;
        ##10 #1; 
    end
  endtask

  task test10(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h18);
        wreg(A_ocrb,8'h16);
        wreg(A_tccra1,8'h2);
        wreg(A_tccrb1,8'h7);
        rreg(A_ocra,8'h18);
        rreg(A_tccra,8'h2);
        rreg(A_tccrb,8'h7);
        rreg(A_ocra1,8'h18);
        rreg(A_tccra1,8'h2);
        rreg(A_tccrb1,8'h7);
        rreg(A_ocrb,8'h16);
        rreg(A_ocrb1,8'h16);
        wreg(A_tifr,8'h07);
        wreg(A_timsk,8'h07);
        wreg(A_tcnt1,8'h00);
        ai.status_reg_interrupt_enable=1;
        ai.addr=A_tcnt;
        ai.read=1;
        ##10 #1;
        ##10 ai.t0=0;
        ##10 ai.t0=1;
        ##10 ai.t0=0;
        ##10 ai.t0=1;
        ##10 ai.t0=0;
        ##10 ai.t0=1;
        ##10 ai.t0=0;
        ##10 ai.t0=1;
        ##10 ; 
        if (ai.rdata!=8'h4) begin
                              die("Wrong positive edge counting"); 
                            end
      ##10 #1; 
      ai.read=0;
      ##10 #1; 
    end
  endtask

  task test11(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h19);
        rreg(A_ocra,8'h19);
        rreg(A_ocra1,8'h19);
        wreg(A_tccrb1,8'h8);
        rreg(A_tccrb1,8'h8);
        wreg(A_tccra,8'h0);
        wreg(A_tccrb,8'h1);
        wreg(A_tcnt1, 8'h00);
        wreg(A_tcnt, 8'h00);
        ai.status_reg_interrupt_enable=1;
        ai.addr=A_tcnt;
        ai.read=1;
        test11_running=1;
        ##4000 #1;
        test11_running=0;
        ##1480 #1;
        ai.read=0;
      end
  endtask

  task test12(input string tname);
    begin
        test=tname;
        wreg(A_tccrb1,8'h9);
        rreg(A_tccrb1,8'h9);
        wreg(A_tccra,8'h1);
        wreg(A_tccrb,8'h1);
        wreg(A_tcnt1,8'h00);
        wreg(A_tcnt,8'h00);
        ai.status_reg_interrupt_enable=1;
        ai.addr=A_tcnt;
        ai.read=1;
        test12_running=1;
        ##400 #1;
        test12_running=0;
        ##148 #1;
        ai.read=0;
      end
  endtask

  task test13(input string tname);
    begin
        test=tname;
        wreg(A_ocra1,8'h20);
        rreg(A_ocra,8'h20);
        rreg(A_ocra1,8'h20);
        wreg(A_tccrb1,8'h9);
        rreg(A_tccrb1,8'h9);
        wreg(A_tccra,8'h1);
        wreg(A_tccrb,8'h1);
        wreg(A_tcnt1,8'h00);
        wreg(A_tcnt,8'h00);
        ai.status_reg_interrupt_enable=1;
        ai.addr=A_tifr;
        ai.read=1;
        test13_running=1;
        ##100 #1;
        test13_running=0;
        ##48 #1;
        ai.read=0;
      end
  endtask

  //////////////////
  //Run all tests //
  //////////////////
  initial begin
    ai.write=0;
    ai.read=0;
    ai.addr=8'h12;
    ai.wdata=8'h34;
    ai.rst = 0;
    ai.status_reg_interrupt_enable=1;
    ai.interrupt_executed=1;
    ##1 #1;
    ai.rst = 1;
    ##5 #1;
    ai.rst = 0;
    test1("test1");
    test2("test2");
    test3("test3");
    test4("test4");
    test5("test5");
    test6("test6");
    test7("test7");
    test8("test8");
    test9("test9");
    test10("test10");
    test11("test11");
    test12("test12");
    test13("test13");
    ##200;
    $finish;

  end


  always @(posedge(ai.clk)) begin
    if(1'b1) begin
      if(ai.interrupt_request) begin
        repeat($random&7) ##1;
        ##1 #1 ai.interrupt_executed=1;
      end else begin
               ai.interrupt_executed=#1 0;
      end
    end
  end

  ////////////////////////////////////
  //Sequences for use in assertions //
  ////////////////////////////////////
  sequence seq1;
  test1_running==1 && $rose(ai.rdata==0);
  endsequence
  
  sequence seq11;
  test1_running==1 && $rose(ai.rdata==4);
  endsequence

  sequence seq2;
  test2_running==1 && $rose(ai.rdata==0);
  endsequence

  sequence seq21;
  test2_running==1 && $rose(ai.rdata==15);
  endsequence

  sequence seq3;
  test3_running==1 && $rose(ai.rdata==0);
  endsequence
  
  sequence seq31;
  test3_running==1 && $rose(ai.rdata==15);
  endsequence

  sequence seq4;
  test4_running==1 && $rose(ai.rdata==0);
  endsequence
  
  sequence seq41;
  test4_running==1 && $rose(ai.rdata==15);
  endsequence

  sequence seq5;
  test5_running==1 && $rose(ai.rdata==0);
  endsequence

  sequence seq51;
  test5_running==1 && $rose(ai.rdata==15);
  endsequence
  
  sequence seq6;
  test6_running==1 && $rose(ai.rdata==0);
  endsequence

  sequence seq61;
  test6_running==1 && $rose(ai.rdata==15);
  endsequence

  sequence seq7;
  test7_running==1 && $rose(ai.rdata==0);
  endsequence

  sequence seq71;
  test7_running==1 && $rose(ai.rdata==8);
  endsequence

  sequence seq8;
  test8_running==1 && $rose(ai.rdata==0);
  endsequence

  sequence seq81;
  test8_running==1 && $rose(ai.rdata==15);
  endsequence

  /////////////////////////////////
  //Multi-line assert statements //
  /////////////////////////////////
  assert property( test8_running |=> ##[1:(1024*256)] ai.interrupt_request)
                    else die("No interrupt seen (ocra) ");

  assert property( test8_running && $rose(ai.interrupt_request) |->
                    ##[1:(1024*128)] $rose(ai.interrupt_request)) else die("Wrong interrupt rate");

  assert property( test1_running |=> ##[1:256] ai.interrupt_request)
                    else die("No interrupt seen (ocra) ");

  assert property( test1_running && $rose(ai.interrupt_request) |->
                    ##48 $rose(ai.interrupt_request)) else die("Wrong interrupt rate");

  assert property( test2_running |-> ##[1:(22*8)] ai.rdata==5 ##8 ai.rdata==6)
                    else die("Not counting right");
 
  assert property( test2_running && $rose(ai.interrupt_request) |->
                    ##(22*8) $rose(ai.interrupt_request)) else die("Wrong interrupt rate");

  assert property( test3_running |-> ##[1:(25*8)] ai.rdata==5 ##8 ai.rdata==6)
                    else die("Not counting right");
  
  assert property( test3_running && $rose(ai.interrupt_request) |->
                    ##(25*8) $rose(ai.interrupt_request)) else die("Wrong interrupt rate");

  assert property( test4_running |-> ##[1:(25*8)] ai.rdata==5 ##8 ai.rdata==6)
                    else die("Not counting right");
  
  assert property( test4_running && $rose(ai.interrupt_request) |->
                    ##(25*8) $rose(ai.interrupt_request)) else die("Wrong interrupt rate");

  assert property( test5_running |-> ##[1:(25*8)] ai.rdata==5 ##8 ai.rdata==6)
                    else die("Not counting right");
  
  assert property( test5_running && $rose(ai.interrupt_request) |->
                    (##(16) $rose(ai.interrupt_request) or
                     ##(23*8) $rose(ai.interrupt_request))) 
                     else die("Wrong interrupt sequence");

  assert property( test6_running |=> ##[1:(64*32)] ai.interrupt_request)
                    else die("No interrupt seen (ocra) ");

  assert property( test6_running && $rose(ai.interrupt_request) |->
                    ##[1:(64*32)] $rose(ai.interrupt_request)) else die("Wrong interrupt rate");

  assert property( test7_running |=> ##[1:(256*64)] ai.interrupt_request)
                    else die("No interrupt seen (ocra) ");

  assert property( test7_running && $rose(ai.interrupt_request) |->
                    ##[1:(64*32)] $rose(ai.interrupt_request)) else die("Wrong interrupt rate");

  //////////////////////////////////
  //Single line assert statements //
  //////////////////////////////////
  assert property( seq5 |-> ( ##(8*25) ai.rdata==0)) else die("Didn't cycle to zero");
  assert property( seq5 |-> ( ##(8*3) ai.rdata== 3)) else die("Didn't get 3");
  assert property( seq51 |->  ##8 ai.rdata==16 ##8 ai.rdata==17) else die("Inc error");
  assert property( seq4 |-> ( ##(8*25) ai.rdata==0)) else die("Didn't cycle to zero");
  assert property( seq4 |-> ( ##(8*3) ai.rdata== 3)) else die("Didn't get 3");
  assert property( seq41 |->  ##8 ai.rdata==16 ##8 ai.rdata==17) else die("Inc error");
  assert property( seq3 |-> ( ##(8*25) ai.rdata==0)) else die("Didn't cycle to zero");
  assert property( seq3 |-> ( ##(8*3) ai.rdata== 3)) else die("Didn't get 3");
  assert property( seq31 |->  ##8 ai.rdata==16 ##8 ai.rdata==17) else die("Inc error");
  assert property( seq2 |-> ( ##(8*22) ai.rdata==0)) else die("Didn't cycle to zero");
  assert property( seq2 |-> ( ##(8*3) ai.rdata== 3)) else die("Didn't get 3");
  assert property( seq21 |->  ##8 ai.rdata==16 ##8 ai.rdata==17) else die("Inc error");
  assert property( test1_running |=> ##[1:256] ai.rdata==2 ##8 ai.rdata==3) else die("Not counting right");
  assert property( seq1 |-> (##48 ai.rdata==0)) else die("didn't cycle in 48 clocks");
  assert property( seq1 |-> (##8 ai.rdata==1)) else die("Didn't increment in 8 cycles");
  assert property( seq11 |-> ##8 ai.rdata==5 ##8 ai.rdata==0) else die("Didn't wrap right");
  assert property( seq7 |-> (##(64) ai.rdata==1)) else die("didn't cycle in 48 clocks");
  assert property( seq7 |-> (##(64) ai.rdata==0)) else die("Didn't increment in 8 cycles");
  assert property( seq71 |-> ##256 ai.rdata==9 ##256 ai.rdata==10) else die("Didn't wrap right");
  assert property( test6_running |=> ##[1:(64*32)] ai.rdata==2 ##64 ai.rdata==3) else die("Not counting right");
  assert property( seq6 |-> (##64 ai.rdata==1)) else die("Didn't increment in 8 cycles");
  assert property( seq61 |-> ##64 ai.rdata==16 ##64 ai.rdata==17) else die("Didn't wrap right");
  assert property( test8_running |=> ##[1:(1024*128)] ai.rdata==2 ##1024 ai.rdata==3) else die("Not counting right");
  assert property( seq8 |-> (##1024 ai.rdata==0)) else die("didn't cycle in 48 clocks");
  assert property( seq8 |-> (##1024 ai.rdata==1)) else die("Didn't increment in 8 cycles");
  assert property( seq81 |-> ##1024 ai.rdata==16 ##1024 ai.rdata==17) else die("Didn't wrap right");
  assert property( test11_running && $rose(ai.rdata == 0) |-> ##256 ai.rdata==0 ) else die("Not counting right");
  assert property( test11_running && $rose(ai.rdata == 0) |-> ##256 ai.interrupt_request==1 ) else die("Not counting right");
  assert property( test12_running && $rose(ai.rdata == 8'hff)|=> ##255 ai.rdata==1) else die("Not counting right");
  assert property( test13_running && $rose(ai.rdata[1]) && $rose(ai.rdata[2]) |=> ( ai.rdata[2] != ai.rdata[1]) ) else die("Not counting right");

endmodule
