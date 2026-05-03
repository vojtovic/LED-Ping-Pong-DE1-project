library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity led_pulse is
    port (
        clk     : in  std_logic;
        rst     : in  std_logic;
        trigger : in  std_logic;
        tick    : in  std_logic;
        output  : out std_logic
    );
end entity led_pulse;

architecture Behavioral of led_pulse is
    signal cnt : unsigned(3 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                cnt <= (others => '0');
            elsif trigger = '1' then
                cnt <= to_unsigned(10, 4);
            elsif tick = '1' and cnt > 0 then
                cnt <= cnt - 1;
            end if;
        end if;
    end process;

    output <= '1' when cnt > 0 else '0';

end Behavioral;
