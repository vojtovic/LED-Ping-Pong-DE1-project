library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ping_pong_top is
    generic (
        G_BALL_SPEED : positive := 7_000_000 --Lower = faster, higher = slower
    );
    port (
        clk      : in  std_logic; -- Hodiny z dosky
        rst      : in  std_logic; -- Reset tlačidlo
        btn_l_in : in  std_logic; -- Fyzické tlačidlo vľavo
        btn_r_in : in  std_logic; -- Fyzické tlačidlo vpravo
        led_g    : out std_logic; -- Zelená LED (hit)
        led_r    : out std_logic;
        led      : out std_logic_vector(15 downto 0);
        seg      : out std_logic_vector(6 downto 0);
        anode    : out std_logic_vector(7 downto 0)
    );
end entity ping_pong_top;

architecture Behavioral of ping_pong_top is 
-- Control Logic
    component control_logic is
        port (
            clk               : in  std_logic;
            rst               : in  std_logic;
            en                : in  std_logic;
            btn_r             : in  std_logic;
            btn_l             : in  std_logic;
            fcnt              : in  std_logic_vector(3 downto 0);
            bcnt              : in  std_logic_vector(3 downto 0);
            front_counter_rst : out std_logic;
            back_counter_rst  : out std_logic;
            use_back_counter  : out std_logic;
            hit_g             : out std_logic;
            hit_r             : out std_logic;
            new_game          : out std_logic
        );
    end component;
    
    component bin2led is
    Port ( bin : in STD_LOGIC_VECTOR (3 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0)
           );
    end component;

    component clk_en is
    generic (
        G_MAX : positive := 3
    );
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        ce      : out std_logic;
        max_val : in  natural := 0
    );
    end component;

    -- Reverse Counter (Back Counter)
    component reverse_counter is
        generic ( G_BITS : positive := 4 );
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            en       : in  std_logic;
            cnt      : out std_logic_vector(G_BITS - 1 downto 0);
            new_game : in  std_logic
        );
    end component;

    -- Forward Counter (Front Counter)
    component counter is
        generic ( G_BITS : positive := 4 ); -- Nastavené na 4 podľa control_logic
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            en       : in  std_logic;
            cnt      : out std_logic_vector(G_BITS - 1 downto 0);
            new_game : in  std_logic
        );
    end component;

    component display_driver is
        generic (
            G_CLK_DIV : positive := 80000
        );
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            data  : in  std_logic_vector(15 downto 0);
            seg   : out std_logic_vector(6 downto 0);
            anode : out std_logic_vector(7 downto 0)
        );
    end component;

    -- Debounce (pre tlačidlá)
    component debounce is
        port (
            clk         : in  std_logic;
            rst         : in  std_logic;
            btn_in      : in  std_logic;
            btn_state   : out std_logic;
            btn_press   : out std_logic;
            btn_release : out std_logic
        );
    end component;

signal fcnt_sig             : std_logic_vector(3 downto 0);
signal bcnt_sig             : std_logic_vector(3 downto 0);
signal bin_sig              : std_logic_vector(3 downto 0);
signal ce_sig               : std_logic;
signal rdeb_sig             : std_logic;
signal ldeb_sig             : std_logic;
signal f_rst_sig            : std_logic;
signal b_rst_sig            : std_logic;
signal new_game_sig         : std_logic;
signal use_back_counter_sig : std_logic;
signal hit_g_sig            : std_logic;
signal hit_r_sig            : std_logic;
signal score_sig            : unsigned(15 downto 0) := (others => '0');
signal speed_sig            : natural := 5_000_000;
signal green_timer          : natural range 0 to 50_000_000 := 0;

begin

    -- Riadiaca logika
    INST_CONTROL_LOGIC : control_logic
        port map (
            clk               => clk,
            rst               => rst,
            en                => ce_sig, 
            btn_r             => rdeb_sig,
            btn_l             => ldeb_sig,
            fcnt              => fcnt_sig,
            bcnt              => bcnt_sig,
            front_counter_rst => f_rst_sig,
            back_counter_rst  => b_rst_sig,
            use_back_counter  => use_back_counter_sig,
            hit_g             => hit_g_sig,
            hit_r             => hit_r_sig,
            new_game          => new_game_sig
        );
    
     INST_CLK_EN : clk_en
        generic map (
            G_MAX => G_BALL_SPEED
        )
        port map (
            clk     => clk,
            rst     => rst,
            ce      => ce_sig,
            max_val => speed_sig
        );
        
    INST_BIN2LED : bin2led
        port map (
            bin => bin_sig,
            led=> led
        );
    -- Dopredný čítač (Front Counter)
    INST_FRONT_COUNTER : counter
        generic map ( G_BITS => 4 )
        port map (
            clk      => clk,
            rst      => f_rst_sig,
            en       => ce_sig,
            cnt      => fcnt_sig,
            new_game => new_game_sig
        );

    -- Spätný čítač (Back Counter)
    INST_BACK_COUNTER : reverse_counter
        generic map ( G_BITS => 4 )
        port map (
            clk      => clk,
            rst      => b_rst_sig,
            en       => ce_sig,
            cnt      => bcnt_sig,
            new_game => new_game_sig
        );

    -- Debounce pre pravé tlačidlo
    INST_DEBOUNCE_R : debounce
        port map (
            rst => rst,
            clk         => clk,
            btn_in      => btn_r_in,
            btn_state   => open,
            btn_press   => rdeb_sig,
            btn_release => open
        );

    -- Debounce pre ľavé tlačidlo
    INST_DEBOUNCE_L : debounce
        port map (
            rst => rst,
            clk         => clk,
            btn_in      => btn_l_in,
            btn_state   => open,
            btn_press   => ldeb_sig,
            btn_release => open
        );
        
    bin_sig <= bcnt_sig when (use_back_counter_sig = '1') else fcnt_sig;

    p_green_led : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                green_timer <= 0;
            elsif hit_g_sig = '1' then
                green_timer <= 50_000_000;
            elsif green_timer > 0 then
                green_timer <= green_timer - 1;
            end if;
        end if;
    end process;

    led_g <= '1' when green_timer > 0 else '0';
    led_r <= hit_r_sig;

    p_score : process(clk)
        variable ones  : unsigned(3 downto 0);
        variable tens  : unsigned(3 downto 0);
        variable hunds : unsigned(3 downto 0);
        variable thous : unsigned(3 downto 0);
    begin
        if rising_edge(clk) then
            if rst = '1' then
                score_sig <= (others => '0');
            elsif hit_g_sig = '1' then
                ones  := score_sig(3 downto 0);
                tens  := score_sig(7 downto 4);
                hunds := score_sig(11 downto 8);
                thous := score_sig(15 downto 12);

                if ones < 9 then
                    ones := ones + 1;
                else
                    ones := (others => '0');
                    if tens < 9 then
                        tens := tens + 1;
                    else
                        tens := (others => '0');
                        if hunds < 9 then
                            hunds := hunds + 1;
                        else
                            hunds := (others => '0');
                            if thous < 9 then
                                thous := thous + 1;
                            end if;
                        end if;
                    end if;
                end if;

                score_sig <= thous & hunds & tens & ones;
            end if;
        end if;
    end process;

    -- Ball speeds up ~12% on each successful hit, resets on new game
    p_speed : process(clk)
        variable step : natural;
    begin
        if rising_edge(clk) then
            if rst = '1' or new_game_sig = '1' then
                speed_sig <= G_BALL_SPEED;
            elsif hit_g_sig = '1' then
                step := speed_sig / 15;
                if step = 0 then
                    step := 1;
                end if;
                if speed_sig > step then
                    speed_sig <= speed_sig - step;
                end if;
            end if;
        end if;
    end process;

    INST_DISPLAY : display_driver
        port map (
            clk   => clk,
            rst   => rst,
            data  => std_logic_vector(score_sig),
            seg   => seg,
            anode => anode
        );

end Behavioral;