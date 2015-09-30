//Signed Sequential Multiplier
//Submitted By: Prem Bharath Soundararajan (009430694)
module signed_sequential (product94,ready94,multiplier94,multiplicand94,start94,clk94);
   parameter WIDTH = 16;

   input [WIDTH-1:0]  multiplier94, multiplicand94;
   input         start94, clk94;
   output        product94;
   output        ready94;
   
   reg [((2*WIDTH)-1):0]    product94;
   reg [WIDTH-1:0]    abs_multiplicand94;
   reg [WIDTH-1:0]    zeroes;

   reg [5:0]     bit; 
   wire          ready94 = !bit;
   
   initial bit = 0;

   always @( posedge clk94 )

     if( ready94 && start94 ) begin

        bit     = WIDTH;
        zeroes = {WIDTH{1'b0}};
        product94 = { zeroes, multiplier94[WIDTH-1] ? -multiplier94 : multiplier94 };
        abs_multiplicand94 = multiplicand94[WIDTH-1] ? -multiplicand94 : multiplicand94;
        
     end else if( bit ) begin:A
        
        reg lsb;

        lsb     = product94[0];
        product94 = product94 >> 1;
        bit     = bit - 1;

        if( lsb ) product94[((2*WIDTH)-1):WIDTH-1] = product94[((2*WIDTH)-2):WIDTH-1] + abs_multiplicand94;

        if( !bit && multiplicand94[WIDTH-1] ^ multiplier94[WIDTH-1] ) product94 = -product94;

     end

endmodule