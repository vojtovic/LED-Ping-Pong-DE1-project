library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_score_counter is
end tb_score_counter;

architecture tb of tb_score_counter is

    signal clk   : std_logic := '0';
    signal rst   : std_logic;
    signal hit   : std_logic;
    signal score : std_logic_vector(15 downto 0);

    constant CLK_PERIOD : time := 10 ps;

    -- helper signals for waveform
    signal ones  : integer range 0 to 15 := 0;
    signal tens  : integer range 0 to 15 := 0;
    signal hunds : integer range 0 to 15 := 0;
    signal thous : integer range 0 to 15 := 0;

begin

    dut : entity work.score_counter
        port map (
            clk   => clk,
            rst   => rst,
            hit   => hit,
            score => score
        );

    clk <= not clk after CLK_PERIOD / 2;

    ones  <= to_integer(unsigned(score(3 downto 0)));
    tens  <= to_integer(unsigned(score(7 downto 4)));
    hunds <= to_integer(unsigned(score(11 downto 8)));
    thous <= to_integer(unsigned(score(15 downto 12)));

    process
    begin
        -- reset
        rst <= '1';
        hit <= '0';
        wait for 3 * CLK_PERIOD;
        assert score = x"0000"
            report "reset failed" severity error;
        rst <= '0';

        -- count from 0 to 12
        for i in 1 to 12 loop
            hit <= '1';
            wait for CLK_PERIOD;
            hit <= '0';
            wait for CLK_PERIOD;
        end loop;
        assert score = x"0012"
            report "expected 0012" severity error;

        -- reset and check it clears
        rst <= '1';
        wait for CLK_PERIOD;
        assert score = x"0000"
            report "reset to 0000 failed" severity error;
        rst <= '0';
        wait for CLK_PERIOD;

        -- count to 10 (ones should roll over to tens)
        for i in 1 to 10 loop
            hit <= '1';
            wait for CLK_PERIOD;
            hit <= '0';
            wait for CLK_PERIOD;
        end loop;
        assert score = x"0010"
            report "expected 0010 after 10 hits" severity error;

        -- keep going to 100
        for i in 11 to 100 loop
            hit <= '1';
            wait for CLK_PERIOD;
            hit <= '0';
            wait for CLK_PERIOD;
        end loop;
        assert score = x"0100"
            report "expected 0100 after 100 hits" severity error;

        report "tb_score_counter: done";
        wait;
    end process;

end tb;
