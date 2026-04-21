library ieee;
use ieee.std_logic_1164.all;

entity clk_en is
    generic (
        G_MAX : positive := 5_000_000
    );
    port (
        clk : in std_logic;
        rst : in std_logic;
        ce  : out std_logic
    );
end entity clk_en;

architecture rtl of clk_en is
    signal sig_cnt : integer range 0 to G_MAX - 1 := 0;
    signal ce_reg  : std_logic := '0';
begin
    process (clk) is
    begin
        if rising_edge(clk) then
            if rst = '1' then
                sig_cnt <= 0;
                ce_reg  <= '0';
            elsif sig_cnt = G_MAX - 1 then
                sig_cnt <= 0;
                ce_reg  <= '1';
            else
                sig_cnt <= sig_cnt + 1;
                ce_reg  <= '0';
            end if;
        end if;
    end process;

    ce <= ce_reg;
end architecture rtl;
