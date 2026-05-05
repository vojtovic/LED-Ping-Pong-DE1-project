library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_display_driver is
end tb_display_driver;

architecture tb of tb_display_driver is

    signal clk   : std_logic := '0';
    signal rst   : std_logic := '1';
    signal data  : std_logic_vector(15 downto 0) := (others => '0');
    signal seg   : std_logic_vector(6 downto 0);
    signal anode : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10000 ps;
    constant CYCLE      : time := 160000 ps;
    signal done         : std_logic := '0';

    -- which digit is on right now (0-3)
    signal which_digit : integer range 0 to 3 := 0;

    -- the nibble value on display
    signal showing : integer range 0 to 15 := 0;

    -- individual segments so you can see them in waveform
    --       aaa
    --      f   b
    --       ggg
    --      e   c
    --       ddd
    -- active low: '0' = ON, '1' = OFF
    signal seg_a : std_logic;
    signal seg_b : std_logic;
    signal seg_c : std_logic;
    signal seg_d : std_logic;
    signal seg_e : std_logic;
    signal seg_f : std_logic;
    signal seg_g : std_logic;

begin

    dut : entity work.display_driver
        generic map (G_CLK_DIV => 4)
        port map (
            clk   => clk,
            rst   => rst,
            data  => data,
            seg   => seg,
            anode => anode
        );

    clk <= not clk after CLK_PERIOD / 2 when done /= '1' else '0';

    -- break out segments
    seg_a <= seg(0);
    seg_b <= seg(1);
    seg_c <= seg(2);
    seg_d <= seg(3);
    seg_e <= seg(4);
    seg_f <= seg(5);
    seg_g <= seg(6);

    -- figure out which digit is active
    process(anode, data)
        variable nib : integer;
    begin
        case anode is
            when "11111110" => which_digit <= 0; nib := to_integer(unsigned(data(3 downto 0)));
            when "11111101" => which_digit <= 1; nib := to_integer(unsigned(data(7 downto 4)));
            when "11111011" => which_digit <= 2; nib := to_integer(unsigned(data(11 downto 8)));
            when "11110111" => which_digit <= 3; nib := to_integer(unsigned(data(15 downto 12)));
            when others     => which_digit <= 0; nib := 0;
        end case;
        showing <= nib;
    end process;

    -- test it
    process
    begin
        rst  <= '1';
        data <= x"0000";
        wait for 3 * CLK_PERIOD;
        rst  <= '0';

        -- show 0
        data <= x"0000";
        wait for 2 * CYCLE;

        -- show 1
        data <= x"0001";
        wait for 2 * CYCLE;

        -- show 10
        data <= x"0010";
        wait for 2 * CYCLE;

        done <= '1';
        wait;
    end process;

end tb;
