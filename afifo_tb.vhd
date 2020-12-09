library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.numeric_std_unsigned.all;

entity afifo_tb is
    generic (
            DATA_WIDTH : natural := 8;
            FIFO_ADDR_WIDTH : natural := 4
    );
end afifo_tb;

architecture Behavioral of afifo_tb is
        signal i_wclk:     std_logic;
        signal i_rclk:     std_logic;
        signal i_rnrst:    std_logic := '1';
        signal i_wnrst:    std_logic := '1';
        signal i_data:     std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
        signal i_rd:       std_logic;
        signal i_wr:       std_logic;
        signal o_data:     std_logic_vector(DATA_WIDTH-1 downto 0);
        signal o_wfull:    std_logic;
        signal o_rempty:   std_logic;
        constant rclock_period : time := 6 ns;
        constant wclock_period : time := 4 ns;
begin

    UUT: entity work.afifo
    generic map (
        DATA_WIDTH => DATA_WIDTH,
        FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    port map (
        i_wclk => i_wclk,
        i_rclk => i_rclk,
        i_rnrst => i_rnrst,
        i_wnrst => i_wnrst,
        i_data => i_data,
        i_rd => i_rd,
        i_wr => i_wr,
        o_data => o_data,
        o_wfull => o_wfull,
        o_rempty => o_rempty
    );
    
    wclk_proc: process
    begin
        i_wclk <= '0';
        wait for wclock_period/2;
        i_wclk <= '1';
        wait for wclock_period/2;
    end process;
    
    rclk_proc: process
    begin
        i_rclk <= '0';
        wait for rclock_period/2;
        i_rclk <= '1';
        wait for rclock_period/2;
    end process;
    
    write_reset: process
    begin
        -- Asynchronous reset
        i_wnrst <= '0';
        i_rnrst <= '0';
        wait for 1 ns;
        i_wnrst <= '1';
        i_rnrst <= '1';
        wait;
    end process;
    
    write_data: process(i_wclk)
    begin
        if( falling_edge(i_wclk) ) then
            i_data <= i_data + 1;
            i_wr <= '1';
        end if;
    end process;
    
    read_data: process(i_rclk)
    begin
        if( falling_edge(i_rclk) ) then
            i_rd <= '1';
        end if;
    end process;

end Behavioral;
