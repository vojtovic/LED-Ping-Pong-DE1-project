library ieee;
use ieee.std_logic_1164.all;

entity control_logic is
    generic (
        G_DEBOUNCE_SHIFT_LEN : positive := 4;
        G_DEBOUNCE_MAX       : positive := 2
    );
    port (
        clk               : in std_logic;
        rst               : in std_logic;
        en                : in std_logic;
        btn_r             : in std_logic;
        btn_l             : in std_logic;
        fcnt              : in std_logic_vector(3 downto 0);
        bcnt              : in std_logic_vector(3 downto 0);
        front_counter_rst : out std_logic;
        back_counter_rst  : out std_logic;
        use_back_counter  : out std_logic;
        hit_g             : out std_logic;
        hit_r             : out std_logic;
        new_game          : out std_logic
    );
end entity control_logic;

architecture Behavioral of control_logic is
    
    type state_type is (START, MOVE_RIGHT, MOVE_LEFT, GAME_OVER);
    signal current_state, next_state : state_type := START;
    
    constant G_MAX : integer := 10; 
    signal sig_cnt : integer range 0 to G_MAX := 0;
begin

    
    p_state_register : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_state <= START;
            else
                current_state <= next_state;
            end if;
        end if;
    end process;

    
    p_next_state_logic : process(current_state, btn_r, btn_l, bcnt, fcnt, sig_cnt, en)
    begin
        -- Defaultné hodnoty výstupov (aby nevznikali latche)
        next_state <= current_state; 
        hit_r <= '0';
        hit_g <= '0';
        front_counter_rst <= '1';
        back_counter_rst <= '1';
        new_game <= '0';

        case current_state is
            when START =>
                new_game <= '1';
                if btn_r = '1' or btn_l = '1' then
                    next_state <= MOVE_RIGHT;
                end if;

            when MOVE_LEFT =>
                back_counter_rst <= '0';
                front_counter_rst <='1';
                use_back_counter <= '1';
                new_game <= '0';
                if bcnt = "0000" then
                    if btn_l = '1' and sig_cnt < G_MAX then
                        next_state <= MOVE_RIGHT;
                        hit_g <= '1';
                    elsif sig_cnt = G_MAX  then
                        next_state <= GAME_OVER;
                        hit_r <= '1';
                    end if;
                end if;

            when MOVE_RIGHT =>
                front_counter_rst <= '0';
                back_counter_rst <= '1';
                if fcnt = "1111" then
                    if btn_r = '1' and sig_cnt < G_MAX then
                        next_state <= MOVE_LEFT;
                        hit_g <= '1';
                    elsif sig_cnt = G_MAX then
                        next_state <= GAME_OVER;
                        hit_r <= '1';
                    end if;
                end if;

            when GAME_OVER =>
                hit_r <= '1';
                new_game <= '1';
                if btn_r = '1' and btn_l = '1' then
                    next_state <= START;
                end if;
        end case;
    end process;

    -- Samostatný proces pre sig_cnt (lebo sig_cnt je register)
    p_timer : process(clk)
    begin
        if rising_edge(clk) then
            -- 1. Hard reset alebo stav START vždy nulujú počítadlo
            if rst = '1' or current_state = START then
                sig_cnt <= 0;
            
            -- 2. Logika pre zónu odrazu
            elsif (current_state = MOVE_RIGHT and fcnt = "1111") or 
                  (current_state = MOVE_LEFT and bcnt = "0000") then
                
                -- Ak sme v zóne, počítame (ak tikne 'en')
                if en = '1' then
                    if sig_cnt < G_MAX then
                        sig_cnt <= sig_cnt + 1;
                    end if;
                end if;
    
            else
                -- 3. Ak loptička NIE JE na okraji, sig_cnt MUSÍ byť 0
                sig_cnt <= 0;
            end if;
        end if;
end process;

end Behavioral;