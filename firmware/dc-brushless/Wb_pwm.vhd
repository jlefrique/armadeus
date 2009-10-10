---------------------------------------------------------------------------
-- Company     : UTBM
-- Author(s)   : Julien Lefrique - Vincent Marotta
-- 
-- Creation Date : 12/12/2008
-- File          : Wb_pwm.vhd
--
-- Abstract : generation of a pwm signal
--
------------------------------------------------------------------------------------
-- This program is free software; you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation; either version 2, or (at your option)
-- any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program; if not, write to the Free Software
-- Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
----------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.STD_LOGIC_UNSIGNED.all;

-----------------------------------------------------------------------
	Entity Wb_pwm is 
-----------------------------------------------------------------------
    port 
    (
		-- Syscon signals
		gls_reset : in std_logic ;
		gls_clk	  : in std_logic ;
		-- Wishbone signals
		wbs_writedata : in std_logic_vector( 15 downto 0);
		wbs_readdata  : out std_logic_vector( 15 downto 0);
		wbs_strobe    : in std_logic ;
		wbs_write     : in std_logic ;
		wbs_ack	      : out std_logic;
		-- out signals
		pwm           : out std_logic
    );
end entity;
            


-----------------------------------------------------------------------
Architecture Wb_pwm_1 of Wb_pwm is
-----------------------------------------------------------------------
	signal reg : std_logic_vector( 15 downto 0);
	signal speed : std_logic_vector( 7 downto 0);
	signal count : std_logic_vector( 7 downto 0);

begin

-- connect speed
speed <= reg( 7 downto 0);

-- manage register
reg_bloc : process(gls_clk,gls_reset)
begin
	if gls_reset = '1' then 
		reg <= (others => '0');
	elsif rising_edge(gls_clk) then
		if ((wbs_strobe and wbs_write) = '1' ) then
			reg <= wbs_writedata;
		else
			reg <= reg;
		end if;
	end if;

end process reg_bloc;

pwm_bloc : process(gls_clk,gls_reset)
begin
	if gls_reset = '1' then
		count <= "00000000";
	elsif rising_edge(gls_clk) then
		if count >= speed then
			pwm <= '0';
		elsif count < speed then
			pwm <= '1';
		end if;
		if count = "11111111" then
			count <= "00000000";
		else 
			count <= count+1;
		end if;
	end if;
end process pwm_bloc;
		
wbs_ack <= wbs_strobe;
wbs_readdata <= reg;

end architecture Wb_pwm_1;
