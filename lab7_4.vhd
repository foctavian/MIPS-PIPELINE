library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;

entity lab7_4 is
    Port ( clk : in STD_LOGIC;
           btn : in STD_LOGIC_VECTOR (4 downto 0);
           sw : in STD_LOGIC_VECTOR (15 downto 0);
           led : out STD_LOGIC_VECTOR (15 downto 0);
           an : out STD_LOGIC_VECTOR (3 downto 0);
           cat : out STD_LOGIC_VECTOR (6 downto 0));
end lab7_4;

architecture Behavioral of lab7_4 is

component MPG is
    Port ( en : out STD_LOGIC;
           input : in STD_LOGIC;
           clock : in STD_LOGIC);
end component;

component SSD is
    Port ( clk: in STD_LOGIC;
           digits: in STD_LOGIC_VECTOR(15 downto 0);
           an: out STD_LOGIC_VECTOR(3 downto 0);
           cat: out STD_LOGIC_VECTOR(6 downto 0));
end component;

component IFetch
    Port ( clk: in STD_LOGIC;
           rst : in STD_LOGIC;
           en : in STD_LOGIC;
           BranchAddress : in STD_LOGIC_VECTOR(15 downto 0);
           JumpAddress : in STD_LOGIC_VECTOR(15 downto 0);
           Jump : in STD_LOGIC;
           PCSrc : in STD_LOGIC;
           Instruction : out STD_LOGIC_VECTOR(15 downto 0);
           PCinc : out STD_LOGIC_VECTOR(15 downto 0));
end component;

component IDecode
    Port ( clk: in STD_LOGIC;
           en : in STD_LOGIC;    
           Instr : in STD_LOGIC_VECTOR(12 downto 0);
           WD : in STD_LOGIC_VECTOR(15 downto 0);
           RegWrite : in STD_LOGIC;
           ExtOp : in STD_LOGIC;
           RD1 : out STD_LOGIC_VECTOR(15 downto 0);
           RD2 : out STD_LOGIC_VECTOR(15 downto 0);
           Ext_Imm : out STD_LOGIC_VECTOR(15 downto 0);
           wa: in std_logic_vector(2 downto 0);
           func : out STD_LOGIC_VECTOR(2 downto 0);
           rt: out std_logic_vector(2 downto 0);
           rd: out std_logic_vector(2 downto 0);
           sa : out STD_LOGIC);
end component;

component MainControl
    Port ( Instr : in STD_LOGIC_VECTOR(2 downto 0);
           RegDst : out STD_LOGIC;
           ExtOp : out STD_LOGIC;
           ALUSrc : out STD_LOGIC;
           Branch : out STD_LOGIC;
           Jump : out STD_LOGIC;
           ALUOp : out STD_LOGIC_VECTOR(2 downto 0);
           MemWrite : out STD_LOGIC;
           MemtoReg : out STD_LOGIC;
           RegWrite : out STD_LOGIC);
end component;

component ExecutionUnit is
Port ( PCinc : in STD_LOGIC_VECTOR(15 downto 0);
           RD1 : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           Ext_Imm : in STD_LOGIC_VECTOR(15 downto 0);
           func : in STD_LOGIC_VECTOR(2 downto 0);
           sa : in STD_LOGIC;
           ALUSrc : in STD_LOGIC;
           RegDst:in std_logic;
           ALUOp : in STD_LOGIC_VECTOR(2 downto 0);
           BranchAddress : out STD_LOGIC_VECTOR(15 downto 0);
           ALURes : out STD_LOGIC_VECTOR(15 downto 0);
           rt:in std_logic_vector(2 downto 0);
           rd:in std_logic_vector(2 downto 0);
           rwa:out std_logic_vector(2 downto 0);
           Zero : out STD_LOGIC);
end component;

component MEM
    port ( clk : in STD_LOGIC;
           en : in STD_LOGIC;
           ALUResIn : in STD_LOGIC_VECTOR(15 downto 0);
           RD2 : in STD_LOGIC_VECTOR(15 downto 0);
           MemWrite : in STD_LOGIC;			
           MemData : out STD_LOGIC_VECTOR(15 downto 0);
           ALUResOut : out STD_LOGIC_VECTOR(15 downto 0));
end component;

signal Instruction, PCinc, RD1, RD2, WD, Ext_imm : STD_LOGIC_VECTOR(15 downto 0); 
signal JumpAddress, BranchAddress, ALURes, ALURes1, MemData : STD_LOGIC_VECTOR(15 downto 0);
signal func : STD_LOGIC_VECTOR(2 downto 0);
signal sa, zero : STD_LOGIC;
signal digits : STD_LOGIC_VECTOR(15 downto 0);
signal en, rst, PCSrc : STD_LOGIC; 
-- main controls 
signal RegDst, ExtOp, ALUSrc, Branch, Jump, MemWrite, MemtoReg, RegWrite : STD_LOGIC;
signal ALUOp :  STD_LOGIC_VECTOR(2 downto 0);

signal PcInc_if_id: std_logic_vector(15 downto 0);
signal Instr_if_id: std_logic_vector(15 downto 0);
signal PcInc_id_ex: std_logic_vector(15 downto 0);

signal rd : std_logic_vector(2 downto 0);
signal rt : std_logic_vector(2 downto 0);
signal rwa : std_logic_vector(2 downto 0);

signal RegDst_id_ex: std_logic;
signal RegWrite_id_ex: std_logic;
signal sa_id_ex: std_logic;
signal Branch_id_ex: std_logic;
signal AluSrc_id_ex: std_logic;
signal MemWrite_id_ex:std_logic;
signal MemToReg_id_ex:std_logic;

signal func_id_ex:std_logic_vector(2 downto 0);
signal AluOp_id_ex:std_logic_vector(2 downto 0);
signal rd_id_ex:std_logic_vector(2 downto 0);
signal rt_id_ex:std_logic_vector(2 downto 0);

signal rd1_id_ex:std_logic_vector(15 downto 0);
signal rd2_id_ex:std_logic_vector(15 downto 0);
signal Ext_Imm_id_ex:std_logic_vector(15 downto 0);

signal RegDst_ex_mem: std_logic;
signal RegWrite_ex_mem: std_logic;
signal sa_id_ex_mem: std_logic;
signal Branch_ex_mem: std_logic;
signal AluSrc_ex_mem: std_logic;
signal MemWrite_ex_mem:std_logic;
signal MemToReg_ex_mem:std_logic;
signal zero_ex_mem:std_logic;
signal alures_ex_mem:std_logic_vector(15 downto 0);
signal branch_address_ex_mem:std_logic_vector(15 downto 0);
signal rd_ex_mem:std_logic_vector(2 downto 0);
signal data2_ex_mem:std_logic_vector(15 downto 0);

signal wa_mem_wb:std_logic_vector(2 downto 0);
signal alures_mem_wb:std_logic_vector(15 downto 0);
signal MemData_mem_wb:std_logic_vector(15 downto 0);
signal MemWrite_mem_wb:std_logic;
signal RegWrite_mem_wb: std_logic;
signal MemToReg_mem_wb:std_logic;


begin

    
    monopulse1: MPG port map(en, btn(0), clk);
    monopulse2: MPG port map(rst, btn(1), clk);
    inst_IF: IFetch port map(clk, rst, en, branch_address_ex_mem, JumpAddress, Jump, PCSrc, Instruction, PCinc);
    inst_ID: IDecode port map(clk, en, Instr_if_id(12 downto 0), WD, RegWrite_mem_wb,ExtOp, RD1, RD2, Ext_imm,wa_mem_wb ,func,rt, rd, sa);
    inst_MC: MainControl port map(Instr_if_id(15 downto 13), RegDst, ExtOp, ALUSrc, Branch, Jump, ALUOp, MemWrite, MemtoReg, RegWrite);
    inst_EX: ExecutionUnit port map(PCinc_id_ex, rd1_id_ex, rd2_id_ex, Ext_Imm_id_ex, func_id_ex, sa_id_ex, ALUSrc_id_ex, RegDst_id_ex,ALUOp_id_ex, BranchAddress, AluRes,rt_id_ex, rd_id_ex,rwa, Zero); 
    inst_MEM: MEM port map(clk, en, alures_ex_mem, data2_ex_mem, MemWrite_ex_mem, MemData, ALURes1);
    
    process(clk)
    begin
    if rising_edge(clk) and en = '1' then 
        PcInc_if_id<=PcInc;
        Instr_if_id<=Instruction;
        
        rd1_id_ex<=RD1;
        rd2_id_ex<=RD2;
        Ext_Imm_id_ex <= Ext_imm;
        func_id_ex <= func;
        sa_id_ex <=sa;
        rt_id_ex <=rt;
        rd_id_ex <=rd;
        RegDst_id_ex <= RegDst;
        RegWrite_id_ex <= RegWrite;
        PcInc_id_ex <=PcInc_if_id;
        AluSrc_id_ex<=AluSrc;
        AluOp_id_ex <= AluOp;
        MemToReg_id_ex <= MemToReg;
        Branch_id_ex<=Branch;
        MemToReg_ex_mem <= MemToReg_id_ex;
        MemToReg_mem_wb <= MemToReg_ex_mem;
        
        RegWrite_ex_mem <= RegWrite_id_ex;
        zero_ex_mem <= Zero;
        alures_ex_mem <= AluRes;
        Branch_ex_mem <= Branch_id_ex;
        rd_ex_mem <= rwa;
        wa_mem_wb<=rd_ex_mem;
        branch_address_ex_mem <= BranchAddress;
        alures_mem_wb<= ALURes1;
        MemData_mem_wb <=MemData;
        RegWrite_mem_wb <= RegWrite_ex_mem;
        
        MemWrite_id_ex<=MemWrite;
        MemWrite_ex_mem<=MemWrite_id_ex; 
       
    end if;
    end process;
    
    
    with MemToReg_mem_wb select
        WD <= MemData_mem_wb when '1',
              alures_mem_wb when '0',
              (others => '0') when others;

    
    PCSrc <= zero_ex_mem and Branch_ex_mem;

    
    JumpAddress <= PCinc_if_id(15 downto 13) & Instr_if_id(12 downto 0);

   
    with sw(7 downto 5) select
        digits <=  Instruction when "000", 
                   PCinc when "001",
                   rd1_id_ex when "010",
                   rd2_id_ex when "011",
                   Ext_Imm_id_ex when "100",
                   ALURes when "101",
                   MemData when "110",
                   WD when "111",
                   (others => '0') when others; 

    display : SSD port map (clk, digits, an, cat);
    
    
    led(10 downto 0) <= ALUOp & RegDst & ExtOp & ALUSrc & Branch & Jump & MemWrite & MemtoReg & RegWrite;
    
end Behavioral;