library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ping_pong_top is
end tb_ping_pong_top;

architecture tb of tb_ping_pong_top is

    component ping_pong_top
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            btn_l_in : in  std_logic;
            btn_r_in : in  std_logic;
            led_g    : out std_logic;
            led_r    : out std_logic;
            led      : out std_logic_vector(15 downto 0);
            seg      : out std_logic_vector(6 downto 0);
            anode    : out std_logic_vector(7 downto 0)
        );
    end component;

    -- DUT ports
    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal btn_l_in : std_logic := '0';
    signal btn_r_in : std_logic := '0';
    signal led_g    : std_logic;
    signal led_r    : std_logic;
    signal led      : std_logic_vector(15 downto 0);
    signal seg      : std_logic_vector(6 downto 0);
    signal anode    : std_logic_vector(7 downto 0);

    -- Counts led_g pulses so the running score is visible as a single waveform
    signal score_check : unsigned(7 downto 0) := (others => '0');

    constant TbPeriod  : time := 10 ns;  -- 100 MHz
    signal TbSimEnded  : std_logic := '0';

    -- Timing constants derived from design parameters:
    --   clk_en  G_MAX = 3   -> game tick every 30 ns
    --   debounce C_MAX = 2, C_SHIFT_LEN = 4  -> btn_press ~100 ns after button asserted
    --
    -- Ball travel times (from counter start until counter hits edge):
    --   MOVE_RIGHT first leg : fcnt 7->15 = 8 ticks  = 240 ns
    --   MOVE_LEFT  leg       : bcnt 15->0 = 15 ticks = 450 ns
    --   MOVE_RIGHT later leg : fcnt 0->15 = 16 ticks = 480 ns

begin

    dut : ping_pong_top
        port map (
            clk      => clk,
            rst      => rst,
            btn_l_in => btn_l_in,
            btn_r_in => btn_r_in,
            led_g    => led_g,
            led_r    => led_r,
            led      => led,
            seg      => seg,
            anode    => anode
        );

    clk <= not clk after TbPeriod / 2 when TbSimEnded /= '1' else '0';

    -- Track successful hits so score is visible as a numeric waveform
    p_score_check : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                score_check <= (others => '0');
            elsif led_g = '1' then
                score_check <= score_check + 1;
            end if;
        end if;
    end process;

    stimuli : process
    begin
        -- --------------------------------------------------------
        -- Reset
        -- --------------------------------------------------------
        btn_l_in <= '0';
        btn_r_in <= '0';
        rst      <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 50 ns;   -- let debounce settle after reset (t=150ns)

        -- --------------------------------------------------------
        -- HIT 0: start the game (any button press from START state)
        -- Debounce needs ~100 ns hold; btn_press fires at ~t=250ns.
        -- Counter loads 7 via new_game on the same clock.
        -- --------------------------------------------------------
        btn_r_in <= '1';
        wait for 200 ns;  -- t=350ns
        btn_r_in <= '0';
        -- game is now in MOVE_RIGHT, fcnt starting from 7

        -- --------------------------------------------------------
        -- HIT 1 (right edge): fcnt 7->15 takes 8*30=240ns from ~t=250ns
        -- Edge reached at ~t=490ns. Press well before window closes
        -- (window = 10 game-ticks = 300 ns).
        -- --------------------------------------------------------
        wait for 150 ns;  -- t=500ns - ball just hit the right edge
        btn_r_in <= '1';
        wait for 200 ns;  -- hold; btn_press at ~t=600ns -> hit_g, score=1
        btn_r_in <= '0';
        -- state -> MOVE_LEFT, bcnt starting from 15

        -- --------------------------------------------------------
        -- HIT 2 (left edge): bcnt 15->0 takes 15*30=450ns from ~t=600ns
        -- Edge reached at ~t=1050ns.
        -- --------------------------------------------------------
        wait for 460 ns;  -- t=1160ns - just past left edge
        btn_l_in <= '1';
        wait for 200 ns;  -- hold; btn_press at ~t=1260ns -> hit_g, score=2
        btn_l_in <= '0';
        -- state -> MOVE_RIGHT, fcnt starting from 0

        -- --------------------------------------------------------
        -- HIT 3 (right edge): fcnt 0->15 takes 16*30=480ns from ~t=1260ns
        -- Edge reached at ~t=1740ns.
        -- --------------------------------------------------------
        wait for 490 ns;  -- t=1750ns - just past right edge
        btn_r_in <= '1';
        wait for 200 ns;  -- hold; btn_press at ~t=1850ns -> hit_g, score=3
        btn_r_in <= '0';

        -- --------------------------------------------------------
        -- Done - let waveform settle then end
        -- --------------------------------------------------------
        wait for 300 ns;

        report "Simulation done. Check score_check signal (expected 3), seg/anode for display output.";
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
