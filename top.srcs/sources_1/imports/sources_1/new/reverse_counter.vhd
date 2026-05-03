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



entity reverse_counter is
 generic ( G_BITS : positive := 4 );  
    port (
        clk : in  std_logic;                             
        rst : in  std_logic;                             
        en  : in  std_logic;                             
        cnt : out std_logic_vector(G_BITS - 1 downto 0);
        new_game : in std_logic  
    );
end reverse_counter;

architecture Behavioral of reverse_counter is
    constant C_MAX : integer := 2**G_BITS - 1;

    
    signal sig_cnt : integer range 0 to C_MAX;
begin

 p_counter : process (clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then    
                if new_game = '1' then
                    sig_cnt <= 7;
                else
                    sig_cnt <= 15;
                end if;
            
            elsif en = '1' then  
                if sig_cnt = 0 then
                    sig_cnt <= 0;
                else
                    sig_cnt <= sig_cnt - 1;
                end if; 
            end if;            
        end if;
    end process p_counter;

    cnt <= std_logic_vector(to_unsigned(sig_cnt, G_BITS));

end Behavioral;