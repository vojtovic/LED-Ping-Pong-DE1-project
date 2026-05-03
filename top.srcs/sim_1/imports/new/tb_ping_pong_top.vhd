library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_ping_pong_top is
end tb_ping_pong_top;

architecture tb of tb_ping_pong_top is

    component ping_pong_top
        generic (
            G_BALL_SPEED : positive := 7_000_000
        );
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

    signal clk      : std_logic := '0';
    signal rst      : std_logic := '0';
    signal btn_l_in : std_logic := '0';
    signal btn_r_in : std_logic := '0';
    signal led_g    : std_logic;
    signal led_r    : std_logic;
    signal led      : std_logic_vector(15 downto 0);
    signal seg      : std_logic_vector(6 downto 0);
    signal anode    : std_logic_vector(7 downto 0);

    constant TbPeriod : time := 10 ns;
    signal TbSimEnded : std_logic := '0';

    -- ===== HELPER SIGNALS - pridej do waveform =====

    -- pozice micku (0-15), spocitana z led one-hot
    signal ball_pos : integer range 0 to 15 := 0;

    -- kolikaty hit (pocita nabeznymi hranami led_g)
    signal hit_count  : integer range 0 to 255 := 0;
    signal led_g_prev : std_logic := '0';

    -- co se prave deje v testu
    -- 0=reset, 1=start hry, 2=micek leti doprava
    -- 3=hit vpravo, 4=micek leti doleva, 5=hit vlevo
    -- 6=micek leti doprava, 7=hit vpravo, 8=miss, 9=game over, 10=restart
    signal test_phase : integer range 0 to 10 := 0;

begin

    dut : ping_pong_top
        generic map (
            G_BALL_SPEED => 3
        )
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

    -- pozice micku z one-hot led
    p_ball_pos : process(led)
    begin
        ball_pos <= 0;
        for i in 0 to 15 loop
            if led(i) = '1' then
                ball_pos <= i;
            end if;
        end loop;
    end process;

    -- pocitadlo hitu
    p_hit_count : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hit_count  <= 0;
                led_g_prev <= '0';
            else
                led_g_prev <= led_g;
                if led_g = '1' and led_g_prev = '0' then
                    hit_count <= hit_count + 1;
                end if;
            end if;
        end if;
    end process;

    stimuli : process
    begin
        -- PHASE 0: reset
        test_phase <= 0;
        btn_l_in <= '0';
        btn_r_in <= '0';
        rst      <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 50 ns;

        -- PHASE 1: start hry - stisknu prave tlacitko
        -- micek startuje uprostred (pozice 7), FSM prejde do MOVE_RIGHT
        test_phase <= 1;
        btn_r_in <= '1';
        wait for 200 ns;
        btn_r_in <= '0';

        -- PHASE 2: micek leti doprava (7 -> 15)
        -- 8 ticku * 30 ns = 240 ns
        test_phase <= 2;
        wait for 150 ns;

        -- PHASE 3: micek dorazil vpravo, stisknu prave tlacitko = HIT
        -- FSM prejde do MOVE_LEFT, score +1
        test_phase <= 3;
        btn_r_in <= '1';
        wait for 200 ns;
        btn_r_in <= '0';

        -- PHASE 4: micek leti doleva (15 -> 0)
        -- 15 ticku * 30 ns = 450 ns
        test_phase <= 4;
        wait for 460 ns;

        -- PHASE 5: micek dorazil vlevo, stisknu leve tlacitko = HIT
        -- FSM prejde do MOVE_RIGHT, score +1
        test_phase <= 5;
        btn_l_in <= '1';
        wait for 200 ns;
        btn_l_in <= '0';

        -- PHASE 6: micek leti doprava (0 -> 15)
        -- 16 ticku * 30 ns = 480 ns
        test_phase <= 6;
        wait for 490 ns;

        -- PHASE 7: micek dorazil vpravo, stisknu = HIT
        -- score +1 (celkem 3)
        test_phase <= 7;
        btn_r_in <= '1';
        wait for 200 ns;
        btn_r_in <= '0';

        -- PHASE 8: micek leti doleva, tentokrat NESTISKNU = MISS
        -- bcnt 15->0 = 450 ns, pak timer 10 ticku = 300 ns
        test_phase <= 8;
        wait for 800 ns;

        -- PHASE 9: game over - led_r by mela svitit
        test_phase <= 9;
        wait for 200 ns;

        -- PHASE 10: restart - obe tlacitka naraz
        test_phase <= 10;
        btn_l_in <= '1';
        btn_r_in <= '1';
        wait for 200 ns;
        btn_l_in <= '0';
        btn_r_in <= '0';
        wait for 200 ns;

        report "Simulation done.";
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
