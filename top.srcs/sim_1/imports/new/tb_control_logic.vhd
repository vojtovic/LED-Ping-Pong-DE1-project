library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_control_logic is
end tb_control_logic;

architecture tb of tb_control_logic is

    component control_logic
        port (clk               : in std_logic;
              rst               : in std_logic;
              en                : in std_logic;
              btn_r             : in std_logic;
              btn_l             : in std_logic;
              fcnt              : in std_logic_vector (3 downto 0);
              bcnt              : in std_logic_vector (3 downto 0);
              front_counter_rst : out std_logic;
              back_counter_rst  : out std_logic;
              use_back_counter  : out std_logic;
              hit_g             : out std_logic;
              hit_r             : out std_logic;
              new_game          : out std_logic);
              
    end component;

    signal clk               : std_logic;
    signal rst               : std_logic;
    signal en                : std_logic;
    signal btn_r             : std_logic;
    signal btn_l             : std_logic;
    signal fcnt              : std_logic_vector (3 downto 0);
    signal bcnt              : std_logic_vector (3 downto 0);
    signal front_counter_rst : std_logic;
    signal back_counter_rst  : std_logic;
    signal use_back_counter  : std_logic;
    signal hit_g             : std_logic;
    signal hit_r             : std_logic;
    signal new_game          : std_logic;

    constant TbPeriod : time := 10 ns; 
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin
    
    en_process :process
    begin
    en <= '0';
    wait for 20 ns; 
    en <= '1';
    wait for 10 ns;
    
    end process;     


    dut : control_logic
    port map (clk               => clk,
              rst               => rst,
              en                => en,
              btn_r             => btn_r,
              btn_l             => btn_l,
              fcnt              => fcnt,
              bcnt              => bcnt,
              front_counter_rst => front_counter_rst,
              back_counter_rst  => back_counter_rst,
              use_back_counter  => use_back_counter,
              hit_g             => hit_g,
              hit_r             => hit_r,
              new_game          => new_game);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    
    clk <= TbClock;

    stimuli : process
    begin
        

        rst   <= '0';
        bcnt  <= "0111";
        fcnt  <= "0111";
        btn_r <= '0'; 
        btn_l <= '0'; 
        
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;
        
        fcnt <= "0111";
        bcnt <= "0111";
        wait for 20 ns;
 
        btn_r <= '1'; 
        wait for 20 ns;
        btn_r <= '0'; 
        wait for 20 ns;
        
        for i in 7 to 15 loop
            fcnt <= std_logic_vector(to_unsigned(i, 4));
            wait for 20 ns;
        end loop;

        wait for 500 ns; 

        wait for 50 ns;
        btn_l <= '1'; 
        btn_r <= '1';
        wait for 10 ns; 
        btn_l <= '0'; 
        btn_r <= '0';

        
        wait for 100 ns;
        TbSimEnded <= '1';
        wait;
    end process;

end tb;
