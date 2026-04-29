

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;


entity bin2led is
    Port ( bin : in STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0));
end bin2led;

architecture Behavioral of bin2led is

begin

bin2led_decoder : process (bin) is 
    begin 
        case bin is
            
            when x"0" =>
                led <= b"1000_0000_0000_0000";
            when x"1" =>
                led <= b"0100_0000_0000_0000";
            when x"2" => 
                led <= b"0010_0000_0000_0000";
            when x"3" => 
                led <= b"0001_0000_0000_0000";
            when x"4" => 
                led <= b"0000_1000_0000_0000";
            when x"5" => 
                led <= b"0000_0100_0000_0000";
            when x"6" => 
                led <= b"0000_0010_0000_0000";
            when x"7" => 
                led <= b"0000_0001_0000_0000";
            when x"8" => 
                led <= b"0000_0000_1000_0000";
            when x"9" => 
                led <= b"0000_0000_0100_0000";
            when x"A" => 
                led <= b"0000_0000_0010_0000";
            when x"B" => 
                led <= b"0000_0000_0001_0000";
            when x"C" => 
                led <= b"0000_0000_0000_1000";
            when x"D" =>
                led <= b"0000_0000_0000_0100";  
            when x"E" =>
                led <= b"0000_0000_0000_0010"; 
            when x"F" =>
                led <= b"0000_0000_0000_0001"; 
            when others =>
                led <= b"0000_0000_0000_0000";
        
        end case;
    
    end process;


end Behavioral;