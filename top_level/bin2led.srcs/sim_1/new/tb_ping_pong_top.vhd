library ieee;
use ieee.std_logic_1164.all;

entity tb_ping_pong_top is
end tb_ping_pong_top;

architecture tb of tb_ping_pong_top is

    component ping_pong_top
        port (clk      : in std_logic;
              rst      : in std_logic;
              btn_l_in : in std_logic;
              btn_r_in : in std_logic;
              led_g    : out std_logic;
              led_r    : out std_logic;
              led      : out std_logic_vector (15 downto 0));
    end component;

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal btn_l_in : std_logic;
    signal btn_r_in : std_logic;
    signal led_g    : std_logic;
    signal led_r    : std_logic;
    signal led      : std_logic_vector (15 downto 0);

    constant TbPeriod : time := 10 ns; 
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : ping_pong_top
    port map (clk      => clk,
              rst      => rst,
              btn_l_in => btn_l_in,
              btn_r_in => btn_r_in,
              led_g    => led_g,
              led_r    => led_r,
              led      => led);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    clk <= TbClock;

    stimuli : process
    begin
        -- Inicializácia
        btn_l_in <= '0';
        btn_r_in <= '0';
        rst <= '1';
        wait for 100 ns;
        rst <= '0';
        wait for 100 ns;

        
        btn_r_in <= '1';
        wait for 100 ns; 
        btn_r_in <= '0';

        wait for 400 ns;
        btn_r_in <= '1';
        wait for 100 ns; 
        btn_r_in <= '0';
        
        wait for 2000 ns; 

       
        btn_r_in <= '1';
        wait for 500 ns;
        btn_r_in <= '0';

        
        wait for 2000 ns;

        
        report "Simulacia uspesne dobehla. Skontroluj priebehy signálov.";
        TbSimEnded <= '1';
        wait;
    end process;

end tb;