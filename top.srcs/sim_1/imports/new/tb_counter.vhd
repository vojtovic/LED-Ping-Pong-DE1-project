library ieee;
use ieee.std_logic_1164.all;

entity tb_counter is
end tb_counter;

architecture tb of tb_counter is

    component counter
        generic ( G_BITS : positive := 4 );
        port (clk      : in std_logic;
              rst      : in std_logic;
              en       : in std_logic;
              cnt      : out std_logic_vector (G_BITS - 1 downto 0);
              new_game : in std_logic);
    end component;

    signal clk      : std_logic;
    signal rst      : std_logic;
    signal en       : std_logic;
    signal cnt      : std_logic_vector (3 downto 0);
    signal new_game : std_logic;

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
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

    dut : counter
    generic map (G_bits => 4)
    port map (clk      => clk,
              rst      => rst,
              en       => en,
              cnt      => cnt,
              new_game => new_game);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- ***EDIT*** Adapt initialization as needed
       
        new_game <= '0';

        
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        wait for 250 ns;
        
        rst <= '1';
        wait for 50 ns;
        rst <= '0';
        
        wait for 200 ns;
        
        rst <= '1';
        new_game <='1';
        wait for 50 ns;
        
        rst <= '0';
        new_game <='0';
        wait for 50 ns;
     

        
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

