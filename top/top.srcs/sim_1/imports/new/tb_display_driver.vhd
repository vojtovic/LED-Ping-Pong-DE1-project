library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_display_driver is
end tb_display_driver;

architecture tb of tb_display_driver is

    component display_driver
        generic (
            G_CLK_DIV : positive := 80000
        );
        port (
            clk   : in  STD_LOGIC;
            rst   : in  STD_LOGIC;
            data  : in  STD_LOGIC_VECTOR(15 downto 0);
            seg   : out STD_LOGIC_VECTOR(6 downto 0);
            anode : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal data  : std_logic_vector(15 downto 0) := (others => '0');
    signal seg   : std_logic_vector(6 downto 0);
    signal anode : std_logic_vector(7 downto 0);

    constant TbPeriod   : time := 10 ns;
    constant CYCLE_TIME : time := 160 ns;
    signal TbSimEnded   : std_logic := '0';

    type seg_lut_t is array (0 to 15) of std_logic_vector(6 downto 0);
    constant SEG_LUT : seg_lut_t := (
        0  => "0000001",  -- 0
        1  => "1001111",  -- 1
        2  => "0010010",  -- 2
        3  => "0000110",  -- 3
        4  => "1001100",  -- 4
        5  => "0100100",  -- 5
        6  => "0100000",  -- 6
        7  => "0001111",  -- 7
        8  => "0000000",  -- 8
        9  => "0000100",  -- 9
        10 => "0001000",  -- A
        11 => "1100000",  -- b
        12 => "0110001",  -- C
        13 => "1000010",  -- d
        14 => "0110000",  -- E
        15 => "0111000"   -- F
    );

begin

    dut : display_driver
        generic map (
            G_CLK_DIV => 4
        )
        port map (
            clk   => clk,
            rst   => rst,
            data  => data,
            seg   => seg,
            anode => anode
        );

    clk <= not clk after TbPeriod / 2 when TbSimEnded /= '1' else '0';

    -- Drive test data
    stimuli : process
    begin
        rst  <= '1';
        data <= x"0000";
        wait for 100 ns;
        rst  <= '0';

        -- T01: all zeros
        data <= x"0000";
        wait for 3 * CYCLE_TIME;

        -- T02: score = 3
        data <= x"0003";
        wait for 3 * CYCLE_TIME;

        -- T03: score = 15 (hex F in digit 0)
        data <= x"000F";
        wait for 3 * CYCLE_TIME;

        -- T04: each digit different
        data <= x"1234";
        wait for 3 * CYCLE_TIME;

        -- T05: all 8s (every segment on)
        data <= x"8888";
        wait for 3 * CYCLE_TIME;

        -- T06: hex A-D
        data <= x"ABCD";
        wait for 3 * CYCLE_TIME;

        -- T07: all F's
        data <= x"FFFF";
        wait for 3 * CYCLE_TIME;

        -- T08: digits 9-8-7-6
        data <= x"9876";
        wait for 3 * CYCLE_TIME;

        -- T09: digits 5-4-3-2
        data <= x"5432";
        wait for 3 * CYCLE_TIME;

        -- T10: single non-zero in digit 0
        data <= x"0001";
        wait for 3 * CYCLE_TIME;

        -- T11: single non-zero in digit 1
        data <= x"0020";
        wait for 3 * CYCLE_TIME;

        -- T12: single non-zero in digit 2
        data <= x"0300";
        wait for 3 * CYCLE_TIME;

        -- T13: single non-zero in digit 3
        data <= x"4000";
        wait for 3 * CYCLE_TIME;

        -- T14: alternating nibbles A0A0
        data <= x"A0A0";
        wait for 3 * CYCLE_TIME;

        -- T15: alternating nibbles 0B0B
        data <= x"0B0B";
        wait for 3 * CYCLE_TIME;

        -- T16: all 1s (fewest segments lit)
        data <= x"1111";
        wait for 3 * CYCLE_TIME;

        -- T17: E/F boundary
        data <= x"EFFE";
        wait for 3 * CYCLE_TIME;

        -- T18: mid-operation reset
        data <= x"DEAD";
        wait for 80 ns;
        rst <= '1';
        wait for 60 ns;
        rst <= '0';
        wait for 3 * CYCLE_TIME;

        -- T19: rapid data changes (one cycle each)
        data <= x"1111";
        wait for CYCLE_TIME;
        data <= x"2222";
        wait for CYCLE_TIME;
        data <= x"3333";
        wait for 3 * CYCLE_TIME;

        -- T20: clear back to zero after all-F
        data <= x"FFFF";
        wait for CYCLE_TIME;
        data <= x"0000";
        wait for 3 * CYCLE_TIME;

        report "Stimuli complete." severity note;
        TbSimEnded <= '1';
        wait;
    end process;

    -- Automatic checker: verifies seg matches expected on every falling edge
    checker : process
        variable nibble   : integer;
        variable expected : std_logic_vector(6 downto 0);
    begin
        loop
            wait until falling_edge(clk);
            exit when TbSimEnded = '1';
            if rst = '0' then
                case anode is
                    when "11111110" =>
                        nibble   := to_integer(unsigned(data(3 downto 0)));
                        expected := SEG_LUT(nibble);
                        assert seg = expected
                            report "digit0 FAIL: nibble=" & integer'image(nibble)
                            severity error;
                    when "11111101" =>
                        nibble   := to_integer(unsigned(data(7 downto 4)));
                        expected := SEG_LUT(nibble);
                        assert seg = expected
                            report "digit1 FAIL: nibble=" & integer'image(nibble)
                            severity error;
                    when "11111011" =>
                        nibble   := to_integer(unsigned(data(11 downto 8)));
                        expected := SEG_LUT(nibble);
                        assert seg = expected
                            report "digit2 FAIL: nibble=" & integer'image(nibble)
                            severity error;
                    when "11110111" =>
                        nibble   := to_integer(unsigned(data(15 downto 12)));
                        expected := SEG_LUT(nibble);
                        assert seg = expected
                            report "digit3 FAIL: nibble=" & integer'image(nibble)
                            severity error;
                    when others =>
                        null;
                end case;
            end if;
        end loop;
        report "Checker done: no assertion failures means all tests PASSED." severity note;
        wait;
    end process;

end tb;
