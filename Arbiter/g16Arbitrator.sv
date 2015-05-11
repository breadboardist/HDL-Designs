`timescale 1ns/10ps
//Arbiter Supporting Seven Masters
module g16Arbitrator (g16_if.CLKS cks,
						g16_if.Mstr m00, g16_if.Slave s00,
						g16_if.Mstr m01, g16_if.Slave s01,						
						g16_if.Mstr m02, g16_if.Slave s02,						
						g16_if.Mstr m03, g16_if.Slave s03,						
						g16_if.Mstr m04, g16_if.Slave s04,						
						g16_if.Mstr m05, g16_if.Slave s05,
						g16_if.Mstr m06, g16_if.Slave s06,
						g16_if.Slave s07,
						g16_if.Slave s08,
						g16_if.Slave s09,
						g16_if.Slave s10,
						g16_if.Slave s11,
						g16_if.Slave s12,
						g16_if.Slave s13);

logic idle,m00nsat,m01nsat,m02nsat,m03nsat,m04nsat,m05nsat, m06nsat, 
      m01need, m02need, m03need, m04need, m05need, m06need, m01neednsat,
      m02neednsat, m03neednsat, m04neednsat, m05neednsat, m06neednsat;

logic [8:0]   m00goal, m00xfer_count,
			        m01goal, m01xfer_count,
			        m02goal, m02xfer_count,
			        m03goal, m03xfer_count,
			        m04goal, m04xfer_count,
			        m05goal, m05xfer_count,
			        m06goal, m06xfer_count,
              xfer_counter;

always_comb begin
	
  //Calculate percentges
  m00goal = 105; //21*5
  m04goal = 105;
  m05goal = 105;
  m01goal = 30;  //6*5
  m02goal = 30;
  m06goal = 30;
  m03goal = 96;  //19*5=95, but 96 to compensate. The simulation fails if it is set to 95 or >95.

  //Check if bus is idle
  idle = m00.YouGotIt==0&&m01.YouGotIt==0&&m02.YouGotIt==0&&m03.YouGotIt==0&&m04.YouGotIt==0&&m05.YouGotIt==0&&m06.YouGotIt==0;

  //Check if master is satisfied
  m00nsat = (m00xfer_count<m00goal)?1:0;
  m01nsat = (m01xfer_count<m01goal)?1:0;
  m02nsat = (m02xfer_count<m02goal)?1:0;
  m03nsat = (m03xfer_count<m03goal)?1:0;
  m04nsat = (m04xfer_count<m04goal)?1:0;
  m05nsat = (m05xfer_count<m05goal)?1:0;
  m06nsat = (m06xfer_count<m06goal)?1:0;

  //Check if the master needs the bus. This combo logic will check if the highest priority master needs it or not.
  //The bus need of low priority master is acknowledged only if a higher priority master does not need it.
  if (m06.need&&(m00.need==0&&m04.need==0)&&(m05.need==0&&m03.need==0)&&(m01.need==0&&m02.need==0))
    	 m06need = 1;
  else m06need = 0;
  
  if (m02.need&&(m01.need==0)&&(m03.need==0&&m05.need==0)&&(m04.need==0&&m00.need==0))
    	 m02need =1;
  else m02need = 0;
  
  if (m01.need&&(m03.need==0&&m05.need==0)&&(m04.need==0&&m00.need==0))
    	 m01need = 1;
  else m01need = 0;
  
  if ((m03.need&&m05.need==0)&&(m04.need==0&&m00.need==0))
    	 m03need = 1;
  else m03need = 0;
  
  if (m05.need&&(m04.need==0&&m00.need==0))
   		 m05need = 1;
  else m05need = 0;
  
  if (m04.need&&m00.need==0)
    	 m04need = 1;
  else m04need = 0;
  
  //This signal is used to give grant to the masters. A need is asserted only if the master is not 
  //satisfied and the master is the highest priority one needing it an any time.
  m01neednsat= m01.need && m01nsat;
  m02neednsat= m02.need && m02nsat;
  m03neednsat= m03.need && m03nsat;
  m04neednsat= m04.need && m04nsat;
  m05neednsat= m05.need && m05nsat;
  m06neednsat= m06.need && m06nsat;  
end

always_ff @(posedge(cks.sysClk))begin
  
  if(cks.rst)begin
    m00xfer_count<=0;
    m01xfer_count<=0;
    m02xfer_count<=0;
    m03xfer_count<=0;
    m04xfer_count<=0;
    m05xfer_count<=0;
    m06xfer_count<=0;
    xfer_counter <=0;
    m00.YouGotIt <= 0;
    m01.YouGotIt <= 0;
    m02.YouGotIt <= 0;
    m03.YouGotIt <= 0;
    m04.YouGotIt <= 0;
    m05.YouGotIt <= 0;
    m06.YouGotIt <= 0;
    s00.tarActive <=0;
    s01.tarActive <=0;
    s02.tarActive <=0;
    s03.tarActive <=0;
    s04.tarActive <=0;
    s05.tarActive <=0;
    s06.tarActive <=0;
    s07.tarActive <=0;
    s08.tarActive <=0;
    s09.tarActive <=0;
    s10.tarActive <=0;
    s11.tarActive <=0;
    s12.tarActive <=0;
    s13.tarActive <=0;
  end

  //Multiplexors to connect appropriate masters to slaves
  case(1'b1)
	(m00.YouGotIt):begin 
      case(m00.addrM[19:0]) inside 
    		[20'hf8ddc:20'hf8edc]:begin s00.tarActive <= 1'b1;s00.Adr <= m00.addrM;s00.dbus_in <= m00.DoutM;m00.DinMast <= s00.dataOut; end
    		[20'hf7015:20'hf7085]:begin s01.tarActive <= 1'b1;s01.Adr <= m00.addrM;s01.dbus_in <= m00.DoutM;m00.DinMast <= s01.dataOut; end
    		[20'hf58ce:20'hf58df]:begin s02.tarActive <= 1'b1;s02.Adr <= m00.addrM;s02.dbus_in <= m00.DoutM;m00.DinMast <= s02.dataOut; end
    		[20'hf3ca5:20'hf3d61]:begin s03.tarActive <= 1'b1;s03.Adr <= m00.addrM;s03.dbus_in <= m00.DoutM;m00.DinMast <= s03.dataOut; end
    		[20'he951f:20'he9553]:begin s04.tarActive <= 1'b1;s04.Adr <= m00.addrM;s04.dbus_in <= m00.DoutM;m00.DinMast <= s04.dataOut; end
    		[20'he93e5:20'he93fe]:begin s05.tarActive <= 1'b1;s05.Adr <= m00.addrM;s05.dbus_in <= m00.DoutM;m00.DinMast <= s05.dataOut; end
    		[20'hf5342:20'hf5374]:begin s06.tarActive <= 1'b1;s06.Adr <= m00.addrM;s06.dbus_in <= m00.DoutM;m00.DinMast <= s06.dataOut; end
    		[20'hffc6a:20'hffd5a]:begin s07.tarActive <= 1'b1;s07.Adr <= m00.addrM;s07.dbus_in <= m00.DoutM;m00.DinMast <= s07.dataOut; end
    		[20'hf3064:20'hf3100]:begin s08.tarActive <= 1'b1;s08.Adr <= m00.addrM;s08.dbus_in <= m00.DoutM;m00.DinMast <= s08.dataOut; end
    		[20'hf7d12:20'hf7ded]:begin s09.tarActive <= 1'b1;s09.Adr <= m00.addrM;s09.dbus_in <= m00.DoutM;m00.DinMast <= s09.dataOut; end
    		[20'hf6513:20'hf6554]:begin s10.tarActive <= 1'b1;s10.Adr <= m00.addrM;s10.dbus_in <= m00.DoutM;m00.DinMast <= s10.dataOut; end
    		[20'hf4096:20'hf418a]:begin s11.tarActive <= 1'b1;s11.Adr <= m00.addrM;s11.dbus_in <= m00.DoutM;m00.DinMast <= s11.dataOut; end
    		[20'hfaac2:20'hfab79]:begin s12.tarActive <= 1'b1;s12.Adr <= m00.addrM;s12.dbus_in <= m00.DoutM;m00.DinMast <= s12.dataOut; end
    		[20'hf6066:20'hf610b]:begin s13.tarActive <= 1'b1;s13.Adr <= m00.addrM;s13.dbus_in <= m00.DoutM;m00.DinMast <= s13.dataOut; end
      endcase
    end

    (m01.YouGotIt):begin 
      case(m01.addrM[19:0]) inside 
		    [20'hf8ddc:20'hf8edc]:begin s00.tarActive <= 1'b1;s00.Adr <= m01.addrM;s00.dbus_in <= m01.DoutM;m01.DinMast <= s00.dataOut; end
		    [20'hf7015:20'hf7085]:begin s01.tarActive <= 1'b1;s01.Adr <= m01.addrM;s01.dbus_in <= m01.DoutM;m01.DinMast <= s01.dataOut; end
		    [20'hf58ce:20'hf58df]:begin s02.tarActive <= 1'b1;s02.Adr <= m01.addrM;s02.dbus_in <= m01.DoutM;m01.DinMast <= s02.dataOut; end
		    [20'hf3ca5:20'hf3d61]:begin s03.tarActive <= 1'b1;s03.Adr <= m01.addrM;s03.dbus_in <= m01.DoutM;m01.DinMast <= s03.dataOut; end
		    [20'he951f:20'he9553]:begin s04.tarActive <= 1'b1;s04.Adr <= m01.addrM;s04.dbus_in <= m01.DoutM;m01.DinMast <= s04.dataOut; end
		    [20'he93e5:20'he93fe]:begin s05.tarActive <= 1'b1;s05.Adr <= m01.addrM;s05.dbus_in <= m01.DoutM;m01.DinMast <= s05.dataOut; end
		    [20'hf5342:20'hf5374]:begin s06.tarActive <= 1'b1;s06.Adr <= m01.addrM;s06.dbus_in <= m01.DoutM;m01.DinMast <= s06.dataOut; end
		    [20'hffc6a:20'hffd5a]:begin s07.tarActive <= 1'b1;s07.Adr <= m01.addrM;s07.dbus_in <= m01.DoutM;m01.DinMast <= s07.dataOut; end
		    [20'hf3064:20'hf3100]:begin s08.tarActive <= 1'b1;s08.Adr <= m01.addrM;s08.dbus_in <= m01.DoutM;m01.DinMast <= s08.dataOut; end
		    [20'hf7d12:20'hf7ded]:begin s09.tarActive <= 1'b1;s09.Adr <= m01.addrM;s09.dbus_in <= m01.DoutM;m01.DinMast <= s09.dataOut; end
		    [20'hf6513:20'hf6554]:begin s10.tarActive <= 1'b1;s10.Adr <= m01.addrM;s10.dbus_in <= m01.DoutM;m01.DinMast <= s10.dataOut; end
		    [20'hf4096:20'hf418a]:begin s11.tarActive <= 1'b1;s11.Adr <= m01.addrM;s11.dbus_in <= m01.DoutM;m01.DinMast <= s11.dataOut; end
		    [20'hfaac2:20'hfab79]:begin s12.tarActive <= 1'b1;s12.Adr <= m01.addrM;s12.dbus_in <= m01.DoutM;m01.DinMast <= s12.dataOut; end
		    [20'hf6066:20'hf610b]:begin s13.tarActive <= 1'b1;s13.Adr <= m01.addrM;s13.dbus_in <= m01.DoutM;m01.DinMast <= s13.dataOut; end
      endcase
    end

    (m02.YouGotIt):begin
      case(m02.addrM[19:0]) inside 
		    [20'hf8ddc:20'hf8edc]:begin s00.tarActive <= 1'b1;s00.Adr <= m02.addrM;s00.dbus_in <= m02.DoutM;m02.DinMast <= s00.dataOut; end
		    [20'hf7015:20'hf7085]:begin s01.tarActive <= 1'b1;s01.Adr <= m02.addrM;s01.dbus_in <= m02.DoutM;m02.DinMast <= s01.dataOut; end
		    [20'hf58ce:20'hf58df]:begin s02.tarActive <= 1'b1;s02.Adr <= m02.addrM;s02.dbus_in <= m02.DoutM;m02.DinMast <= s02.dataOut; end
		    [20'hf3ca5:20'hf3d61]:begin s03.tarActive <= 1'b1;s03.Adr <= m02.addrM;s03.dbus_in <= m02.DoutM;m02.DinMast <= s03.dataOut; end
		    [20'he951f:20'he9553]:begin s04.tarActive <= 1'b1;s04.Adr <= m02.addrM;s04.dbus_in <= m02.DoutM;m02.DinMast <= s04.dataOut; end
		    [20'he93e5:20'he93fe]:begin s05.tarActive <= 1'b1;s05.Adr <= m02.addrM;s05.dbus_in <= m02.DoutM;m02.DinMast <= s05.dataOut; end
		    [20'hf5342:20'hf5374]:begin s06.tarActive <= 1'b1;s06.Adr <= m02.addrM;s06.dbus_in <= m02.DoutM;m02.DinMast <= s06.dataOut; end
		    [20'hffc6a:20'hffd5a]:begin s07.tarActive <= 1'b1;s07.Adr <= m02.addrM;s07.dbus_in <= m02.DoutM;m02.DinMast <= s07.dataOut; end
		    [20'hf3064:20'hf3100]:begin s08.tarActive <= 1'b1;s08.Adr <= m02.addrM;s08.dbus_in <= m02.DoutM;m02.DinMast <= s08.dataOut; end
		    [20'hf7d12:20'hf7ded]:begin s09.tarActive <= 1'b1;s09.Adr <= m02.addrM;s09.dbus_in <= m02.DoutM;m02.DinMast <= s09.dataOut; end
		    [20'hf6513:20'hf6554]:begin s10.tarActive <= 1'b1;s10.Adr <= m02.addrM;s10.dbus_in <= m02.DoutM;m02.DinMast <= s10.dataOut; end
		    [20'hf4096:20'hf418a]:begin s11.tarActive <= 1'b1;s11.Adr <= m02.addrM;s11.dbus_in <= m02.DoutM;m02.DinMast <= s11.dataOut; end
		    [20'hfaac2:20'hfab79]:begin s12.tarActive <= 1'b1;s12.Adr <= m02.addrM;s12.dbus_in <= m02.DoutM;m02.DinMast <= s12.dataOut; end
		    [20'hf6066:20'hf610b]:begin s13.tarActive <= 1'b1;s13.Adr <= m02.addrM;s13.dbus_in <= m02.DoutM;m02.DinMast <= s13.dataOut; end
      endcase
    end
    
    (m03.YouGotIt):begin 
      case(m03.addrM[19:0]) inside 
		    [20'hf8ddc:20'hf8edc]:begin s00.tarActive <= 1'b1;s00.Adr <= m03.addrM;s00.dbus_in <= m03.DoutM;m03.DinMast <= s00.dataOut; end
		    [20'hf7015:20'hf7085]:begin s01.tarActive <= 1'b1;s01.Adr <= m03.addrM;s01.dbus_in <= m03.DoutM;m03.DinMast <= s01.dataOut; end
		    [20'hf58ce:20'hf58df]:begin s02.tarActive <= 1'b1;s02.Adr <= m03.addrM;s02.dbus_in <= m03.DoutM;m03.DinMast <= s02.dataOut; end
		    [20'hf3ca5:20'hf3d61]:begin s03.tarActive <= 1'b1;s03.Adr <= m03.addrM;s03.dbus_in <= m03.DoutM;m03.DinMast <= s03.dataOut; end
		    [20'he951f:20'he9553]:begin s04.tarActive <= 1'b1;s04.Adr <= m03.addrM;s04.dbus_in <= m03.DoutM;m03.DinMast <= s04.dataOut; end
		    [20'he93e5:20'he93fe]:begin s05.tarActive <= 1'b1;s05.Adr <= m03.addrM;s05.dbus_in <= m03.DoutM;m03.DinMast <= s05.dataOut; end
		    [20'hf5342:20'hf5374]:begin s06.tarActive <= 1'b1;s06.Adr <= m03.addrM;s06.dbus_in <= m03.DoutM;m03.DinMast <= s06.dataOut; end
		    [20'hffc6a:20'hffd5a]:begin s07.tarActive <= 1'b1;s07.Adr <= m03.addrM;s07.dbus_in <= m03.DoutM;m03.DinMast <= s07.dataOut; end
		    [20'hf3064:20'hf3100]:begin s08.tarActive <= 1'b1;s08.Adr <= m03.addrM;s08.dbus_in <= m03.DoutM;m03.DinMast <= s08.dataOut; end
		    [20'hf7d12:20'hf7ded]:begin s09.tarActive <= 1'b1;s09.Adr <= m03.addrM;s09.dbus_in <= m03.DoutM;m03.DinMast <= s09.dataOut; end
		    [20'hf6513:20'hf6554]:begin s10.tarActive <= 1'b1;s10.Adr <= m03.addrM;s10.dbus_in <= m03.DoutM;m03.DinMast <= s10.dataOut; end
		    [20'hf4096:20'hf418a]:begin s11.tarActive <= 1'b1;s11.Adr <= m03.addrM;s11.dbus_in <= m03.DoutM;m03.DinMast <= s11.dataOut; end
		    [20'hfaac2:20'hfab79]:begin s12.tarActive <= 1'b1;s12.Adr <= m03.addrM;s12.dbus_in <= m03.DoutM;m03.DinMast <= s12.dataOut; end
	   	  [20'hf6066:20'hf610b]:begin s13.tarActive <= 1'b1;s13.Adr <= m03.addrM;s13.dbus_in <= m03.DoutM;m03.DinMast <= s13.dataOut; end
      endcase
    end

    (m04.YouGotIt):begin 
      case(m04.addrM[19:0]) inside 
		    [20'hf8ddc:20'hf8edc]:begin s00.tarActive <= 1'b1;s00.Adr <= m04.addrM;s00.dbus_in <= m04.DoutM;m04.DinMast <= s00.dataOut; end
		    [20'hf7015:20'hf7085]:begin s01.tarActive <= 1'b1;s01.Adr <= m04.addrM;s01.dbus_in <= m04.DoutM;m04.DinMast <= s01.dataOut; end
		    [20'hf58ce:20'hf58df]:begin s02.tarActive <= 1'b1;s02.Adr <= m04.addrM;s02.dbus_in <= m04.DoutM;m04.DinMast <= s02.dataOut; end
		    [20'hf3ca5:20'hf3d61]:begin s03.tarActive <= 1'b1;s03.Adr <= m04.addrM;s03.dbus_in <= m04.DoutM;m04.DinMast <= s03.dataOut; end
		    [20'he951f:20'he9553]:begin s04.tarActive <= 1'b1;s04.Adr <= m04.addrM;s04.dbus_in <= m04.DoutM;m04.DinMast <= s04.dataOut; end
		    [20'he93e5:20'he93fe]:begin s05.tarActive <= 1'b1;s05.Adr <= m04.addrM;s05.dbus_in <= m04.DoutM;m04.DinMast <= s05.dataOut; end
		    [20'hf5342:20'hf5374]:begin s06.tarActive <= 1'b1;s06.Adr <= m04.addrM;s06.dbus_in <= m04.DoutM;m04.DinMast <= s06.dataOut; end
		    [20'hffc6a:20'hffd5a]:begin s07.tarActive <= 1'b1;s07.Adr <= m04.addrM;s07.dbus_in <= m04.DoutM;m04.DinMast <= s07.dataOut; end
		    [20'hf3064:20'hf3100]:begin s08.tarActive <= 1'b1;s08.Adr <= m04.addrM;s08.dbus_in <= m04.DoutM;m04.DinMast <= s08.dataOut; end
		    [20'hf7d12:20'hf7ded]:begin s09.tarActive <= 1'b1;s09.Adr <= m04.addrM;s09.dbus_in <= m04.DoutM;m04.DinMast <= s09.dataOut; end
		    [20'hf6513:20'hf6554]:begin s10.tarActive <= 1'b1;s10.Adr <= m04.addrM;s10.dbus_in <= m04.DoutM;m04.DinMast <= s10.dataOut; end
		    [20'hf4096:20'hf418a]:begin s11.tarActive <= 1'b1;s11.Adr <= m04.addrM;s11.dbus_in <= m04.DoutM;m04.DinMast <= s11.dataOut; end
		    [20'hfaac2:20'hfab79]:begin s12.tarActive <= 1'b1;s12.Adr <= m04.addrM;s12.dbus_in <= m04.DoutM;m04.DinMast <= s12.dataOut; end
		    [20'hf6066:20'hf610b]:begin s13.tarActive <= 1'b1;s13.Adr <= m04.addrM;s13.dbus_in <= m04.DoutM;m04.DinMast <= s13.dataOut; end
      endcase
    end

    (m05.YouGotIt):begin 
      case(m05.addrM[19:0]) inside 
		    [20'hf8ddc:20'hf8edc]:begin s00.tarActive <= 1'b1;s00.Adr <= m05.addrM;s00.dbus_in <= m05.DoutM;m05.DinMast <= s00.dataOut; end
		    [20'hf7015:20'hf7085]:begin s01.tarActive <= 1'b1;s01.Adr <= m05.addrM;s01.dbus_in <= m05.DoutM;m05.DinMast <= s01.dataOut; end
		    [20'hf58ce:20'hf58df]:begin s02.tarActive <= 1'b1;s02.Adr <= m05.addrM;s02.dbus_in <= m05.DoutM;m05.DinMast <= s02.dataOut; end
		    [20'hf3ca5:20'hf3d61]:begin s03.tarActive <= 1'b1;s03.Adr <= m05.addrM;s03.dbus_in <= m05.DoutM;m05.DinMast <= s03.dataOut; end
		    [20'he951f:20'he9553]:begin s04.tarActive <= 1'b1;s04.Adr <= m05.addrM;s04.dbus_in <= m05.DoutM;m05.DinMast <= s04.dataOut; end
		    [20'he93e5:20'he93fe]:begin s05.tarActive <= 1'b1;s05.Adr <= m05.addrM;s05.dbus_in <= m05.DoutM;m05.DinMast <= s05.dataOut; end
		    [20'hf5342:20'hf5374]:begin s06.tarActive <= 1'b1;s06.Adr <= m05.addrM;s06.dbus_in <= m05.DoutM;m05.DinMast <= s06.dataOut; end
		    [20'hffc6a:20'hffd5a]:begin s07.tarActive <= 1'b1;s07.Adr <= m05.addrM;s07.dbus_in <= m05.DoutM;m05.DinMast <= s07.dataOut; end
		    [20'hf3064:20'hf3100]:begin s08.tarActive <= 1'b1;s08.Adr <= m05.addrM;s08.dbus_in <= m05.DoutM;m05.DinMast <= s08.dataOut; end
		    [20'hf7d12:20'hf7ded]:begin s09.tarActive <= 1'b1;s09.Adr <= m05.addrM;s09.dbus_in <= m05.DoutM;m05.DinMast <= s09.dataOut; end
		    [20'hf6513:20'hf6554]:begin s10.tarActive <= 1'b1;s10.Adr <= m05.addrM;s10.dbus_in <= m05.DoutM;m05.DinMast <= s10.dataOut; end
		    [20'hf4096:20'hf418a]:begin s11.tarActive <= 1'b1;s11.Adr <= m05.addrM;s11.dbus_in <= m05.DoutM;m05.DinMast <= s11.dataOut; end
		    [20'hfaac2:20'hfab79]:begin s12.tarActive <= 1'b1;s12.Adr <= m05.addrM;s12.dbus_in <= m05.DoutM;m05.DinMast <= s12.dataOut; end
		    [20'hf6066:20'hf610b]:begin s13.tarActive <= 1'b1;s13.Adr <= m05.addrM;s13.dbus_in <= m05.DoutM;m05.DinMast <= s13.dataOut; end
      endcase
    end

    (m06.YouGotIt):begin 
      case(m06.addrM[19:0]) inside 
		    [20'hf8ddc:20'hf8edc]:begin s00.tarActive <= 1'b1;s00.Adr <= m06.addrM;s00.dbus_in <= m06.DoutM;m06.DinMast <= s00.dataOut; end
		    [20'hf7015:20'hf7085]:begin s01.tarActive <= 1'b1;s01.Adr <= m06.addrM;s01.dbus_in <= m06.DoutM;m06.DinMast <= s01.dataOut; end
		    [20'hf58ce:20'hf58df]:begin s02.tarActive <= 1'b1;s02.Adr <= m06.addrM;s02.dbus_in <= m06.DoutM;m06.DinMast <= s02.dataOut; end
		    [20'hf3ca5:20'hf3d61]:begin s03.tarActive <= 1'b1;s03.Adr <= m06.addrM;s03.dbus_in <= m06.DoutM;m06.DinMast <= s03.dataOut; end
		    [20'he951f:20'he9553]:begin s04.tarActive <= 1'b1;s04.Adr <= m06.addrM;s04.dbus_in <= m06.DoutM;m06.DinMast <= s04.dataOut; end
		    [20'he93e5:20'he93fe]:begin s05.tarActive <= 1'b1;s05.Adr <= m06.addrM;s05.dbus_in <= m06.DoutM;m06.DinMast <= s05.dataOut; end
		    [20'hf5342:20'hf5374]:begin s06.tarActive <= 1'b1;s06.Adr <= m06.addrM;s06.dbus_in <= m06.DoutM;m06.DinMast <= s06.dataOut; end
		    [20'hffc6a:20'hffd5a]:begin s07.tarActive <= 1'b1;s07.Adr <= m06.addrM;s07.dbus_in <= m06.DoutM;m06.DinMast <= s07.dataOut; end
		    [20'hf3064:20'hf3100]:begin s08.tarActive <= 1'b1;s08.Adr <= m06.addrM;s08.dbus_in <= m06.DoutM;m06.DinMast <= s08.dataOut; end
		    [20'hf7d12:20'hf7ded]:begin s09.tarActive <= 1'b1;s09.Adr <= m06.addrM;s09.dbus_in <= m06.DoutM;m06.DinMast <= s09.dataOut; end
		    [20'hf6513:20'hf6554]:begin s10.tarActive <= 1'b1;s10.Adr <= m06.addrM;s10.dbus_in <= m06.DoutM;m06.DinMast <= s10.dataOut; end
		    [20'hf4096:20'hf418a]:begin s11.tarActive <= 1'b1;s11.Adr <= m06.addrM;s11.dbus_in <= m06.DoutM;m06.DinMast <= s11.dataOut; end
		    [20'hfaac2:20'hfab79]:begin s12.tarActive <= 1'b1;s12.Adr <= m06.addrM;s12.dbus_in <= m06.DoutM;m06.DinMast <= s12.dataOut; end
		    [20'hf6066:20'hf610b]:begin s13.tarActive <= 1'b1;s13.Adr <= m06.addrM;s13.dbus_in <= m06.DoutM;m06.DinMast <= s13.dataOut; end
      endcase
    end
	endcase

  //Disable slave on end of transaction by pulling down tarActive
  case(1'b1)
     (s00.Clast):begin s00.tarActive <= 0;end
     (s01.Clast):begin s01.tarActive <= 0;end
     (s02.Clast):begin s02.tarActive <= 0;end
     (s03.Clast):begin s03.tarActive <= 0;end
     (s04.Clast):begin s04.tarActive <= 0;end
     (s05.Clast):begin s05.tarActive <= 0;end
     (s06.Clast):begin s06.tarActive <= 0;end
     (s07.Clast):begin s07.tarActive <= 0;end
     (s08.Clast):begin s08.tarActive <= 0;end
     (s09.Clast):begin s09.tarActive <= 0;end
     (s10.Clast):begin s10.tarActive <= 0;end
     (s11.Clast):begin s11.tarActive <= 0;end
     (s12.Clast):begin s12.tarActive <= 0;end
     (s13.Clast):begin s13.tarActive <= 0;end
  endcase

  //Reset counter for every 500 cycles
  if(xfer_counter == 501)begin
  	xfer_counter <=0;
  	m00xfer_count<=0;
  	m01xfer_count<=0;
  	m02xfer_count<=0;
  	m03xfer_count<=0;
  	m04xfer_count<=0;
  	m05xfer_count<=0;
  	m06xfer_count<=0;
  end

  else begin
  //Arbitration algorithm - weighted priority
  if(idle)
  begin
      case(1'b1)
	    (m00.need): begin 
           		if(m00nsat)begin m00.YouGotIt <= 1;end
			        else if(m04neednsat)begin m04.YouGotIt <= 1;end
			        else if(m05neednsat)begin m05.YouGotIt <= 1;end      
			        else if(m03neednsat)begin m03.YouGotIt <= 1;end
			        else if(m01neednsat)begin m01.YouGotIt <= 1;end
			        else if(m02neednsat)begin m02.YouGotIt <= 1;end 
			        else if(m06neednsat)begin m06.YouGotIt <= 1;end
          		else if(m04.need) begin m04.YouGotIt <= 1;end 
			        else if(m05.need) begin m05.YouGotIt <= 1;end
			        else if(m03.need) begin m03.YouGotIt <= 1;end
			        else if(m01.need) begin m01.YouGotIt <= 1;end
			        else if(m02.need) begin m02.YouGotIt <= 1;end
           		else if(m06.need) begin m06.YouGotIt <= 1;end 
           		else begin m00.YouGotIt <= 1;end
			 end

		  (m04need): begin 
             	if(m04nsat)begin m04.YouGotIt <= 1;end
			        else if(m05neednsat)begin m05.YouGotIt <= 1;end      
			        else if(m03neednsat)begin m03.YouGotIt <= 1;end
			        else if(m01neednsat)begin m01.YouGotIt <= 1;end
			        else if(m02neednsat)begin m02.YouGotIt <= 1;end
			        else if(m06neednsat)begin m06.YouGotIt <= 1;end
			        else if(m05.need) begin m05.YouGotIt <= 1;end
			        else if(m03.need) begin m03.YouGotIt <= 1;end
			        else if(m01.need) begin m01.YouGotIt <= 1;end
			        else if(m02.need) begin m02.YouGotIt <= 1;end
			        else if(m06.need) begin m06.YouGotIt <= 1;end
			        else if(m00.need) begin m00.YouGotIt <= 1;end 
			        else begin m04.YouGotIt <= 1;end
			 end

	    (m05need): begin
             	if(m05nsat)begin m05.YouGotIt <= 1;end      
             	else if(m03neednsat)begin m03.YouGotIt <= 1;end
			        else if(m01neednsat)begin m01.YouGotIt <= 1;end
			        else if(m02neednsat)begin m02.YouGotIt <= 1;end
			        else if(m06neednsat)begin m06.YouGotIt <= 1;end		       
			        else if(m03.need) begin m03.YouGotIt <= 1;end
			        else if(m01.need) begin m01.YouGotIt <= 1;end
			        else if(m02.need) begin m02.YouGotIt <= 1;end
			        else if(m06.need) begin m06.YouGotIt <= 1;end
			        else if(m00.need) begin m00.YouGotIt <= 1;end
			        else if(m04.need) begin m04.YouGotIt <= 1;end 
			        else begin m05.YouGotIt <= 1;end
			 end

	   	(m03need): begin 
         	    if(m03nsat)begin m03.YouGotIt <= 1;end
			        else if(m01neednsat)begin m01.YouGotIt <= 1;end
			        else if(m02neednsat)begin m02.YouGotIt <= 1;end
			        else if(m06neednsat)begin m06.YouGotIt <= 1;end
			        else if(m01.need) begin m01.YouGotIt <= 1;end
			        else if(m02.need) begin m02.YouGotIt <= 1;end
			        else if(m06.need) begin m06.YouGotIt <= 1;end
			        else if(m00.need) begin m00.YouGotIt <= 1;end
			        else if(m04.need) begin m04.YouGotIt <= 1;end
			        else if(m05.need) begin m05.YouGotIt <= 1;end 
			        else begin m03.YouGotIt <= 1;end
			 end

	    (m01need): begin
            	if(m01nsat)begin m01.YouGotIt <= 1;end
			        else if(m02neednsat)begin m02.YouGotIt <= 1;end
			        else if(m06neednsat)begin m06.YouGotIt <= 1;end
			        else if(m02.need) begin m02.YouGotIt <= 1;end
			        else if(m06.need) begin m06.YouGotIt <= 1;end
			        else if(m00.need) begin m00.YouGotIt <= 1;end
			        else if(m04.need) begin m04.YouGotIt <= 1;end
			        else if(m05.need) begin m05.YouGotIt <= 1;end
			        else if(m03.need) begin m03.YouGotIt <= 1;end
			        else begin m01.YouGotIt <= 1;end
			 end

	     (m02need): begin 
             	if(m02nsat) begin m02.YouGotIt <= 1;end
			        else if(m06neednsat)begin m06.YouGotIt <= 1;end
			        else if(m06.need) begin m06.YouGotIt <= 1;end
			        else if(m00.need) begin m00.YouGotIt <= 1;end
			        else if(m04.need) begin m04.YouGotIt <= 1;end
			        else if(m05.need) begin m05.YouGotIt <= 1;end
			        else if(m03.need) begin m03.YouGotIt <= 1;end
			        else if(m01.need) begin m01.YouGotIt <= 1;end
			        else begin m02.YouGotIt <= 1;end
			 end

	     (m06need): begin 
             	if(m06nsat)begin m06.YouGotIt <= 1;end 
				      else if(m00.need) begin m00.YouGotIt <= 1;end
			        else if(m04.need) begin m04.YouGotIt <= 1;end
			        else if(m05.need) begin m05.YouGotIt <= 1;end
			        else if(m03.need) begin m03.YouGotIt <= 1;end
			        else if(m01.need) begin m01.YouGotIt <= 1;end
			        else if(m02.need) begin m02.YouGotIt <= 1;end
				      else begin m06.YouGotIt <= 1;end
      end
    endcase
  end
  
  //End of transaction, pull down grant (yougotit) and increment appropriate Mcounter, also track total transfers
  case(1'b1)
     (s00.Clast):begin 
     	case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s01.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s02.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s03.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s04.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s05.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s06.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s07.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s08.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s09.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s10.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s11.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s12.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
     (s13.Clast):begin 
     		case(1'b1)
     		(m00.YouGotIt):begin m00.YouGotIt <= 0;m00xfer_count<=m00xfer_count+1;end 
		    (m01.YouGotIt):begin m01.YouGotIt <= 0;m01xfer_count<=m01xfer_count+1;end
		    (m02.YouGotIt):begin m02.YouGotIt <= 0;m02xfer_count<=m02xfer_count+1;end
		    (m03.YouGotIt):begin m03.YouGotIt <= 0;m03xfer_count<=m03xfer_count+1;end
		    (m04.YouGotIt):begin m04.YouGotIt <= 0;m04xfer_count<=m04xfer_count+1;end 
		    (m05.YouGotIt):begin m05.YouGotIt <= 0;m05xfer_count<=m05xfer_count+1;end
		    (m06.YouGotIt):begin m06.YouGotIt <= 0;m06xfer_count<=m06xfer_count+1;end
	     endcase // 1'b1
	     xfer_counter <= xfer_counter +1;
	   end
  endcase
 end
end
endmodule
