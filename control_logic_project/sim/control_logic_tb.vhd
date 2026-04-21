library ieee;
use ieee.std_logic_1164.all;

entity control_logic_tb is
end entity control_logic_tb;

architecture tb of control_logic_tb is
    signal clk               : std_logic := '0';
    signal en                : std_logic := '0';
    signal rst               : std_logic := '1';
    signal btn_r_raw         : std_logic := '0';
    signal btn_l_raw         : std_logic := '0';
    signal fcnt              : std_logic_vector(3 downto 0) := (others => '0');
    signal bcnt              : std_logic_vector(3 downto 0) := (others => '0');
    signal front_counter_rst : std_logic;
    signal back_counter_rst  : std_logic;
    signal use_back_counter  : std_logic;
    signal hit               : std_logic;
    signal phase             : std_logic_vector(3 downto 0) := (others => '0');
    signal at_right_edge     : std_logic;
    signal at_left_edge      : std_logic;

    constant C_CLK_PER : time := 10 ns;
begin
    clk <= not clk after C_CLK_PER/2;
    at_right_edge <= '1' when fcnt = x"F" else '0';
    at_left_edge  <= '1' when bcnt = x"0" else '0';

    dut : entity work.control_logic
        generic map (
            G_DEBOUNCE_SHIFT_LEN => 4,
            G_DEBOUNCE_MAX       => 2
        )
        port map (
            clk               => clk,
            rst               => rst,
            en                => en,
            btn_r_raw         => btn_r_raw,
            btn_l_raw         => btn_l_raw,
            fcnt              => fcnt,
            bcnt              => bcnt,
            front_counter_rst => front_counter_rst,
            back_counter_rst  => back_counter_rst,
            use_back_counter  => use_back_counter,
            hit               => hit
        );

    p_stim : process
    begin
        -- PHASE 0: Reset
        phase <= x"0";
        wait for 4 * C_CLK_PER;
        rst <= '0';
        wait for 4 * C_CLK_PER;

        assert (front_counter_rst = '0' and back_counter_rst = '1' and use_back_counter = '0')
            report "Initial state is not MOVE_RIGHT" severity error;

        -- PHASE 1: en=0, no reaction even at edge
        phase <= x"1";
        fcnt <= x"F";
        en <= '0';
        wait for 4 * C_CLK_PER;
        assert hit = '0' report "Hit should stay 0 when en=0" severity error;

        -- Enable FSM decisions
        en <= '1';
        wait for 2 * C_CLK_PER;

        -- PHASE 2: Right-side miss (expect one-cycle hit pulse)
        phase <= x"2";
        fcnt <= x"F";
        btn_r_raw <= '0';
        wait for 2 * C_CLK_PER;
        assert hit = '1' report "Expected hit on right-side miss" severity error;
        wait for 2 * C_CLK_PER;
        assert hit = '0' report "Hit must be one clock pulse" severity error;
        wait for 4 * C_CLK_PER;

        -- PHASE 3: Right button bounce (should not switch direction)
        phase <= x"3";
        btn_r_raw <= '1';
        wait for C_CLK_PER;
        btn_r_raw <= '0';
        wait for C_CLK_PER;
        btn_r_raw <= '1';
        wait for C_CLK_PER;
        btn_r_raw <= '0';
        wait for 6 * C_CLK_PER;
        assert use_back_counter = '0'
            report "Bounce should not switch to MOVE_LEFT" severity error;

        -- PHASE 4: Valid right press (should switch to MOVE_LEFT)
        phase <= x"4";
        btn_r_raw <= '1';
        wait for 12 * C_CLK_PER;
        btn_r_raw <= '0';
        wait for 8 * C_CLK_PER;
        assert (use_back_counter = '1' and front_counter_rst = '1' and back_counter_rst = '0')
            report "Expected state MOVE_LEFT after right button press" severity error;
        wait for 4 * C_CLK_PER;

        -- PHASE 5: Left-side miss (expect one-cycle hit pulse)
        phase <= x"5";
        bcnt <= x"0";
        btn_l_raw <= '0';
        wait for 2 * C_CLK_PER;
        assert hit = '1' report "Expected hit on left-side miss" severity error;
        wait for 2 * C_CLK_PER;
        assert hit = '0' report "Hit must be one clock pulse" severity error;
        wait for 4 * C_CLK_PER;

        -- PHASE 6: Valid left press (should switch back to MOVE_RIGHT)
        phase <= x"6";
        btn_l_raw <= '1';
        wait for 12 * C_CLK_PER;
        btn_l_raw <= '0';
        wait for 8 * C_CLK_PER;
        assert use_back_counter = '0'
            report "Expected state MOVE_RIGHT after left button press" severity error;
        wait for 4 * C_CLK_PER;

        -- PHASE 7: en=0 again, no reaction at edge
        phase <= x"7";
        en <= '0';
        fcnt <= x"F";
        bcnt <= x"0";
        btn_r_raw <= '1';
        btn_l_raw <= '1';
        wait for 10 * C_CLK_PER;
        assert hit = '0' report "Hit should stay 0 when en=0 (final check)" severity error;

        report "control_logic_tb PASSED" severity note;
        wait;
    end process;
end architecture tb;
