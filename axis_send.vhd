library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_send is
	generic (
		-- Users to add parameters here
		   DATA_WIDTH: integer	:= 8;

		-- User parameters ends
		-- Do not modify the parameters beyond this line


		-- Parameters of Axi Master Bus Interface M00_AXIS
		C_M00_AXIS_TDATA_WIDTH	: integer	:= 8;
		C_M00_AXIS_START_COUNT	: integer	:= 8
	);
	port (
		-- Users to add ports here
		cpu_clock : in std_logic; --clocks
        cpu_resetn : in std_logic;
        
        -- ram
        
        cpuDataOut   : in std_logic_vector(DATA_WIDTH-1 downto 0);
        cpu_enable : in std_logic; -- chip enables
        end_of_frame : in std_logic;
        tx_ack        : out   std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Master Bus Interface M00_AXIS
		m00_axis_aclk	: in std_logic;
		m00_axis_aresetn	: in std_logic;
		m00_axis_tvalid	: out std_logic;
		m00_axis_tdata	: out std_logic_vector(C_M00_AXIS_TDATA_WIDTH-1 downto 0);
		m00_axis_tstrb	: out std_logic_vector((C_M00_AXIS_TDATA_WIDTH/8)-1 downto 0) := (others => '1');
		m00_axis_tlast	: out std_logic;
		m00_axis_tready	: in std_logic
	);
end axis_send;

architecture arch_imp of axis_send is

      -- Memory FSM
    type state_type is (stIdle, stAddressPending, 
                        stWriteComplete, stComplete);  
    signal cState, nState : state_type := stIdle;
    
begin


	-- Add user logic her

	
	transmit : process (cpu_clock)
    begin
    
    if rising_edge(cpu_clock) then
	
	        case nState is
            when stIdle =>
                cState <= nState;  
                tx_ack <= '0';
                m00_axis_tvalid <= '0';
                m00_axis_tlast <= '0';
                
                if cpu_enable = '1' then
                    nState <= stAddressPending; --address changing
                end if;
            
            when stAddressPending => 
                cState <= nState;
                if m00_axis_tready = '1' then

                    m00_axis_tdata(DATA_WIDTH-1 downto 0) <=  cpuDataOut;
                    m00_axis_tvalid <= '1';
                    m00_axis_tlast <= end_of_frame;
                    nState <= stWriteComplete;
                end if;
                
            when stWriteComplete =>
            
                cState <= nState;
                m00_axis_tvalid <= '0';
                m00_axis_tlast <= '0';
                                
                if m00_axis_tready = '1' then
                    nState <= stComplete; 
                    tx_ack <= '1';
                end if;
                
            when stComplete =>
            
                cState <= nState;
                nState <= stIdle;
            
            end case;
        end if;

    end process; 

	-- User logic ends

end arch_imp;
