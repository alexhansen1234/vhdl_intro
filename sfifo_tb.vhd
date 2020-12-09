library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.numeric_std_unsigned.all;

entity sfifo_tb is
    generic (
        DATA_WIDTH : natural := 8;
        FIFO_ADDR_WIDTH : natural := 4
    );
end sfifo_tb;

architecture tb of sfifo_tb is
     signal clk:        std_logic;
     signal i_nrst:     std_logic;
     signal data_in:    std_logic_vector(DATA_WIDTH-1 downto 0) := (others => '0');
     signal i_rd:       std_logic;
     signal i_wr:       std_logic;
     signal data_out:   std_logic_vector(DATA_WIDTH-1 downto 0);
     signal o_full:     std_logic;
     signal o_empty:    std_logic;
     constant clock_period : time := 1 ns;
begin

    UUT : entity work.sfifo 
    generic map (
        DATA_WIDTH => DATA_WIDTH,
        FIFO_ADDR_WIDTH => FIFO_ADDR_WIDTH
    )
    port map (
        clk => clk, 
        i_nrst => i_nrst, 
        data_in => data_in, 
        i_rd => i_rd, 
        i_wr => i_wr, 
        data_out => data_out,
        o_full => o_full, 
        o_empty => o_empty
    );

    clock_proc: process
    begin
        clk <= '0';
        wait for clock_period / 2;
        clk <= '1';
        wait for clock_period / 2;
    end process;
    
    stim_proc: process
    begin
        i_nrst <= '1';
        i_wr <= '1';
        i_rd <= '0';
        wait for ((2**FIFO_ADDR_WIDTH + 1) * clock_period);
        i_rd <= '1';
        wait for ((2**FIFO_ADDR_WIDTH + 1) * clock_period);
        i_wr <= '0';
        wait for ((2**FIFO_ADDR_WIDTH + 1) * clock_period);
        i_rd <= '0';
        i_nrst <= '0';
        wait for clock_period;
        std.env.finish;
    end process;
    
    generate_input: process(clk)
    begin
        if (falling_edge(clk) and o_full /= '1') then
            data_in <= std_logic_vector(unsigned(data_in) + 1);
        end if;
    end process;
end tb;