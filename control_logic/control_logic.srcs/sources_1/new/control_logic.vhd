----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 19.04.2026 17:08:36
-- Design Name: control-logic
-- Module Name: control-logic - Behavioral
-- Project Name: Ping-Pong
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

entity control_logic is
    
    Port ( clk : in STD_LOGIC;
           btn_r : in STD_LOGIC;
           btn_l : in STD_LOGIC;
           hitg : out STD_LOGIC;
           hitr : out STD_LOGIC;
           fcnt : in STD_LOGIC_VECTOR (3 downto 0);
           bcnt : in STD_LOGIC_VECTOR (3 downto 0);
           back_counter_rst : out STD_LOGIC;
           front_counter_rst : out STD_LOGIC);
end control_logic;

architecture Behavioral of control_logic is
    
    signal start_bit : std_logic := '1';
    signal fcnt_rst  : std_logic := '0';
    signal bcnt_rst  : std_logic := '1';
    constant G_MAX: integer := 9 ; -- hit button delay (0,2 s)20000000
    
    signal sig_cnt : integer range 0 to G_MAX-1;

begin
    
    back_counter_rst <= bcnt_rst;
    front_counter_rst <= fcnt_rst;
    
    process (clk) is
    begin
    if rising_edge(clk) then 
        
        
        if fcnt = "0111" then   --compare value from front counter
             
               if sig_cnt /= G_MAX-1 and btn_r = '1' then
                    
                        hitg <= '1';
                        hitr <= '0';
                        sig_cnt <= 0;
                        bcnt_rst <= '0';
                        fcnt_rst <= '1';
                
                elsif sig_cnt = G_MAX-1 then
                        
                        hitr <= '1';
                        hitg <= '0';
                        sig_cnt <= 0;
                        bcnt_rst <= '0';
                        fcnt_rst <= '1';
                        
                else
                        hitg <= '0';
                        hitr <= '0';
                        bcnt_rst <= '1';
                        fcnt_rst <= '0';
                        sig_cnt <= sig_cnt+1;
                end if;  
               

   
   elsif bcnt = "0000" then
             
               if sig_cnt /= G_MAX-1 and btn_l = '1' then
                    
                        hitg <= '1';
                        hitr <= '0';
                        sig_cnt <= 0;
                        bcnt_rst <= '1';
                        fcnt_rst <= '0';
                
                elsif sig_cnt = G_MAX-1 then
                        
                        hitr <= '1';
                        hitg <= '0';
                        sig_cnt <= 0;
                        bcnt_rst <= '1';
                        fcnt_rst <= '0';
                        
                else
                        hitg <= '0';
                        hitr <= '0';
                        bcnt_rst <= '1';
                        fcnt_rst <= '0';
                        sig_cnt <= sig_cnt+1;
                end if;  
           
   else
       hitg <= '0';
       hitr <= '0';    
    end if;  
end if;  
   
end process; 
end Behavioral;
