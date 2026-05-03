library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity tb_speed_control is
end tb_speed_control;

architecture tb of tb_speed_control is

    signal clk      : std_logic := '0';
    signal rst      : std_logic;
    signal hit      : std_logic;
    signal new_game : std_logic;
    signal speed    : natural;

    constant CLK_PERIOD : time := 10 ps;
    constant DEFAULT_SPEED : positive := 1500;

begin

    dut : entity work.speed_control
        generic map (
            G_DEFAULT => DEFAULT_SPEED
        )
        port map (
            clk      => clk,
            rst      => rst,
            hit      => hit,
            new_game => new_game,
            speed    => speed
        );

    clk <= not clk after CLK_PERIOD / 2;

    process
    begin
        -- reset
        rst      <= '1';
        hit      <= '0';
        new_game <= '0';
        wait for 3 * CLK_PERIOD;
        assert speed = DEFAULT_SPEED
            report "should be default after reset" severity error;
        rst <= '0';
        wait for CLK_PERIOD;

        -- first hit: 1500 - 1500/15 = 1500 - 100 = 1400
        hit <= '1';
        wait for CLK_PERIOD;
        hit <= '0';
        wait for CLK_PERIOD;
        assert speed = 1400
            report "expected 1400 after 1 hit" severity error;

        -- second hit: 1400 - 1400/15 = 1400 - 93 = 1307
        hit <= '1';
        wait for CLK_PERIOD;
        hit <= '0';
        wait for CLK_PERIOD;
        assert speed = 1307
            report "expected 1307 after 2 hits" severity error;

        -- new_game should reset to default
        new_game <= '1';
        wait for CLK_PERIOD;
        new_game <= '0';
        wait for CLK_PERIOD;
        assert speed = DEFAULT_SPEED
            report "should reset to default on new_game" severity error;

        -- hit a bunch of times, speed should keep dropping
        for i in 1 to 20 loop
            hit <= '1';
            wait for CLK_PERIOD;
            hit <= '0';
            wait for CLK_PERIOD;
        end loop;
        assert speed < DEFAULT_SPEED
            report "speed should be less than default after hits" severity error;
        assert speed > 0
            report "speed should never reach 0" severity error;

        -- rst should also reset
        rst <= '1';
        wait for CLK_PERIOD;
        rst <= '0';
        wait for CLK_PERIOD;
        assert speed = DEFAULT_SPEED
            report "should reset to default on rst" severity error;

        report "tb_speed_control: done";
        wait;
    end process;

end tb;
