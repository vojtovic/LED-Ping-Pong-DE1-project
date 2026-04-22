library ieee;
use ieee.std_logic_1164.all;

entity tb_debounce is
end tb_debounce;

architecture tb of tb_debounce is

    component debounce
        port (clk         : in std_logic;
              rst         : in std_logic;
              btn_in      : in std_logic;
              btn_state   : out std_logic;
              btn_press   : out std_logic;
              btn_release : out std_logic);
    end component;

    signal clk         : std_logic;
    signal rst         : std_logic;
    signal btn_in      : std_logic;
    signal btn_state   : std_logic;
    signal btn_press   : std_logic;
    signal btn_release : std_logic;

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : debounce
    port map (clk         => clk,
              rst         => rst,
              btn_in      => btn_in,
              btn_state   => btn_state,
              btn_press   => btn_press,
              btn_release => btn_release);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

        stimuli : process
    begin
        btn_in <= '0';

        -- Reset generation
        rst <= '1';
        wait for 50 ns;
        rst <= '0';

        -- Simulate button bounce on press
        report "Simulating button press with bounce";

        wait for 100 ns;
        btn_in <= '1';
        wait for 50 ns;
        btn_in <= '0';
        wait for 50 ns;
        btn_in <= '1';
        wait for 250 ns;
        btn_in <= '0';  -- Final stable press

        -- Simulate button bounce on release
        report "Simulating button release with bounce";

        wait for 20 ns;
        btn_in <= '1';
        wait for 60 ns;
        btn_in <= '0';
        wait for 30 ns;
        btn_in <= '1';
        wait for 50 ns;
        btn_in <= '0';  -- Final release
        wait for 300 ns;

        -- Stop the clock and hence terminate the simulation
        report "Simulation finished";
        TbSimEnded <= '1';
        wait;

    end process;

end tb;
