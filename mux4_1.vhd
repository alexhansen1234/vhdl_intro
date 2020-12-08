----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/07/2020 11:15:55 AM
-- Design Name: 
-- Module Name: mux4_1 - Behavioral
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


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity mux4_1 is
    port (
        I0, I1, I2, I3: in std_logic_vector(7 downto 0);
        SEL: in std_logic_vector(1 downto 0);
        OUT0: out std_logic_vector(7 downto 0)
    );
end mux4_1;

architecture Behavioral of mux4_1 is
begin
    process (SEL, I0, I1, I2, I3) is
    begin
        case SEL is
            when "00" => 
                OUT0 <= I0;
            when "01" => 
                OUT0 <= I1;
            when "10" => 
                OUT0 <= I2;
            when "11" => 
                OUT0 <= I3;
            when others =>
                null;
        end case;
    end process;
end Behavioral;
