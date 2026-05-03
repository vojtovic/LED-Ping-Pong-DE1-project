library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity display_driver is
    generic (
        G_CLK_DIV : positive := 80000  -- 80000 for 100 MHz -> ~1.25 kHz digit refresh
    );
    Port (
        clk   : in  STD_LOGIC;
        rst   : in  STD_LOGIC;
        data  : in  STD_LOGIC_VECTOR(15 downto 0);
        seg   : out STD_LOGIC_VECTOR(6 downto 0);
        anode : out STD_LOGIC_VECTOR(7 downto 0)
    );
end display_driver;

architecture Behavioral of display_driver is

    component clk_en is
        generic ( G_MAX : positive );
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            ce      : out std_logic;
            max_val : in  natural := 0
        );
    end component;

    component bin2seg is
        port (
            bin : in  std_logic_vector(3 downto 0);
            seg : out std_logic_vector(6 downto 0)
        );
    end component;

    signal sig_en      : std_logic;
    signal sig_digit   : unsigned(1 downto 0) := (others => '0');
    signal sig_bin     : std_logic_vector(3 downto 0);

begin

    clock_0 : clk_en
        generic map (
            G_MAX => G_CLK_DIV
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => sig_en,
            max_val => 0
        );

    -- interný 2-bit counter, už netreba samostatný counter.vhd
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sig_digit <= (others => '0');
            elsif sig_en = '1' then
                sig_digit <= sig_digit + 1;
            end if;
        end if;
    end process;

    with std_logic_vector(sig_digit) select
        sig_bin <= data(3 downto 0)    when "00",
                   data(7 downto 4)    when "01",
                   data(11 downto 8)   when "10",
                   data(15 downto 12)  when "11",
                   "0000"              when others;

    decoder_0 : bin2seg
        port map (
            bin => sig_bin,
            seg => seg
        );

    process(sig_digit)
    begin
        case std_logic_vector(sig_digit) is
            when "00" =>
                anode <= "11111110";
            when "01" =>
                anode <= "11111101";
            when "10" =>
                anode <= "11111011";
            when "11" =>
                anode <= "11110111";
            when others =>
                anode <= "11111111";
        end case;
    end process;

end Behavioral;
