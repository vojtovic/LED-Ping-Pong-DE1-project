library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity speed_control is
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
end entity speed_control;

architecture Behavioral of speed_control is
    signal speed_reg : natural := G_DEFAULT;
begin

    process(clk)
        variable step : natural;
    begin
        if rising_edge(clk) then
            if rst = '1' or new_game = '1' then
                speed_reg <= G_DEFAULT;
            elsif hit = '1' then
                step := speed_reg / 15;
                if step = 0 then
                    step := 1;
                end if;
                if speed_reg > step then
                    speed_reg <= speed_reg - step;
                end if;
            end if;
        end if;
    end process;

    speed <= speed_reg;

end Behavioral;
