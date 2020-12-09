library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.numeric_std_unsigned.all;

entity sfifo is
    generic(
        DATA_WIDTH:         natural := 8;
        FIFO_ADDR_WIDTH:    natural := 8
    );
    port(
        clk:        in std_logic;
        i_nrst:     in std_logic;
        data_in:    in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_rd:       in std_logic;
        i_wr:       in std_logic;
        data_out:   out std_logic_vector(DATA_WIDTH-1 downto 0);
        o_full:     out std_logic;
        o_empty:    out std_logic
    );
end sfifo;

architecture Behavioral of sfifo is
    type mem_type is array(0 to (2**FIFO_ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    signal mem : mem_type;
    signal rd_addr : std_logic_vector (FIFO_ADDR_WIDTH downto 0) := ( others => '0' );
    signal wr_addr : std_logic_vector (FIFO_ADDR_WIDTH downto 0) := ( others => '0' );
    signal is_full : std_logic;
    signal is_empty: std_logic;
    constant addr_cmp : std_logic_vector (FIFO_ADDR_WIDTH downto 0) := ( FIFO_ADDR_WIDTH => '1', others => '0' );
    signal wr_addr_index : integer;
    signal rd_addr_index : integer;
begin

    fifo_assign_index: process(rd_addr, wr_addr)
    begin
        wr_addr_index <= to_integer(unsigned(wr_addr)) mod (2**FIFO_ADDR_WIDTH);
        rd_addr_index <= to_integer(unsigned(rd_addr)) mod (2**FIFO_ADDR_WIDTH);
    end process;

    fifo_assign_flags: process(is_full, is_empty)
    begin
        o_full <= is_full;
        o_empty <= is_empty;
    end process;

    fifo_full: process(wr_addr, rd_addr)
    begin
        if (wr_addr - rd_addr = addr_cmp) then
            is_full <= '1';
        else
            is_full <= '0';
        end if;
    end process;

    fifo_empty: process(wr_addr, rd_addr)
    begin
        if (wr_addr - rd_addr = 0) then
            is_empty <= '1';
        else    
            is_empty <= '0';
        end if;
    end process;
    
    fifo_write: process(clk)
    begin
        if (rising_edge(clk)) then
            if (i_nrst = '0') then
                wr_addr <= (others => '0');
            elsif (is_full = '0' and i_wr = '1') then
                mem(wr_addr_index) <= data_in;
                wr_addr <= wr_addr + 1;
            end if;
        end if;
    end process;
    
    fifo_read: process(clk)
    begin
        if (rising_edge(clk)) then
            if (i_nrst = '0') then
                rd_addr <= (others => '0');
                data_out <= (others => '0');
            elsif (is_empty = '0'  and i_rd = '1') then
                data_out <= mem(rd_addr_index);
                rd_addr <= rd_addr + 1;
            end if;
        end if;
    end process;
    
    fifo_asserts: process(wr_addr, rd_addr)
    begin
        assert ((wr_addr - rd_addr) <= addr_cmp) report "Invalid read/write pointers" severity error;
        assert (wr_addr_index < 2**FIFO_ADDR_WIDTH) report "Invalid write pointer index" severity error;
        assert (rd_addr_index < 2**FIFO_ADDR_WIDTH) report "Invalid read pointer index" severity error;
    end process;
    
end Behavioral;

