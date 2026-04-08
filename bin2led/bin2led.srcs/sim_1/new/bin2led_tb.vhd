
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_bin2led is
end tb_bin2led;

architecture tb of tb_bin2led is

    component bin2led
        port (bin : in std_logic_vector (3 downto 0);
              led : out std_logic_vector (15 downto 0));
    end component;

    signal bin : std_logic_vector (3 downto 0);
    signal led : std_logic_vector (15 downto 0);

begin

    dut : bin2led
    port map (bin => bin,
              led => led);

    stimuli : process
    begin
        
        for i in 0 to 15 loop
            bin <= std_logic_vector(to_unsigned(i, 4));
            wait for 10 ns;
    
        end loop;
        wait;
    end process;

end tb;



configuration cfg_tb_bin2led of tb_bin2led is
    for tb
    end for;
end cfg_tb_bin2led;