`timescale 1ns/10ps
// Interface definition
interface g16_if (input sysClk, input rst);
  logic need,YouGotIt;
  logic [47:0] Adr,addrM;
  logic [15:0] dbus_in,dataOut,DinMast,DoutM;
  logic tarActive,Clast,Clast_mstr;
  modport CLKS(input sysClk,input rst);

  modport Mstr(
        input need, output YouGotIt,
        input addrM, input DoutM, output DinMast,
        output Clast_mstr
  );

  modport MstrR(
        output need, input YouGotIt,
        output addrM, output DoutM, input DinMast,
        input Clast
  );

  modport Slave(
        output Adr, output dbus_in, input dataOut,
        output tarActive, input Clast
  );

  modport SlaveR(
        input Adr, input dbus_in, output dataOut,
        input tarActive, input Clast
  );

endinterface

module tbg16();
  logic sysClk,rst;
class Master;
  logic [47:0] addrM;
  rand logic [15:0] DoutM;
  virtual g16_if intf;
  int target;
  int tpercent;
  int NumWon;
  int InXfr,InXfrNext;
  int NumXfr;
  int targetSlave;
  logic [47:0] targetAddr;
  task CheckGrant;
    begin
      InXfr = InXfrNext;
      if(!InXfr && intf.need===1 && intf.YouGotIt===1) begin
        NumWon=NumWon+1;
        intf.need=0;
        InXfrNext=1;
      end
      if(InXfr===1) NumXfr=NumXfr+1;
      if(intf.Clast===1 && InXfr) begin
        InXfrNext=0;
      end
    end
  endtask
  task startInterval;
    begin
      NumWon=0;
      InXfr=0;
      InXfrNext=0;
      NumXfr=0;
      intf.need=0;
    end
  endtask
  task pickRandomTarget;
    begin
      target = $urandom_range(13,0);
      randomize(addrM) with { addrM >= slvs[target].AddrLow && addrM <= slvs[target].AddrHigh;};
    end
  endtask
endclass

class Slave;
  rand logic [15:0] dataOut;
  virtual g16_if intf;
  logic [47:0] AddrLow;
  logic [47:0] AddrHigh;
  task setAddress(input logic [47:0] a,input logic [47:0] b);
    begin
    AddrLow=a;
    AddrHigh=b;
    end
  endtask
  task setSlaveData;
    begin
      intf.dataOut=dataOut;
    end
  endtask
  task xfrIt(input Master mst);
    int ix;
    begin
      ix=0;
      while((!intf.tarActive) && ix++ < 500) ##1;
      if(ix >= 500) begin
        die("didn't get slave enable 'tarActive'","");
      end
      repeat($urandom_range(1,5)) begin
        mst.intf.DoutM=$random;
        this.intf.dataOut=$random; 
        ##1 #1;
        if(mst.intf.addrM !== this.intf.Adr) begin
          die("Address didn't get to the slave","");
        end
        if(mst.intf.DoutM !== this.intf.dbus_in) begin
          $display("\n\nmaster %h slave %h",mst.intf.DoutM,this.intf.dbus_in);
          die("Data to slave didn't work","");
        end
        if(mst.intf.DinMast !== this.intf.dataOut) begin
          $display("\n\nmaster %h slave %h",mst.intf.DinMast,this.intf.dataOut);
          die("Data from slave didn't work","");
        end
        mst.NumXfr=mst.NumXfr+1;
      end
      intf.Clast=1;
      ##1 #1 intf.Clast=0;
      mst.InXfr=0;
      mst.InXfrNext=0;
    end
  endtask
endclass

  logic debug=0;
    logic sadness=0;
  int totaldone;
  reg allreq=0;
  Master msts[];
  Slave  slvs[];
  g16_if mif00(sysClk,rst);
  Master mc00;
  Slave msc00;
  g16_if mif01(sysClk,rst);
  Master mc01;
  Slave msc01;
  g16_if mif02(sysClk,rst);
  Master mc02;
  Slave msc02;
  g16_if mif03(sysClk,rst);
  Master mc03;
  Slave msc03;
  g16_if mif04(sysClk,rst);
  Master mc04;
  Slave msc04;
  g16_if mif05(sysClk,rst);
  Master mc05;
  Slave msc05;
  g16_if mif06(sysClk,rst);
  Master mc06;
  Slave msc06;
  g16_if sif00(sysClk,rst);
  Slave sc00;
  g16_if sif01(sysClk,rst);
  Slave sc01;
  g16_if sif02(sysClk,rst);
  Slave sc02;
  g16_if sif03(sysClk,rst);
  Slave sc03;
  g16_if sif04(sysClk,rst);
  Slave sc04;
  g16_if sif05(sysClk,rst);
  Slave sc05;
  g16_if sif06(sysClk,rst);
  Slave sc06;
  int slaveTarget=999;
  int winningMaster=999;

  default clocking cb16 @(posedge(sysClk));
  endclocking

  initial begin
    sysClk=0;
    forever #5 sysClk=~sysClk;
  end

  initial begin
    rst=0;
    msts=new[7];
    slvs=new[7+7];
    mc00=new;
    mc00.intf = mif00;
    msts[0]=mc00;
    msc00=new;
    msc00.intf = mif00;
    mc00.tpercent=21;
    msc00.intf.Clast=0;
    slvs[0]=msc00;
    msc00.setAddress(48'hffff8ddc,48'hffff8edc);
    mc01=new;
    mc01.intf = mif01;
    msts[1]=mc01;
    msc01=new;
    msc01.intf = mif01;
    mc01.tpercent=6;
    msc01.intf.Clast=0;
    slvs[1]=msc01;
    msc01.setAddress(48'hffff7015,48'hffff7085);
    mc02=new;
    mc02.intf = mif02;
    msts[2]=mc02;
    msc02=new;
    msc02.intf = mif02;
    mc02.tpercent=6;
    msc02.intf.Clast=0;
    slvs[2]=msc02;
    msc02.setAddress(48'hffff58ce,48'hffff58df);
    mc03=new;
    mc03.intf = mif03;
    msts[3]=mc03;
    msc03=new;
    msc03.intf = mif03;
    mc03.tpercent=19;
    msc03.intf.Clast=0;
    slvs[3]=msc03;
    msc03.setAddress(48'hffff3ca5,48'hffff3d61);
    mc04=new;
    mc04.intf = mif04;
    msts[4]=mc04;
    msc04=new;
    msc04.intf = mif04;
    mc04.tpercent=21;
    msc04.intf.Clast=0;
    slvs[4]=msc04;
    msc04.setAddress(48'hfffe951f,48'hfffe9553);
    mc05=new;
    mc05.intf = mif05;
    msts[5]=mc05;
    msc05=new;
    msc05.intf = mif05;
    mc05.tpercent=21;
    msc05.intf.Clast=0;
    slvs[5]=msc05;
    msc05.setAddress(48'hfffe93e5,48'hfffe93fe);
    mc06=new;
    mc06.intf = mif06;
    msts[6]=mc06;
    msc06=new;
    msc06.intf = mif06;
    mc06.tpercent=6;
    msc06.intf.Clast=0;
    slvs[6]=msc06;
    msc06.setAddress(48'hffff5342,48'hffff5374);
    sc00=new;
    sc00.intf = sif00;
    sc00.setAddress(48'hfffffc6a,48'hfffffd5a);
    sc00.intf.Clast=0;
    slvs[0+7]=sc00;
    sc01=new;
    sc01.intf = sif01;
    sc01.setAddress(48'hffff3064,48'hffff3100);
    sc01.intf.Clast=0;
    slvs[1+7]=sc01;
    sc02=new;
    sc02.intf = sif02;
    sc02.setAddress(48'hffff7d12,48'hffff7ded);
    sc02.intf.Clast=0;
    slvs[2+7]=sc02;
    sc03=new;
    sc03.intf = sif03;
    sc03.setAddress(48'hffff6513,48'hffff6554);
    sc03.intf.Clast=0;
    slvs[3+7]=sc03;
    sc04=new;
    sc04.intf = sif04;
    sc04.setAddress(48'hffff4096,48'hffff418a);
    sc04.intf.Clast=0;
    slvs[4+7]=sc04;
    sc05=new;
    sc05.intf = sif05;
    sc05.setAddress(48'hffffaac2,48'hffffab79);
    sc05.intf.Clast=0;
    slvs[5+7]=sc05;
    sc06=new;
    sc06.intf = sif06;
    sc06.setAddress(48'hffff6066,48'hffff610b);
    sc06.intf.Clast=0;
    slvs[6+7]=sc06;
    cleanInterval;
    #0.1 rst=1;
    if(debug) begin
      $dumpfile("tbg16.vpd");
      $dumpvars(9,tbg16);
    end
    ##5 #1 rst=0;
    ##2 #1; 
    cleanInterval;
    repeat(100) anInterval(0);
    stats;
    cleanInterval;
    allreq=1;
    repeat(100) anInterval(1);
    stats;
    cleanInterval;
    repeat(100) anInterval2(0);
    stats;
    if(sadness) die("You are off by more than 2 percent","");
    $display("I think it worked");
    $finish;
    ##5000 die("Ran out of time","Out of time");
    $finish;
  end

  g16Arbitrator arb(mif00.CLKS,
    mif00.Mstr,mif00.Slave, // Master 0
    mif01.Mstr,mif01.Slave, // Master 1
    mif02.Mstr,mif02.Slave, // Master 2
    mif03.Mstr,mif03.Slave, // Master 3
    mif04.Mstr,mif04.Slave, // Master 4
    mif05.Mstr,mif05.Slave, // Master 5
    mif06.Mstr,mif06.Slave, // Master 6
    sif00.Slave,	// Slave 0
    sif01.Slave,	// Slave 1
    sif02.Slave,	// Slave 2
    sif03.Slave,	// Slave 3
    sif04.Slave,	// Slave 4
    sif05.Slave,	// Slave 5
    sif06.Slave 	// Slave 6
  );

  task die(input string e0,input string em);
    begin
      $display("\n\n\n=============== Error ==============\n");
      $display(e0);
      $error(em);
      $display("\n\n\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n");
      #10 $finish;
    end
  endtask
  task cleanInterval;
    int ix;
    begin
      totaldone=0;
      for(ix=0; ix < 7; ix=ix+1) begin
        msts[ix].startInterval;
      end
    end
  endtask
  task stats;
    int iq;
    real perXfr;
    int totalXfr;
    begin
      totalXfr=0;
      for(iq=0; iq < 7; iq=iq+1) begin
        totalXfr += msts[iq].NumXfr;
      end
      if(totalXfr < 100) begin
        $display("Saw %d transfer cycles",totalXfr);
        die("Too few transfer cycles done","");
      end
      $display("\n%d Transfered",totalXfr);
      $display("\n\tMst\tSim\t\tGoal");
      for(iq=0; iq < 7; iq=iq+1) begin
        perXfr = msts[iq].NumXfr;
        perXfr = perXfr/totalXfr;
        perXfr = perXfr*100.0;
        $display("%d	%5.2f	%d	%5.2f",iq,perXfr,msts[iq].tpercent,perXfr-msts[iq].tpercent);
        if( (perXfr-msts[iq].tpercent)< -2.0) begin
          sadness=1;
          $display("You lost it on %d",iq);
        end
      end
    end
  endtask;
  function logic isBusy(input int sn);
    int ix;
    begin
      if(sn > 998) begin
        for(ix=0; ix < 7; ix=ix+1) begin
          $display("Mstr %d InXfr %b",ix,msts[ix].InXfr);
        end
      end
      for(ix=0; ix < 7; ix=ix+1) begin
//        msts[ix].CheckGrant;
        if(msts[ix].InXfr) begin
          if(sn > 998) $display("Busy Master %d",ix);
          return 1;
        end
      end
      return 0;
    end
  endfunction
  function logic isResp;
    int ix;
    begin
      for(ix=0; ix < 7; ix=ix+1) begin
        if(msts[ix].intf.need===1 && msts[ix].intf.YouGotIt===1) begin
          slaveTarget=msts[ix].targetSlave;
          winningMaster=ix;
          msts[ix].CheckGrant;
          return 1'b1;
        end
      end
      return 1'b0;
    end
  endfunction
  task setReqs;
    int ix;
    int ixp,ixnp;
    begin
      for(ix=0; ix < 7; ix=ix+1) begin
        ixp=msts[ix].tpercent;
        ixnp=100-ixp;
        if(msts[ix].intf.need===0) begin
          msts[ix].targetSlave=$urandom_range(0,13);
          msts[ix].targetAddr = pickSlaveAddr(msts[ix].targetSlave);
          msts[ix].intf.addrM = msts[ix].targetAddr;
        end
        if(allreq) msts[ix].intf.need=1;
        else if(msts[ix].intf.need==0) randcase
          ixp: begin
            msts[ix].intf.need=1;
            msts[ix].targetSlave=$urandom_range(0,13);
            msts[ix].targetAddr = pickSlaveAddr(msts[ix].targetSlave);
            msts[ix].intf.addrM = msts[ix].targetAddr;
          end
          ixnp: msts[ix].intf.need=0;
        endcase
      end
    end
  endtask
  task setReqs2;
    int ix;
    int ixp,ixnp;
    begin
      for(ix=0; ix < 7; ix=ix+1) begin
        ixp=msts[ix].tpercent;
        ixnp=100-ixp;
        if(msts[ix].intf.need===0) begin
          msts[ix].targetSlave=$urandom_range(0,13);
          msts[ix].targetAddr = pickSlaveAddr(msts[ix].targetSlave);
          msts[ix].intf.addrM = msts[ix].targetAddr;
        end
        if((ix%1)==0) msts[ix].intf.need=1;
        else if(msts[ix].intf.need==0) randcase
          ixp+2: begin
            msts[ix].intf.need=1;
            msts[ix].targetSlave=$urandom_range(0,13);
            msts[ix].targetAddr = pickSlaveAddr(msts[ix].targetSlave);
            msts[ix].intf.addrM = msts[ix].targetAddr;
          end
          ixnp-2: msts[ix].intf.need=0;
        endcase
      end
    end
  endtask
  function logic ReqSet;
    int ix;
    begin
      for(ix=0; ix < 7; ix=ix+1) begin
        if(msts[ix].intf.need===1) return 1;
      end
    end
    ReqSet=0;
  endfunction
  function [47:0] pickSlaveAddr(input int sn);
    logic [47:0] wk;
    begin
      wk=$urandom_range(slvs[sn].AddrLow,slvs[sn].AddrHigh);
      pickSlaveAddr=wk;
    end
  endfunction
  task anInterval(input int tnum);
    int ix;
    int icnt;
    begin
      ##1 #1;
      ix=0;
      while(isBusy(ix) && ix < 1000) ##1 #1 ix=ix+1;
      if(ix >= 1000) die("Requests not Clearing","Clearing");
      icnt=0;
      ##1 #1;
      while(icnt < 500 || ReqSet() ) begin
        if(icnt < 500 ) setReqs;
        if(ReqSet()) begin
          for( ix=0; (ix < 1000) && (!isResp()); ix=ix+1) ##1 #1;
          if(ix >= 1000) die("Response didn't happen","response");
          icnt=icnt+1;
	  msts[winningMaster].intf.need=0;
          slvs[slaveTarget].xfrIt(msts[winningMaster]);
        end
      end
    end
  endtask
  task anInterval2(input int tnum);
    int ix;
    int icnt;
    begin
      ##1 #1;
      ix=0;
      while(isBusy(ix) && ix < 1000) ##1 #1 ix=ix+1;
      if(ix >= 1000) die("Requests not Clearing","Clearing");
      icnt=0;
      ##1 #1;
      while(icnt < 500 || ReqSet() ) begin
        if(icnt < 500 ) setReqs2;
        if(ReqSet()) begin
          for( ix=0; (ix < 1000) && (!isResp()); ix=ix+1) ##1 #1;
          if(ix >= 1000) die("Response didn't happen","response");
          icnt=icnt+1;
	  msts[winningMaster].intf.need=0;
          slvs[slaveTarget].xfrIt(msts[winningMaster]);
        end
      end
    end
  endtask

endmodule
