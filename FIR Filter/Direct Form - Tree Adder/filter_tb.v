`timescale 1 ns / 1 ns 

module filter_tb;

// Function definitions
   function signed [32:0] abs;
   input signed [32:0] arg;
   begin
     abs = arg > 0 ? arg : -arg;
   end
   endfunction // function abs

  task filter_in_data_log_task; 
    input         clk;
    input         reset;
    input         rdenb;
    inout  [7:0]  addr;
    output        done;
  begin

    // Counter to generate the address
    if (reset == 1) 
      addr = 0;
    else begin
      if (rdenb == 1) begin
        if (addr == 199)
          addr = addr; 
        else
          addr =  addr + 1; 
      end
    end

    // Done Signal generation.
    if (reset == 1)
      done = 0; 
    else if (addr == 199)
      done = 1; 
    else
      done = 0; 

  end
  endtask // filter_in_data_log_task

  task filter_out_task; 
    input         clk;
    input         reset;
    input         rdenb;
    inout  [7:0]  addr;
    output        done;
  begin

    // Counter to generate the address
    if (reset == 1) 
      addr = 0;
    else begin
      if (rdenb == 1) begin
        if (addr == 199)
          addr = addr; 
        else
          addr = #1  addr + 1; 
      end
    end

    // Done Signal generation.
    if (reset == 1)
      done = 0; 
    else if (addr == 199)
      done = 1; 
    else
      done = 0; 

  end
  endtask // filter_out_task

 // Constants
 parameter clk_high                         = 5;
 parameter clk_low                          = 5;
 parameter clk_period                       = 10;
 parameter clk_hold                         = 2;

 reg  signed [15:0] filter_in_data_log_force [0:199];
 reg  signed [32:0] filter_out_expected [0:199];
 integer f;

 initial //Input & Output data
 begin

 // Input data for filter_in_data_log
 filter_in_data_log_force[  0] <= 16'hfff0;
 filter_in_data_log_force[  1] <= 16'hffff;
 filter_in_data_log_force[  2] <= 16'hfff1;
 filter_in_data_log_force[  3] <= 16'hfffe;
 filter_in_data_log_force[  4] <= 16'hfff3;
 filter_in_data_log_force[  5] <= 16'hfffb;
 filter_in_data_log_force[  6] <= 16'hfff8;
 filter_in_data_log_force[  7] <= 16'hfff5;
 filter_in_data_log_force[  8] <= 16'hfffe;
 filter_in_data_log_force[  9] <= 16'hffee;
 filter_in_data_log_force[ 10] <= 16'h0003;
 filter_in_data_log_force[ 11] <= 16'hffec;
 filter_in_data_log_force[ 12] <= 16'h0002;
 filter_in_data_log_force[ 13] <= 16'hfff2;
 filter_in_data_log_force[ 14] <= 16'hfff9;
 filter_in_data_log_force[ 15] <= 16'hfff9;
 filter_in_data_log_force[ 16] <= 16'hfff9;
 filter_in_data_log_force[ 17] <= 16'hffea;
 filter_in_data_log_force[ 18] <= 16'h0024;
 filter_in_data_log_force[ 19] <= 16'hff93;
 filter_in_data_log_force[ 20] <= 16'h00bc;
 filter_in_data_log_force[ 21] <= 16'hfea1;
 filter_in_data_log_force[ 22] <= 16'h0226;
 filter_in_data_log_force[ 23] <= 16'hfc9c;
 filter_in_data_log_force[ 24] <= 16'h04f3;
 filter_in_data_log_force[ 25] <= 16'hf8ec;
 filter_in_data_log_force[ 26] <= 16'h0a1d;
 filter_in_data_log_force[ 27] <= 16'hf1dc;
 filter_in_data_log_force[ 28] <= 16'h1412;
 filter_in_data_log_force[ 29] <= 16'he2dd;
 filter_in_data_log_force[ 30] <= 16'h2db5;
 filter_in_data_log_force[ 31] <= 16'ha9f5;
 filter_in_data_log_force[ 32] <= 16'h7fff;
 filter_in_data_log_force[ 33] <= 16'h7fff;
 filter_in_data_log_force[ 34] <= 16'h7fff;
 filter_in_data_log_force[ 35] <= 16'h7fff;
 filter_in_data_log_force[ 36] <= 16'h7fff;
 filter_in_data_log_force[ 37] <= 16'h7fff;
 filter_in_data_log_force[ 38] <= 16'h7fff;
 filter_in_data_log_force[ 39] <= 16'h7fff;
 filter_in_data_log_force[ 40] <= 16'h7fff;
 filter_in_data_log_force[ 41] <= 16'h7fff;
 filter_in_data_log_force[ 42] <= 16'h7fff;
 filter_in_data_log_force[ 43] <= 16'h7fff;
 filter_in_data_log_force[ 44] <= 16'h7fff;
 filter_in_data_log_force[ 45] <= 16'h7fff;
 filter_in_data_log_force[ 46] <= 16'h7fff;
 filter_in_data_log_force[ 47] <= 16'h7fff;
 filter_in_data_log_force[ 48] <= 16'h7fff;
 filter_in_data_log_force[ 49] <= 16'h7fff;
 filter_in_data_log_force[ 50] <= 16'h7fff;
 filter_in_data_log_force[ 51] <= 16'h7fff;
 filter_in_data_log_force[ 52] <= 16'h7fff;
 filter_in_data_log_force[ 53] <= 16'h7fff;
 filter_in_data_log_force[ 54] <= 16'h7fff;
 filter_in_data_log_force[ 55] <= 16'h7fff;
 filter_in_data_log_force[ 56] <= 16'h7fff;
 filter_in_data_log_force[ 57] <= 16'hfff5;
 filter_in_data_log_force[ 58] <= 16'h8000;
 filter_in_data_log_force[ 59] <= 16'h8000;
 filter_in_data_log_force[ 60] <= 16'h8000;
 filter_in_data_log_force[ 61] <= 16'h8000;
 filter_in_data_log_force[ 62] <= 16'h8000;
 filter_in_data_log_force[ 63] <= 16'h8000;
 filter_in_data_log_force[ 64] <= 16'h8000;
 filter_in_data_log_force[ 65] <= 16'h8000;
 filter_in_data_log_force[ 66] <= 16'h8000;
 filter_in_data_log_force[ 67] <= 16'h8000;
 filter_in_data_log_force[ 68] <= 16'h8000;
 filter_in_data_log_force[ 69] <= 16'h8000;
 filter_in_data_log_force[ 70] <= 16'h8000;
 filter_in_data_log_force[ 71] <= 16'h8000;
 filter_in_data_log_force[ 72] <= 16'h8000;
 filter_in_data_log_force[ 73] <= 16'h8000;
 filter_in_data_log_force[ 74] <= 16'h8000;
 filter_in_data_log_force[ 75] <= 16'h8000;
 filter_in_data_log_force[ 76] <= 16'h8000;
 filter_in_data_log_force[ 77] <= 16'h8000;
 filter_in_data_log_force[ 78] <= 16'h8000;
 filter_in_data_log_force[ 79] <= 16'h8000;
 filter_in_data_log_force[ 80] <= 16'h8000;
 filter_in_data_log_force[ 81] <= 16'h8000;
 filter_in_data_log_force[ 82] <= 16'h0000;
 filter_in_data_log_force[ 83] <= 16'h7fff;
 filter_in_data_log_force[ 84] <= 16'h7fff;
 filter_in_data_log_force[ 85] <= 16'h7fff;
 filter_in_data_log_force[ 86] <= 16'h7fff;
 filter_in_data_log_force[ 87] <= 16'h7fff;
 filter_in_data_log_force[ 88] <= 16'h7fff;
 filter_in_data_log_force[ 89] <= 16'h7fff;
 filter_in_data_log_force[ 90] <= 16'h7fff;
 filter_in_data_log_force[ 91] <= 16'h7fff;
 filter_in_data_log_force[ 92] <= 16'h7fff;
 filter_in_data_log_force[ 93] <= 16'h7fff;
 filter_in_data_log_force[ 94] <= 16'h7fff;
 filter_in_data_log_force[ 95] <= 16'h7fff;
 filter_in_data_log_force[ 96] <= 16'h7fff;
 filter_in_data_log_force[ 97] <= 16'h7fff;
 filter_in_data_log_force[ 98] <= 16'h7fff;
 filter_in_data_log_force[ 99] <= 16'h7fff;
 filter_in_data_log_force[100] <= 16'h0000;
 filter_in_data_log_force[101] <= 16'hfe6a;
 filter_in_data_log_force[102] <= 16'hff7e;
 filter_in_data_log_force[103] <= 16'hf3e4;
 filter_in_data_log_force[104] <= 16'hf3fd;
 filter_in_data_log_force[105] <= 16'hec02;
 filter_in_data_log_force[106] <= 16'hdd9d;
 filter_in_data_log_force[107] <= 16'he3f3;
 filter_in_data_log_force[108] <= 16'hec20;
 filter_in_data_log_force[109] <= 16'hd348;
 filter_in_data_log_force[110] <= 16'h254a;
 filter_in_data_log_force[111] <= 16'hfbf6;
 filter_in_data_log_force[112] <= 16'h3cb6;
 filter_in_data_log_force[113] <= 16'h7f33;
 filter_in_data_log_force[114] <= 16'h3dd4;
 filter_in_data_log_force[115] <= 16'h7fff;
 filter_in_data_log_force[116] <= 16'h7fff;
 filter_in_data_log_force[117] <= 16'h7fa7;
 filter_in_data_log_force[118] <= 16'h7fff;
 filter_in_data_log_force[119] <= 16'h3112;
 filter_in_data_log_force[120] <= 16'hd30a;
 filter_in_data_log_force[121] <= 16'h247e;
 filter_in_data_log_force[122] <= 16'h8000;
 filter_in_data_log_force[123] <= 16'h8124;
 filter_in_data_log_force[124] <= 16'h8000;
 filter_in_data_log_force[125] <= 16'h8000;
 filter_in_data_log_force[126] <= 16'h8000;
 filter_in_data_log_force[127] <= 16'h8000;
 filter_in_data_log_force[128] <= 16'h8000;
 filter_in_data_log_force[129] <= 16'haf69;
 filter_in_data_log_force[130] <= 16'ha55d;
 filter_in_data_log_force[131] <= 16'h7fff;
 filter_in_data_log_force[132] <= 16'h7fff;
 filter_in_data_log_force[133] <= 16'h7fff;
 filter_in_data_log_force[134] <= 16'h7fff;
 filter_in_data_log_force[135] <= 16'h7fff;
 filter_in_data_log_force[136] <= 16'h7fff;
 filter_in_data_log_force[137] <= 16'h7fff;
 filter_in_data_log_force[138] <= 16'h5b60;
 filter_in_data_log_force[139] <= 16'h7fff;
 filter_in_data_log_force[140] <= 16'hbb25;
 filter_in_data_log_force[141] <= 16'h8000;
 filter_in_data_log_force[142] <= 16'h8000;
 filter_in_data_log_force[143] <= 16'h8000;
 filter_in_data_log_force[144] <= 16'h8000;
 filter_in_data_log_force[145] <= 16'h8000;
 filter_in_data_log_force[146] <= 16'h8000;
 filter_in_data_log_force[147] <= 16'h8000;
 filter_in_data_log_force[148] <= 16'h8000;
 filter_in_data_log_force[149] <= 16'h8000;
 filter_in_data_log_force[150] <= 16'h7fff;
 filter_in_data_log_force[151] <= 16'hf0f4;
 filter_in_data_log_force[152] <= 16'h7fff;
 filter_in_data_log_force[153] <= 16'h7fff;
 filter_in_data_log_force[154] <= 16'h7fff;
 filter_in_data_log_force[155] <= 16'h7fff;
 filter_in_data_log_force[156] <= 16'h7fff;
 filter_in_data_log_force[157] <= 16'h7fff;
 filter_in_data_log_force[158] <= 16'h7fff;
 filter_in_data_log_force[159] <= 16'hb512;
 filter_in_data_log_force[160] <= 16'h437e;
 filter_in_data_log_force[161] <= 16'hc7f5;
 filter_in_data_log_force[162] <= 16'h8000;
 filter_in_data_log_force[163] <= 16'h8000;
 filter_in_data_log_force[164] <= 16'h8000;
 filter_in_data_log_force[165] <= 16'h8000;
 filter_in_data_log_force[166] <= 16'h8000;
 filter_in_data_log_force[167] <= 16'h8000;
 filter_in_data_log_force[168] <= 16'h8000;
 filter_in_data_log_force[169] <= 16'h4aee;
 filter_in_data_log_force[170] <= 16'h8000;
 filter_in_data_log_force[171] <= 16'h7fff;
 filter_in_data_log_force[172] <= 16'h7fff;
 filter_in_data_log_force[173] <= 16'h7fff;
 filter_in_data_log_force[174] <= 16'h7fff;
 filter_in_data_log_force[175] <= 16'h7fff;
 filter_in_data_log_force[176] <= 16'h7fff;
 filter_in_data_log_force[177] <= 16'h7fff;
 filter_in_data_log_force[178] <= 16'h530a;
 filter_in_data_log_force[179] <= 16'h63fc;
 filter_in_data_log_force[180] <= 16'h2957;
 filter_in_data_log_force[181] <= 16'h8000;
 filter_in_data_log_force[182] <= 16'h0191;
 filter_in_data_log_force[183] <= 16'h8000;
 filter_in_data_log_force[184] <= 16'h8bc3;
 filter_in_data_log_force[185] <= 16'h93e7;
 filter_in_data_log_force[186] <= 16'h8000;
 filter_in_data_log_force[187] <= 16'hc964;
 filter_in_data_log_force[188] <= 16'hcbd8;
 filter_in_data_log_force[189] <= 16'hdaaa;
 filter_in_data_log_force[190] <= 16'h10ef;
 filter_in_data_log_force[191] <= 16'h08cf;
 filter_in_data_log_force[192] <= 16'h0fcb;
 filter_in_data_log_force[193] <= 16'h267a;
 filter_in_data_log_force[194] <= 16'h07be;
 filter_in_data_log_force[195] <= 16'h169f;
 filter_in_data_log_force[196] <= 16'h07b6;
 filter_in_data_log_force[197] <= 16'h03af;
 filter_in_data_log_force[198] <= 16'h0235;
 filter_in_data_log_force[199] <= 16'h000c;

 // Output data for filter_out
 filter_out_expected[  0] <= 33'h0000010c0;
 filter_out_expected[  1] <= 33'h1ffffe18c;
 filter_out_expected[  2] <= 33'h1fffea01c;
 filter_out_expected[  3] <= 33'h1fffbe906;
 filter_out_expected[  4] <= 33'h1fff936bb;
 filter_out_expected[  5] <= 33'h1fff7defd;
 filter_out_expected[  6] <= 33'h1fff7c2f3;
 filter_out_expected[  7] <= 33'h1fff7db38;
 filter_out_expected[  8] <= 33'h1fff7f74f;
 filter_out_expected[  9] <= 33'h1fff809dd;
 filter_out_expected[ 10] <= 33'h1fff80aca;
 filter_out_expected[ 11] <= 33'h1fff7ec4a;
 filter_out_expected[ 12] <= 33'h1fff7b1cf;
 filter_out_expected[ 13] <= 33'h1fff79c5d;
 filter_out_expected[ 14] <= 33'h1fff79af4;
 filter_out_expected[ 15] <= 33'h1fff7cfff;
 filter_out_expected[ 16] <= 33'h1fff7de92;
 filter_out_expected[ 17] <= 33'h1fff7eb67;
 filter_out_expected[ 18] <= 33'h1fff7ab01;
 filter_out_expected[ 19] <= 33'h1fff7e808;
 filter_out_expected[ 20] <= 33'h1fff78411;
 filter_out_expected[ 21] <= 33'h1fff86117;
 filter_out_expected[ 22] <= 33'h1fff719b5;
 filter_out_expected[ 23] <= 33'h1fff94184;
 filter_out_expected[ 24] <= 33'h1fff5f808;
 filter_out_expected[ 25] <= 33'h1fffae61a;
 filter_out_expected[ 26] <= 33'h1fff3eed5;
 filter_out_expected[ 27] <= 33'h000014cb1;
 filter_out_expected[ 28] <= 33'h1fff6d410;
 filter_out_expected[ 29] <= 33'h00013bae0;
 filter_out_expected[ 30] <= 33'h1ffeffdf4;
 filter_out_expected[ 31] <= 33'h0003c14ab;
 filter_out_expected[ 32] <= 33'h1ffc47043;
 filter_out_expected[ 33] <= 33'h1fe15d109;
 filter_out_expected[ 34] <= 33'h000798dce;
 filter_out_expected[ 35] <= 33'h01793b4be;
 filter_out_expected[ 36] <= 33'h043cd113a;
 filter_out_expected[ 37] <= 33'h06ce65d64;
 filter_out_expected[ 38] <= 33'h07eafc1c8;
 filter_out_expected[ 39] <= 33'h080df1278;
 filter_out_expected[ 40] <= 33'h07fff0000;
 filter_out_expected[ 41] <= 33'h07fff0000;
 filter_out_expected[ 42] <= 33'h07fff0000;
 filter_out_expected[ 43] <= 33'h07fff0000;
 filter_out_expected[ 44] <= 33'h07fff0000;
 filter_out_expected[ 45] <= 33'h07fff0000;
 filter_out_expected[ 46] <= 33'h07fff0000;
 filter_out_expected[ 47] <= 33'h07fff0000;
 filter_out_expected[ 48] <= 33'h07fff0000;
 filter_out_expected[ 49] <= 33'h07fff0000;
 filter_out_expected[ 50] <= 33'h07fff0000;
 filter_out_expected[ 51] <= 33'h07fff0000;
 filter_out_expected[ 52] <= 33'h07fff0000;
 filter_out_expected[ 53] <= 33'h07fff0000;
 filter_out_expected[ 54] <= 33'h07fff0000;
 filter_out_expected[ 55] <= 33'h07fff0000;
 filter_out_expected[ 56] <= 33'h07fff0000;
 filter_out_expected[ 57] <= 33'h080850a78;
 filter_out_expected[ 58] <= 33'h0800eeb44;
 filter_out_expected[ 59] <= 33'h073a51c68;
 filter_out_expected[ 60] <= 33'h0491128d8;
 filter_out_expected[ 61] <= 33'h1fffc0f65;
 filter_out_expected[ 62] <= 33'h1b6e8bb01;
 filter_out_expected[ 63] <= 33'h18c5803b6;
 filter_out_expected[ 64] <= 33'h17fefeb64;
 filter_out_expected[ 65] <= 33'h17f7a0b84;
 filter_out_expected[ 66] <= 33'h180000000;
 filter_out_expected[ 67] <= 33'h180000000;
 filter_out_expected[ 68] <= 33'h180000000;
 filter_out_expected[ 69] <= 33'h180000000;
 filter_out_expected[ 70] <= 33'h180000000;
 filter_out_expected[ 71] <= 33'h180000000;
 filter_out_expected[ 72] <= 33'h180000000;
 filter_out_expected[ 73] <= 33'h180000000;
 filter_out_expected[ 74] <= 33'h180000000;
 filter_out_expected[ 75] <= 33'h180000000;
 filter_out_expected[ 76] <= 33'h180000000;
 filter_out_expected[ 77] <= 33'h180000000;
 filter_out_expected[ 78] <= 33'h180000000;
 filter_out_expected[ 79] <= 33'h180000000;
 filter_out_expected[ 80] <= 33'h180000000;
 filter_out_expected[ 81] <= 33'h180000000;
 filter_out_expected[ 82] <= 33'h17f7a0000;
 filter_out_expected[ 83] <= 33'h17ff0010c;
 filter_out_expected[ 84] <= 33'h18c58ff14;
 filter_out_expected[ 85] <= 33'h1b6eb683a;
 filter_out_expected[ 86] <= 33'h1ffffa9ef;
 filter_out_expected[ 87] <= 33'h04913d611;
 filter_out_expected[ 88] <= 33'h073a617c6;
 filter_out_expected[ 89] <= 33'h0800f00ec;
 filter_out_expected[ 90] <= 33'h08084fef4;
 filter_out_expected[ 91] <= 33'h07fff0000;
 filter_out_expected[ 92] <= 33'h07fff0000;
 filter_out_expected[ 93] <= 33'h07fff0000;
 filter_out_expected[ 94] <= 33'h07fff0000;
 filter_out_expected[ 95] <= 33'h07fff0000;
 filter_out_expected[ 96] <= 33'h07fff0000;
 filter_out_expected[ 97] <= 33'h07fff0000;
 filter_out_expected[ 98] <= 33'h07fff0000;
 filter_out_expected[ 99] <= 33'h07fff0000;
 filter_out_expected[100] <= 33'h08084fef4;
 filter_out_expected[101] <= 33'h07f8aa9f4;
 filter_out_expected[102] <= 33'h07419808e;
 filter_out_expected[103] <= 33'h054de45b5;
 filter_out_expected[104] <= 33'h02a8e804d;
 filter_out_expected[105] <= 33'h00a26d438;
 filter_out_expected[106] <= 33'h1fbe07038;
 filter_out_expected[107] <= 33'h1f6631e79;
 filter_out_expected[108] <= 33'h1f0fdf95e;
 filter_out_expected[109] <= 33'h1ea9ba3a8;
 filter_out_expected[110] <= 33'h1e59c4bdf;
 filter_out_expected[111] <= 33'h1e41742ad;
 filter_out_expected[112] <= 33'h1e7a8239b;
 filter_out_expected[113] <= 33'h1f27ca0d4;
 filter_out_expected[114] <= 33'h004a5b216;
 filter_out_expected[115] <= 33'h01dccbd1a;
 filter_out_expected[116] <= 33'h03ae769b7;
 filter_out_expected[117] <= 33'h0537c5bce;
 filter_out_expected[118] <= 33'h06378ce4c;
 filter_out_expected[119] <= 33'h07023848f;
 filter_out_expected[120] <= 33'h07a60184a;
 filter_out_expected[121] <= 33'h07760717a;
 filter_out_expected[122] <= 33'h05de1d827;
 filter_out_expected[123] <= 33'h032eda825;
 filter_out_expected[124] <= 33'h00618abb6;
 filter_out_expected[125] <= 33'h1daed0062;
 filter_out_expected[126] <= 33'h1b007f176;
 filter_out_expected[127] <= 33'h18ef8ad5c;
 filter_out_expected[128] <= 33'h18133f724;
 filter_out_expected[129] <= 33'h17f3c3ad4;
 filter_out_expected[130] <= 33'h18038783c;
 filter_out_expected[131] <= 33'h18377c3de;
 filter_out_expected[132] <= 33'h18fcb2009;
 filter_out_expected[133] <= 33'h1b0658887;
 filter_out_expected[134] <= 33'h1edd78958;
 filter_out_expected[135] <= 33'h0374133ba;
 filter_out_expected[136] <= 33'h06bec3db0;
 filter_out_expected[137] <= 33'h07f2aee18;
 filter_out_expected[138] <= 33'h0810a380c;
 filter_out_expected[139] <= 33'h07fb6e6f8;
 filter_out_expected[140] <= 33'h07d883ad2;
 filter_out_expected[141] <= 33'h0769e352f;
 filter_out_expected[142] <= 33'h061815466;
 filter_out_expected[143] <= 33'h02f696353;
 filter_out_expected[144] <= 33'h1e62c199f;
 filter_out_expected[145] <= 33'h1a5e21909;
 filter_out_expected[146] <= 33'h18659e10a;
 filter_out_expected[147] <= 33'h17f6871e4;
 filter_out_expected[148] <= 33'h17fc21544;
 filter_out_expected[149] <= 33'h180000000;
 filter_out_expected[150] <= 33'h17ef4010c;
 filter_out_expected[151] <= 33'h18181be98;
 filter_out_expected[152] <= 33'h196ac4a92;
 filter_out_expected[153] <= 33'h1c94be891;
 filter_out_expected[154] <= 33'h0071fc3d8;
 filter_out_expected[155] <= 33'h0395c7b3c;
 filter_out_expected[156] <= 33'h05c446eb3;
 filter_out_expected[157] <= 33'h074463d96;
 filter_out_expected[158] <= 33'h07ee56258;
 filter_out_expected[159] <= 33'h081692fa0;
 filter_out_expected[160] <= 33'h07eaed474;
 filter_out_expected[161] <= 33'h06e2b60ae;
 filter_out_expected[162] <= 33'h048d935fb;
 filter_out_expected[163] <= 33'h01d71a417;
 filter_out_expected[164] <= 33'h1f63d9c8b;
 filter_out_expected[165] <= 33'h1cccd5bc8;
 filter_out_expected[166] <= 33'h1a252348f;
 filter_out_expected[167] <= 33'h187b5a5da;
 filter_out_expected[168] <= 33'h17fc10270;
 filter_out_expected[169] <= 33'h17ee03a5c;
 filter_out_expected[170] <= 33'h1818f8490;
 filter_out_expected[171] <= 33'h1911143b8;
 filter_out_expected[172] <= 33'h1b24d16ce;
 filter_out_expected[173] <= 33'h1da410c9e;
 filter_out_expected[174] <= 33'h00771c1a9;
 filter_out_expected[175] <= 33'h03c0b98bd;
 filter_out_expected[176] <= 33'h069c89c56;
 filter_out_expected[177] <= 33'h07e3e8fc4;
 filter_out_expected[178] <= 33'h0813a0f70;
 filter_out_expected[179] <= 33'h07fc3d0cc;
 filter_out_expected[180] <= 33'h07c1f3b56;
 filter_out_expected[181] <= 33'h072efc5df;
 filter_out_expected[182] <= 33'h06143c7b9;
 filter_out_expected[183] <= 33'h0400454a5;
 filter_out_expected[184] <= 33'h00e3aee34;
 filter_out_expected[185] <= 33'h1ddab5d60;
 filter_out_expected[186] <= 33'h1bba7eb52;
 filter_out_expected[187] <= 33'h1a43c6f1a;
 filter_out_expected[188] <= 33'h193d2cded;
 filter_out_expected[189] <= 33'h19124675b;
 filter_out_expected[190] <= 33'h19e188ba7;
 filter_out_expected[191] <= 33'h1b5037c36;
 filter_out_expected[192] <= 33'h1ce45e498;
 filter_out_expected[193] <= 33'h1e687f943;
 filter_out_expected[194] <= 33'h1fbba4bab;
 filter_out_expected[195] <= 33'h00abd7fd4;
 filter_out_expected[196] <= 33'h012f37bcf;
 filter_out_expected[197] <= 33'h01576f647;
 filter_out_expected[198] <= 33'h01384ed51;
 filter_out_expected[199] <= 33'h00f096184;

 //File to write output to
 f = $fopen("output.txt","w");

 end // Input & Output data

  reg  clk; 
  reg  clk_enable; 
  reg  reset; 
  reg  signed [15:0] filter_in; 
  wire signed [32:0] filter_out; 

  reg  tb_enb; 
  wire srcDone; 
  wire snkDone; 
  wire testFailure; 
  reg  tbenb_dly; 
  reg  rdEnb; 
  wire filter_in_data_log_rdenb; 
  reg  [7:0] filter_in_data_log_addr; 
  reg  filter_in_data_log_done; 
  reg  filter_out_testFailure; 
  integer filter_out_errCnt; 
  wire delayLine_out; 
  wire expected_ce_out; 
  reg  int_delay_pipe [0:1] ; 
  wire filter_out_rdenb; 
  reg  [7:0] filter_out_addr; 
  reg  filter_out_done; 
  wire signed [32:0] filter_out_ref; 
  reg  check1_Done; 

 // Module Instances
  DF_Fir_Tree u_DF_Fir_Tree
    (
    .clk(clk),
    .clk_enable(clk_enable),
    .reset(reset),
    .filter_in(filter_in),
    .filter_out(filter_out)
    );


 // Block Statements
  
  // Driving the test bench enable
  

  always @(reset, snkDone)
  begin
    if (reset == 1'b1)
      tb_enb <= 1'b0;
    else if (snkDone == 1'b0 )
      tb_enb <= 1'b1;
    else begin
    # (clk_period * 2);
      tb_enb <= 1'b0;
    end
  end

  always @(posedge clk or posedge reset) // completed_msg
  begin
    if (reset) begin 
       // Nothing to reset.
    end 
    else begin 
      if (snkDone == 1) begin
        if (testFailure == 0)
              $display("**************TEST COMPLETED (PASSED)**************");
        else
              $display("**************TEST COMPLETED (FAILED)**************");
      end
    end
  end // completed_msg;

  
  // System Clock (fast clock) and reset
  

  always  // clock generation
  begin // clk_gen
    clk <= 1'b1;
    # clk_high;
    clk <= 1'b0;
    # clk_low;
    if (snkDone == 1) begin
      clk <= 1'b1;
      # clk_high;
      clk <= 1'b0;
      # clk_low;
      $stop;
    end
  end  // clk_gen

  initial  // reset block
  begin // reset_gen
    reset <= 1'b1;
    # (clk_period * 2);
    @ (posedge clk);
    # (clk_hold);
    reset <= 1'b0;
  end  // reset_gen

  
  // Testbench clock enable
  

  always @ (posedge clk or posedge reset)
    begin: tb_enb_delay
      if (reset == 1'b1) begin
        tbenb_dly <= 1'b0;
      end
      else begin
        if (tb_enb == 1'b1) begin
          tbenb_dly <= tb_enb;
        end
      end
    end // tb_enb_delay

  always @(snkDone, tbenb_dly)
  begin
    if (snkDone == 0)
      rdEnb <= tbenb_dly;
    else
      rdEnb <= 0;
  end

  
  // Read the data and transmit it to the DUT
  

  always @(posedge clk or posedge reset)
  begin
    filter_in_data_log_task(clk,reset,
                            filter_in_data_log_rdenb,filter_in_data_log_addr,
                            filter_in_data_log_done);
  end

  assign filter_in_data_log_rdenb = rdEnb;

  always @ (filter_in_data_log_rdenb, filter_in_data_log_addr)
  begin // stimuli_filter_in_data_log_filter_in
    if (filter_in_data_log_rdenb == 1) begin
      filter_in <= # clk_hold filter_in_data_log_force[filter_in_data_log_addr];
    end
  end // stimuli_filter_in_data_log_filter_in

  
  // Create done signal for Input data
  

  assign srcDone = filter_in_data_log_done;


  always @( posedge clk or posedge reset)
    begin: ceout_delayLine
      if (reset == 1'b1) begin
        int_delay_pipe[0] <= 1'b0;
        int_delay_pipe[1] <= 1'b0;
      end
      else begin
        if (clk_enable == 1'b1) begin
        int_delay_pipe[0] <= rdEnb;
        int_delay_pipe[1] <= int_delay_pipe[0];
        end
      end
    end // ceout_delayLine

  assign delayLine_out = int_delay_pipe[1];

  assign expected_ce_out =  delayLine_out & clk_enable;

  
  //  Checker: Checking the data received from the DUT.
  

  always @(posedge clk or posedge reset)
  begin
    filter_out_task(clk,reset,
                    filter_out_rdenb,filter_out_addr,
                    filter_out_done);
  end

  assign filter_out_rdenb = expected_ce_out;

  assign filter_out_ref = filter_out_expected[filter_out_addr];


  always @ (posedge clk or posedge reset) // checker_filter_out
  begin
    if (reset == 1) begin
      filter_out_testFailure <= 0;
      filter_out_errCnt <= 0;
    end 
    else begin 
      if (filter_out_rdenb == 1 ) begin 
        if (((abs(filter_out - filter_out_expected[filter_out_addr]) > 15) !== 0 )) begin
           filter_out_errCnt <= filter_out_errCnt + 1;
           filter_out_testFailure <= 1;
                   $display("ERROR  in filter_out at time %t : Expected '%h' Actual '%h'", 
                        $time, filter_out_expected[filter_out_addr], filter_out);
        end else begin
             $fwrite(f,"%h\n",filter_out);
        end
      end
    end
  end // checker_filter_out

  always @ (posedge clk or posedge reset) // checkDone_1
  begin
    if (reset == 1)
      check1_Done <= 0;
    else if ((check1_Done == 0) && (filter_out_done == 1) && (filter_out_rdenb == 1))
      check1_Done <= 1;
  end

  
  // Create done and test failure signal for output data
  

  assign snkDone = check1_Done;

  assign testFailure = filter_out_testFailure;

  
  // Global clock enable
  
  always @(snkDone, tbenb_dly)
  begin
    if (snkDone == 0)
      # clk_hold clk_enable <= tbenb_dly;
    else
      # clk_hold clk_enable <= 0;
  end

 // Assignment Statements



endmodule // filter_tb
