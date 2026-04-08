----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2026 12:36:07 PM
-- Design Name: 
-- Module Name: reverse_counter - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity reverse_counter is
 generic ( G_BITS : positive := 4 );  --! Default number of bits
    port (
        clk : in  std_logic;                             --! Main clock
        rst : in  std_logic;                             --! High-active synchronous reset
        en  : in  std_logic;                             --! Clock enable input
        cnt : out std_logic_vector(G_BITS - 1 downto 0)  --! Counter value
    );
end reverse_counter;

architecture Behavioral of reverse_counter is
    constant C_MAX : integer := 2**G_BITS - 1;

    -- Integer counter with defined range
    signal sig_cnt : integer range 0 to C_MAX;
begin

 p_counter : process (clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then    -- Synchronous, active-high reset
                sig_cnt <= C_MAX;

            elsif en = '1' then  -- Clock enable activated
                if sig_cnt = 0 then
                    sig_cnt <= C_MAX;
                else
                    sig_cnt <= sig_cnt - 1;
                end if;          -- Each `if` must end by `end if`
            end if;
        end if;
    end process p_counter;

    -- Convert integer to std_logic_vector
    cnt <= std_logic_vector(to_unsigned(sig_cnt, G_BITS));

end Behavioral;
