-- Testbench automatically generated online
-- at https://vhdl.lapinoo.net
-- Generation date : Sun, 19 Apr 2026 17:30:37 GMT
-- Request id : cfwk-fed377c2-69e5113d7934f

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_control_logic is
end tb_control_logic;

architecture tb of tb_control_logic is

    component control_logic
        port (clk               : in std_logic;
              btn_r             : in std_logic;
              btn_l             : in std_logic;
              hitg              : out std_logic;
              hitr              : out std_logic;
              fcnt              : in std_logic_vector (3 downto 0);
              bcnt              : in std_logic_vector (3 downto 0);
              back_counter_rst  : out std_logic;
              front_counter_rst : out std_logic);
    end component;

    signal clk               : std_logic;
    signal btn_r             : std_logic;
    signal btn_l             : std_logic;
    signal hitg              : std_logic;
    signal hitr              : std_logic;
    signal fcnt              : std_logic_vector (3 downto 0);
    signal bcnt              : std_logic_vector (3 downto 0);
    signal back_counter_rst  : std_logic;
    signal front_counter_rst : std_logic;
    
    
    
    constant TbPeriod : time := 50 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin

    dut : control_logic
    port map (clk               => clk,
              btn_r             => btn_r,
              btn_l             => btn_l,
              hitg              => hitg,
              hitr              => hitr,
              fcnt              => fcnt,
              bcnt              => bcnt,
              back_counter_rst  => back_counter_rst,
              front_counter_rst => front_counter_rst);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
    -- ***EDIT*** Adapt initialization as needed
        btn_r <= '0';
        btn_l <= '0';
        fcnt <= (others => '0');
        bcnt <= (others => '0');
        
        wait for 60 ns;
        
        if front_counter_rst = '0' then
            for i in 0 to 7 loop
                fcnt <= std_logic_vector(TO_UNSIGNED(i,4));
                wait until rising_edge (clk);       
            end loop;
       

       
        elsif front_counter_rst = '1' then 
         fcnt <="0000";    
        end if;
           
        --wait for 30 ns; 
            
        if back_counter_rst = '0' then    
            for n in 7 downto 0 loop
                bcnt <= std_logic_vector(TO_UNSIGNED(n,4));
                wait until rising_edge (clk);
                
            end loop; 
            wait for 60 ns;  
        elsif  back_counter_rst = '1' then
          bcnt <="0111";
        end if;
            
            
        -- ***EDIT*** Add stimuli here
        wait for 200 * TbPeriod;

        -- Stop the clock and hence terminate the simulation
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_control_logic of tb_control_logic is
    for tb
    end for;
end cfg_tb_control_logic;