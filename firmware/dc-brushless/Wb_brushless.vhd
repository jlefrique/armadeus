---------------------------------------------------------------------------
-- Company     : UTBM
-- Author(s)   : Julien Lefrique - Vincent Marotta
-- 
-- Creation Date : 12/12/2008
-- File          : Wb_brushless.vhd
--
-- Abstract : controller for DC Brushless motors
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

-----------------------------------------------------------------------
	Entity Wb_brushless is 
-----------------------------------------------------------------------
    port 
    (
		-- Syscon signals
		gls_reset 	  : in std_logic ;
		gls_clk	     : in std_logic ;
		-- Wishbone signals
		wbs_writedata : in std_logic_vector( 15 downto 0);
		wbs_readdata  : out std_logic_vector( 15 downto 0);
		wbs_strobe    : in std_logic ;
		wbs_write     : in std_logic ;
		wbs_ack	     : out std_logic;
		-- in signals
		pwm           : in std_logic;
		sensors       : in std_logic_vector( 2 downto 0);
		-- out signals
		phases_H      : out std_logic_vector( 2 downto 0);
		phases_L      : out std_logic_vector( 2 downto 0)
    );
end entity;


-----------------------------------------------------------------------
Architecture Wb_brushless_1 of Wb_brushless is
-----------------------------------------------------------------------
	signal reg : std_logic_vector( 15 downto 0);
	signal start : std_logic;
	signal direction : std_logic;
	type STATE_TYPE is (IDLE, INIT, RUN, STOP);
	signal state : STATE_TYPE;

begin

-- connect start and direction
start <= reg(9);
direction <= reg(8);

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

-- state diagram
state_diagram : process(gls_clk,gls_reset)
begin
	if gls_reset = '1' then
		state <= IDLE;
	elsif rising_edge(gls_clk) then
		case state is
			when IDLE =>
				if start = '1' then
					state <= INIT;
				elsif start = '0' then
					state <= IDLE;
				end if;
				
			when INIT =>
				-- Initialisations
				state <= RUN;
				
			when RUN =>
				if start = '0' then
					state <= STOP;
				elsif start = '1' then
					state <= RUN;
					if direction = '0' then
						-- clockwise
						case sensors is -- six states are possible
							when "001" => -- phase 6
								phases_H(2) <= '0';
								phases_H(1) <= '0';
								phases_H(0) <= pwm;
								phases_L <= "100";

							when "011" => -- phase 5
								phases_H(2) <= '0';
								phases_H(1) <= pwm;
								phases_H(0) <= '0';
								phases_L <= "100";
							
							when "010" => -- phase 4
								phases_H(2) <= '0';
								phases_H(1) <= pwm;
								phases_H(0) <= '0';
								phases_L <= "001";
							
							when "110" => -- phase 3
								phases_H(2) <= pwm;
								phases_H(1) <= '0';
								phases_H(0) <= '0';
								phases_L <= "001";
							
							when "100" => -- phase 2
								phases_H(2) <= pwm;
								phases_H(1) <= '0';
								phases_H(0) <= '0';
								phases_L <= "010";
							
							when "101" => -- phase 1
								phases_H(2) <= '0';
								phases_H(1) <= '0';
								phases_H(0) <= pwm;
								phases_L <= "010";
							
							when others =>
								phases_H <= "000";
								phases_L <= "000";	
						end case;
						
					elsif direction = '1' then
						-- counterclockwise
						case sensors is -- six states are possible
							when "001" => -- phase 6
								phases_H(2) <= pwm;
								phases_H(1) <= '0';
								phases_H(0) <= '0';
								phases_L <= "001";

							when "011" => -- phase 5
								phases_H(2) <= pwm;
								phases_H(1) <= '0';
								phases_H(0) <= '0';
								phases_L <= "010";
							
							when "010" => -- phase 4
								phases_H(2) <= '0';
								phases_H(1) <= '0';
								phases_H(0) <= pwm;
								phases_L <= "010";
							
							when "110" => -- phase 3
								phases_H(2) <= '0';
								phases_H(1) <= '0';
								phases_H(0) <= pwm;
								phases_L <= "100";
							
							when "100" => -- phase 2
								phases_H(2) <= '0';
								phases_H(1) <= pwm;
								phases_H(0) <= '0';
								phases_L <= "100";
							
							when "101" => -- phase 1
								phases_H(2) <= '0';
								phases_H(1) <= pwm;
								phases_H(0) <= '0';
								phases_L <= "001";
							
							when others =>
								phases_H <= "000";
								phases_L <= "000";	
						end case;
					end if;
				end if;
				
			when STOP =>
				-- Stop motors
				state <= IDLE;
				
			when others =>
				state <= state;
		end case;
	end if;
end process state_diagram;

wbs_ack <= wbs_strobe;
wbs_readdata <= reg;

end architecture Wb_brushless_1;

