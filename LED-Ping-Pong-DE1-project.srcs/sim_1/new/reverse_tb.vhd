----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/08/2026 12:47:00 PM
-- Design Name: 
-- Module Name: reverse_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library ieee;
use ieee.std_logic_1164.all;

entity tb_reverse_counter is
end tb_reverse_counter;

architecture tb of tb_reverse_counter is

    component reverse_counter
    generic ( G_BITS : positive );
        port (clk : in std_logic;
              rst : in std_logic;
              en  : in std_logic;
              cnt : out std_logic_vector (G_BITS - 1 downto 0));
    end component;

    constant C_BITS : integer := 4;
    signal clk : std_logic;
    signal rst : std_logic;
    signal en  : std_logic;
    signal cnt : std_logic_vector (C_BITS - 1 downto 0);

    constant TbPeriod : time := 10 ns; -- ***EDIT*** Put right period here
    signal TbClock : std_logic := '0';
    signal TbSimEnded : std_logic := '0';

begin   

    dut : reverse_counter
    generic map ( G_BITS => C_BITS )
    port map (clk => clk,
              rst => rst,
              en  => en,
              cnt => cnt);

    -- Clock generation
    TbClock <= not TbClock after TbPeriod/2 when TbSimEnded /= '1' else '0';

    -- ***EDIT*** Check that clk is really your main clock signal
    clk <= TbClock;

    stimuli : process
    begin
        -- Inicializace
        en <= '0';
        rst <= '1';
        wait for TbPeriod * 2; -- stačí pár cyklů na reset
        
        -- Uvolnění resetu
        rst <= '0';
        wait for TbPeriod;
        
        -- Aktivace čítače
        en <= '1';
        
        -- Necháme ho běžet dostatečně dlouho, aby protočil 4 bity (16 stavů)
        wait for 20 * TbPeriod;

        -- Test pozastavení čítače
        en <= '0';
        wait for 5 * TbPeriod;
        
        en <= '1';
        wait for 5 * TbPeriod;

        -- Ukončení
        TbSimEnded <= '1';
        wait;
    end process;

end tb;

-- Configuration block below is required by some simulators. Usually no need to edit.

configuration cfg_tb_reverse_counter of tb_reverse_counter is
    for tb
    end for;
end cfg_tb_reverse_counter;
