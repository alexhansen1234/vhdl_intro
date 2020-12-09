library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use ieee.numeric_std_unsigned.all;

entity afifo is
    generic (
        DATA_WIDTH:         natural := 8;
        FIFO_ADDR_WIDTH :   natural := 8
    );
    port (
        i_wclk:     in std_logic;
        i_rclk:     in std_logic;
        i_rnrst:    in std_logic;
        i_wnrst:    in std_logic;
        i_data:     in std_logic_vector(DATA_WIDTH-1 downto 0);
        i_rd:       in std_logic;
        i_wr:       in std_logic;
        o_data:     out std_logic_vector(DATA_WIDTH-1 downto 0);
        o_wfull:    out std_logic;
        o_rempty:   out std_logic 
    );
end afifo;

architecture Behavioral of afifo is
    type mem_type is array(0 to (2**FIFO_ADDR_WIDTH)-1) of std_logic_vector(DATA_WIDTH-1 downto 0);
    subtype mem_ptr is std_logic_vector(FIFO_ADDR_WIDTH downto 0);
    signal mem : mem_type;
    signal rbin     : mem_ptr := (others => '0');
    signal wbin     : mem_ptr := (others => '0');
    signal rgray    : mem_ptr;
    signal wgray    : mem_ptr;
    signal wr_index : integer;
    signal rd_index : integer; 
    signal rq1_wgray: mem_ptr;
    signal rq2_wgray: mem_ptr;
    signal wq1_rgray: mem_ptr;
    signal wq2_rgray: mem_ptr;
begin

    fifo_assign_index: process(rbin, wbin)
    begin
        wr_index <= to_integer(unsigned(wbin(FIFO_ADDR_WIDTH-1 downto 0)));
        rd_index <= to_integer(unsigned(rbin(FIFO_ADDR_WIDTH-1 downto 0)));
    end process;
    
    fifo_cross_w_to_r: process(i_rclk, i_rnrst)
    begin
        if( i_rnrst = '0' ) then
            wq1_rgray <= (others => '0');
            wq2_rgray <= (others => '0');
        elsif ( rising_edge(i_rclk) ) then
            wq1_rgray <= rgray;
            wq2_rgray <= wq1_rgray;
        end if;
    end process;
    
    fifo_cross_r_to_w: process(i_wclk, i_wnrst)
    begin
        if( i_wnrst = '0' ) then
            rq1_wgray <= (others => '0');
            rq2_wgray <= (others => '0');
        elsif ( rising_edge(i_wclk) ) then
            rq1_wgray <= wgray;
            rq2_wgray <= rq1_wgray;
        end if;
    end process;
    
    wgray <= wbin xor ( '0' & wbin(FIFO_ADDR_WIDTH downto 1));
    rgray <= rbin xor ( '0' & rbin(FIFO_ADDR_WIDTH downto 1));
    o_rempty <= '1' when rq2_wgray = rgray else '0';
    o_wfull <= '1' when  (wgray(FIFO_ADDR_WIDTH downto FIFO_ADDR_WIDTH-1) = not(wq2_rgray(FIFO_ADDR_WIDTH downto FIFO_ADDR_WIDTH-1))) 
        and (wgray(FIFO_ADDR_WIDTH-2 downto 0) = wq2_rgray(FIFO_ADDR_WIDTH-2 downto 0)) else '0';
            
    fifo_read: process(i_rclk, i_rnrst)
    begin
        if( i_rnrst = '0' ) then
            rbin <= (others => '0');
        elsif( rising_edge(i_rclk) ) then
            if( i_rd = '1' and o_rempty = '0' ) then
                o_data <= mem(rd_index);
                rbin <= rbin + 1;
            end if;
        end if;
    end process;
    
    fifo_write: process(i_wclk, i_wnrst)
    begin
        if( i_wnrst = '0' ) then
            wbin <= (others => '0');
        elsif( rising_edge(i_wclk) ) then
            if( i_wr = '1' and o_wfull = '0' ) then
                mem(wr_index) <= i_data;
                wbin <= wbin + 1;
            end if;
        end if;
    end process;
end Behavioral;
