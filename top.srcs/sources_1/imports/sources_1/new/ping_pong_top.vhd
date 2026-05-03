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

    component score_counter is
        port (
            clk   : in  std_logic;
            rst   : in  std_logic;
            hit   : in  std_logic;
            score : out std_logic_vector(15 downto 0)
        );
    end component;

    component led_pulse is
        port (
            clk     : in  std_logic;
            rst     : in  std_logic;
            trigger : in  std_logic;
            tick    : in  std_logic;
            output  : out std_logic
        );
    end component;

    component speed_control is
        generic (
            G_DEFAULT : positive := 7_000_000
        );
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            hit      : in  std_logic;
            new_game : in  std_logic;
            speed    : out natural
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
signal score_sig            : std_logic_vector(15 downto 0);
signal speed_sig            : natural;


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

    INST_GREEN_LED : led_pulse
        port map (
            clk     => clk,
            rst     => rst,
            trigger => hit_g_sig,
            tick    => ce_sig,
            output  => led_g
        );
    led_r <= hit_r_sig;

    INST_SCORE : score_counter
        port map (
            clk   => clk,
            rst   => rst,
            hit   => hit_g_sig,
            score => score_sig
        );

    INST_SPEED : speed_control
        generic map (
            G_DEFAULT => G_BALL_SPEED
        )
        port map (
            clk      => clk,
            rst      => rst,
            hit      => hit_g_sig,
            new_game => new_game_sig,
            speed    => speed_sig
        );

    INST_DISPLAY : display_driver
        port map (
            clk   => clk,
            rst   => rst,
            data  => score_sig,
            seg   => seg,
            anode => anode
        );

end Behavioral;