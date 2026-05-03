library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity score_counter is
    port (
        clk   : in  std_logic;
        rst   : in  std_logic;
        hit   : in  std_logic;
        score : out std_logic_vector(15 downto 0)
    );
end entity score_counter;

architecture Behavioral of score_counter is
    signal ones  : unsigned(3 downto 0) := (others => '0');
    signal tens  : unsigned(3 downto 0) := (others => '0');
    signal hunds : unsigned(3 downto 0) := (others => '0');
    signal thous : unsigned(3 downto 0) := (others => '0');
begin

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                ones  <= (others => '0');
                tens  <= (others => '0');
                hunds <= (others => '0');
                thous <= (others => '0');
            elsif hit = '1' then
                if ones < 9 then
                    ones <= ones + 1;
                else
                    ones <= (others => '0');
                    if tens < 9 then
                        tens <= tens + 1;
                    else
                        tens <= (others => '0');
                        if hunds < 9 then
                            hunds <= hunds + 1;
                        else
                            hunds <= (others => '0');
                            if thous < 9 then
                                thous <= thous + 1;
                            end if;
                        end if;
                    end if;
                end if;
            end if;
        end if;
    end process;

    score <= std_logic_vector(thous & hunds & tens & ones);

end Behavioral;
