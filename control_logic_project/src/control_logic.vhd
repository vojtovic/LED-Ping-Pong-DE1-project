library ieee;
use ieee.std_logic_1164.all;

entity control_logic is
    generic (
        G_DEBOUNCE_SHIFT_LEN : positive := 4;
        G_DEBOUNCE_MAX       : positive := 200_000
    );
    port (
        clk               : in std_logic;
        rst               : in std_logic;
        en                : in std_logic;
        btn_r_raw         : in std_logic;
        btn_l_raw         : in std_logic;
        fcnt              : in std_logic_vector(3 downto 0);
        bcnt              : in std_logic_vector(3 downto 0);
        front_counter_rst : out std_logic;
        back_counter_rst  : out std_logic;
        use_back_counter  : out std_logic;
        hit               : out std_logic
    );
end entity control_logic;

architecture rtl of control_logic is
    type t_state is (MOVE_RIGHT, MOVE_LEFT);
    signal state     : t_state := MOVE_RIGHT;
    signal hit_reg   : std_logic := '0';
    signal btn_r_deb : std_logic;
    signal btn_l_deb : std_logic;
begin
    debounce_r_i : entity work.debounce
        generic map (
            G_SHIFT_LEN => G_DEBOUNCE_SHIFT_LEN,
            G_MAX       => G_DEBOUNCE_MAX
        )
        port map (
            clk         => clk,
            rst         => rst,
            btn_in      => btn_r_raw,
            btn_state   => open,
            btn_press   => btn_r_deb,
            btn_release => open
        );

    debounce_l_i : entity work.debounce
        generic map (
            G_SHIFT_LEN => G_DEBOUNCE_SHIFT_LEN,
            G_MAX       => G_DEBOUNCE_MAX
        )
        port map (
            clk         => clk,
            rst         => rst,
            btn_in      => btn_l_raw,
            btn_state   => open,
            btn_press   => btn_l_deb,
            btn_release => open
        );

    p_fsm : process (clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state   <= MOVE_RIGHT;
                hit_reg <= '0';
            else
                hit_reg <= '0';
                case state is
                    when MOVE_RIGHT =>
                        if en = '1' and fcnt = x"F" then
                            if btn_r_deb = '1' then
                                state <= MOVE_LEFT;
                            else
                                hit_reg <= '1';
                            end if;
                        end if;

                    when MOVE_LEFT =>
                        if en = '1' and bcnt = x"0" then
                            if btn_l_deb = '1' then
                                state <= MOVE_RIGHT;
                            else
                                hit_reg <= '1';
                            end if;
                        end if;
                end case;
            end if;
        end if;
    end process;

    front_counter_rst <= '0' when state = MOVE_RIGHT else '1';
    back_counter_rst  <= '1' when state = MOVE_RIGHT else '0';
    use_back_counter  <= '0' when state = MOVE_RIGHT else '1';
    hit               <= hit_reg;
end architecture rtl;
