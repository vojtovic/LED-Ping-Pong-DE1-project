library ieee;
use ieee.std_logic_1164.all;

entity tb_clk_en is
end tb_clk_en;

architecture tb of tb_clk_en is

    component clk_en
        generic ( G_MAX : positive );
        port (clk     : in std_logic;
              rst     : in std_logic;
              ce      : out std_logic;
              max_val : in natural);
    end component;

    signal clk     : std_logic;
    signal rst     : std_logic;
    signal ce      : std_logic;
    signal max_val : natural;

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : clk_en
    generic map ( G_MAX => 10 )
    port map (clk     => clk,
              rst     => rst,
              ce      => ce,
              max_val => max_val);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
        max_val <= 0;

        
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 500 ns;

        max_val <= 5;
  
        wait for 400 ns;
        
        TbSimEnded <= '1';
        wait;
    end process;

end tb;


