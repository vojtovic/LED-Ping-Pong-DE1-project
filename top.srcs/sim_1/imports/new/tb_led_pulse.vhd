library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_led_pulse is
end tb_led_pulse;

architecture tb of tb_led_pulse is

    signal clk     : std_logic := '0';
    signal rst     : std_logic;
    signal trigger : std_logic;
    signal tick    : std_logic;
    signal output  : std_logic;

    constant CLK_PERIOD : time := 10 ps;

begin

    dut : entity work.led_pulse
        port map (
            clk     => clk,
            rst     => rst,
            trigger => trigger,
            tick    => tick,
            output  => output
        );

    clk <= not clk after CLK_PERIOD / 2;

    process
    begin
        -- reset
        rst     <= '1';
        trigger <= '0';
        tick    <= '0';
        wait for 3 * CLK_PERIOD;
        assert output = '0'
            report "should be off after reset" severity error;
        rst <= '0';
        wait for CLK_PERIOD;

        -- trigger it
        trigger <= '1';
        wait for CLK_PERIOD;
        trigger <= '0';
        wait for CLK_PERIOD;
        assert output = '1'
            report "should be on after trigger" severity error;

        -- send 9 ticks, should still be on
        for i in 1 to 9 loop
            tick <= '1';
            wait for CLK_PERIOD;
            tick <= '0';
            wait for CLK_PERIOD;
        end loop;
        assert output = '1'
            report "should still be on after 9 ticks" severity error;

        -- 10th tick, should turn off
        tick <= '1';
        wait for CLK_PERIOD;
        tick <= '0';
        wait for CLK_PERIOD;
        assert output = '0'
            report "should be off after 10 ticks" severity error;

        -- stays off without trigger
        wait for 5 * CLK_PERIOD;
        assert output = '0'
            report "should stay off" severity error;

        -- trigger again, then reset mid-count
        trigger <= '1';
        wait for CLK_PERIOD;
        trigger <= '0';
        wait for CLK_PERIOD;
        assert output = '1'
            report "should be on after second trigger" severity error;

        -- send 3 ticks then reset
        for i in 1 to 3 loop
            tick <= '1';
            wait for CLK_PERIOD;
            tick <= '0';
            wait for CLK_PERIOD;
        end loop;
        rst <= '1';
        wait for CLK_PERIOD;
        assert output = '0'
            report "reset should turn it off" severity error;
        rst <= '0';

        report "tb_led_pulse: done";
        wait;
    end process;

end tb;
