library ieee;
use ieee.std_logic_1164.all;

entity debounce is
    generic (
        G_SHIFT_LEN : positive := 4;
        G_MAX       : positive := 200_000
    );
    port (
        clk         : in std_logic;
        rst         : in std_logic;
        btn_in      : in std_logic;
        btn_state   : out std_logic;
        btn_press   : out std_logic;
        btn_release : out std_logic
    );
end entity debounce;

architecture rtl of debounce is
    signal ce_sample : std_logic := '0';
    signal sync0     : std_logic := '0';
    signal sync1     : std_logic := '0';
    signal shift_reg : std_logic_vector(G_SHIFT_LEN - 1 downto 0) := (others => '0');
    signal debounced : std_logic := '0';
    signal delayed   : std_logic := '0';
begin
    clock_0 : entity work.clk_en
        generic map (
            G_MAX => G_MAX
        )
        port map (
            clk => clk,
            rst => rst,
            ce  => ce_sample
        );

    p_debounce : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sync0     <= '0';
                sync1     <= '0';
                shift_reg <= (others => '0');
                debounced <= '0';
                delayed   <= '0';
            else
                sync1 <= sync0;
                sync0 <= btn_in;

                if ce_sample = '1' then
                    shift_reg <= shift_reg(G_SHIFT_LEN - 2 downto 0) & sync1;

                    if shift_reg = (shift_reg'range => '1') then
                        debounced <= '1';
                    elsif shift_reg = (shift_reg'range => '0') then
                        debounced <= '0';
                    end if;
                end if;

                delayed <= debounced;
            end if;
        end if;
    end process;

    btn_state   <= debounced;
    btn_press   <= debounced and not delayed;
    btn_release <= delayed and not debounced;
end architecture rtl;
