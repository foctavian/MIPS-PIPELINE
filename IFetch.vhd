library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity IFetch is
    Port (clk: in STD_LOGIC;
          rst : in STD_LOGIC;
          en : in STD_LOGIC;
          BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
          JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
          Jump : in STD_LOGIC;
          PCSrc : in STD_LOGIC;
          Instruction : out STD_LOGIC_VECTOR(15 downto 0);
          PCinc : out STD_LOGIC_VECTOR(15 downto 0));
end IFetch;

architecture Behavioral of IFetch is

type tROM is array (0 to 255) of STD_LOGIC_VECTOR (15 downto 0);
signal ROM : tROM := (

-- FIBONACCI		
-- Acest program calculeaza sirul lui Fibonacci
-- incarcand initial 0 si 1 in 2 registri.
-- Se efectueaza scrierea in memorie la 2 adrese diferite
-- si apoi citirea de la aceleasi adrese pentru a verifica 
-- corectitudinea. Calculul elementelor din sir se face 
-- intr-o bucla, folosind instructiunea J.
--    B"001_000_001_0000000",     -- X"2080" -- ADDI $1, $0, 0
--    B"001_000_010_0000001",     -- X"2101" -- ADDI $2, $0, 1	
--    B"001_000_011_0000000",     -- X"2180" -- ADDI $3, $0, 0	
--    B"001_000_100_0000001",     -- X"2201" -- ADDI $4, $0, 1
--    B"011_011_001_0000000",     -- X"6C80" -- SW $1, 0($3)
--    B"011_100_010_0000000",     -- X"7100" -- SW $2, 0($4)
--    B"010_011_001_0000000",     -- X"4C80" -- LW $1, 0($3)
--    B"010_100_010_0000000",     -- X"5100" -- LW $2, 0($4)
--    B"000_001_010_101_0_000",   -- X"0550" -- ADD $5, $1, $2
--    B"000_000_010_001_0_000",   -- X"0110" -- ADD $1, $0, $2
--    B"000_000_101_010_0_000",   -- X"02A0" -- ADD $2, $0, $5
--    B"111_0000000001000",       -- X"E008" -- J 8

--Acest program calculeaza suma numerelor pare si suma numerelor impare
--dintr-un interval, iar apoi face diferenta dintre ele.
--Am ales ca intervalul sa aiba un numar impar 
--de elemente pentru a se putea verifica pe SSD
--rezultatul, intrucat daca intervalul are un numar
--par de elemente, scaderea va avea un rezultat negativ.

-- $1 iterator
-- $2 start
-- $5 suma impare
-- $6 suma pare
-- $7 diferenta
-- $3 stop 

B"010_000_010_0000000", --lw $2, 0($0)
B"001_000_101_0000000", --addi $5, $0, 0
B"001_000_110_0000000", --addi $6, $0, 0
B"010_001_011_0000001", --lw $3,1($0)
B"0000_0000_0000_0000", --noop
B"0000_0000_0000_0000", --noop
B"100_010_011_0001111", --beq $2, $3, 15
B"0000_0000_0000_0000", --noop
B"0000_0000_0000_0000", --noop
B"0000_0000_0000_0000", --noop
B"000_010_101_101_0_000", --add $5, $2, $5
B"001_010_010_0000001", --addi $2, $2, 1
B"0000_0000_0000_0000", --noop
B"0000_0000_0000_0000", --noop
B"100_010_011_0000111", --beq $2, $3, 6
B"0000_0000_0000_0000", --noop
B"0000_0000_0000_0000", --noop
B"0000_0000_0000_0000", --noop
B"000_010_110_110_0_000", --add $6,$2,$6
B"001_010_010_0000001", --addi $2,$2,1
B"111_0000000000110",--j 4
B"0000_0000_0000_0000", --noop
B"000_101_110_111_0_001",--sub $7,$5,$6
B"0000_0000_0000_0000", --noop
B"0000_0000_0000_0000", --noop
B"011_000_111_0000010", --sw $7,2($0)
    others => X"0000");

signal PC : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
signal PCAux, NextAddr, AuxSgn, AuxSgn1: STD_LOGIC_VECTOR(15 downto 0);

begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                PC <= (others => '0');
            elsif en = '1' then
                PC <= NextAddr;
            end if;
        end if;
    end process;

    Instruction <= ROM(conv_integer(PC(7 downto 0)));

    
    PCAux <= PC + 1;
    PCinc <= PCAux;

    
    process(PCSrc, PCAux, BranchAddress)
    begin
        case PCSrc is 
            when '1' => AuxSgn <= BranchAddress;
            when others => AuxSgn <= PCAux;
        end case;
    end process;	

     
    process(Jump, AuxSgn, JumpAddress)
    begin
        case Jump is
            when '1' => NextAddr <= JumpAddress;
            when others => NextAddr <= AuxSgn;
        end case;
    end process;

end Behavioral;