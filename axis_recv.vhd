library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity axis_recv is
	generic (
		-- Users to add parameters here
        DATA_WIDTH	: integer	:= 8;
		-- User parameters ends
		-- Do not modify the parameters beyond this line

		-- Parameters of Axi Slave Bus Interface S00_AXIS
		C_S00_AXIS_TDATA_WIDTH	: integer	:= 8
	);
	port (
		-- Users to add ports here
		read_en : in std_logic;
		cpuDataOut : out  std_logic_vector(DATA_WIDTH-1 downto 0);
		rx_intr : out  std_logic;

		-- User ports ends
		-- Do not modify the ports beyond this line


		-- Ports of Axi Slave Bus Interface S00_AXIS
		s00_axis_aclk	: in std_logic;
		s00_axis_aresetn	: in std_logic;
		s00_axis_tready	: out std_logic;
		s00_axis_tdata	: in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
		s00_axis_tstrb	: in std_logic_vector((C_S00_AXIS_TDATA_WIDTH/8)-1 downto 0);
		s00_axis_tlast	: in std_logic;
		s00_axis_tvalid	: in std_logic
	);
end axis_recv;

architecture arch_imp of axis_recv is

component axis_register is 
	generic  (
	   WIDTH : integer
	);
port (
	clock : in std_logic;
	resetn : in std_logic;
	size :  out std_logic_vector(1 downto 0);
	idata : in std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
	ivalid : in std_logic;
	iready : out std_logic;
	odata : out std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
	ovalid : out std_logic;
	oready : in std_logic
	);
end component;

    signal osize: std_logic_vector(1 downto 0);
    signal dataOut: std_logic_vector(C_S00_AXIS_TDATA_WIDTH-1 downto 0);
    signal valid: std_logic;
    
begin

	data_reg: axis_register
	generic map (
	   WIDTH => C_S00_AXIS_TDATA_WIDTH
	)
	port map (
	   clock => s00_axis_aclk,
	   resetn => s00_axis_aresetn,
	   size => osize,
	   idata => s00_axis_tdata,
	   ivalid => s00_axis_tvalid,
	   iready => s00_axis_tready,
	   odata => dataOut,
	   ovalid => valid,
	   oready => read_en
	);

    rx_intr <= valid;
    
    valid_out: process (valid)
    begin
        
        if rising_edge(valid) then
            cpuDataOut <= dataOut;
        end if;
    
    end process;


end arch_imp;
