library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_counter is
end entity tb_counter;

architecture testbench of tb_counter is

    constant C_CLK_PERIOD : time := 10 ns;
    constant C_BITS       : positive := 4;

    signal clk      : std_logic := '0';
    signal rst      : std_logic;
    signal en       : std_logic;
    signal new_game : std_logic;
    signal cnt      : std_logic_vector(C_BITS - 1 downto 0);

begin

    uut : entity work.counter
        generic map (
            G_BITS => C_BITS
        )
        port map (
            clk      => clk,
            rst      => rst,
            en       => en,
            cnt      => cnt,
            new_game => new_game
        );

    p_clk : process is
    begin
        clk <= '0';
        wait for C_CLK_PERIOD / 2;
        clk <= '1';
        wait for C_CLK_PERIOD / 2;
    end process p_clk;

    p_stimulus : process is
    begin
        -- Initial reset
        rst      <= '1';
        en       <= '0';
        new_game <= '0';
        wait for 3 * C_CLK_PERIOD;
        assert unsigned(cnt) = 0
            report "Reset to 0 failed"
            severity error;

        -- New game reset (should go to 7)
        new_game <= '1';
        wait for C_CLK_PERIOD;
        assert unsigned(cnt) = 7
            report "New game reset to 7 failed"
            severity error;

        -- Release reset
        rst      <= '0';
        new_game <= '0';
        wait for C_CLK_PERIOD;

        -- Count up from 7 with enable
        en <= '1';
        for i in 8 to 15 loop
            wait for C_CLK_PERIOD;
            assert unsigned(cnt) = i
                report "Expected " & integer'image(i) &
                       " but got " & integer'image(to_integer(unsigned(cnt)))
                severity error;
        end loop;

        -- Verify saturation at max (15)
        wait for 3 * C_CLK_PERIOD;
        assert unsigned(cnt) = 15
            report "Saturation at max failed"
            severity error;

        -- Disable enable, counter should hold
        en <= '0';
        wait for 3 * C_CLK_PERIOD;
        assert unsigned(cnt) = 15
            report "Counter should hold when en='0'"
            severity error;

        -- Plain reset (no new_game) should go to 0
        rst <= '1';
        wait for C_CLK_PERIOD;
        assert unsigned(cnt) = 0
            report "Plain reset to 0 failed"
            severity error;
        rst <= '0';

        -- Count from 0
        en <= '1';
        for i in 1 to 5 loop
            wait for C_CLK_PERIOD;
            assert unsigned(cnt) = i
                report "Count from 0: expected " & integer'image(i) &
                       " but got " & integer'image(to_integer(unsigned(cnt)))
                severity error;
        end loop;

        en <= '0';
        wait for 2 * C_CLK_PERIOD;

        report "tb_counter: all tests passed";
        wait;
    end process p_stimulus;

end architecture testbench;
