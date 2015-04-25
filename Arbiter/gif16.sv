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

