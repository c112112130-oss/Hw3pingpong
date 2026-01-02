library IEEE;
use IEEE.std_logic_1164.all;
 
ENTITY pingpong_tb IS
END pingpong_tb;
 
ARCHITECTURE behavior OF pingpong_tb IS
 
-- Component Declaration for the Unit Under Test (UUT)
 
COMPONENT pingpong
    Port (
           clk     : in STD_LOGIC;
           rst     : in STD_LOGIC;
           i_swL   : in STD_LOGIC;
           i_swR   : in STD_LOGIC;
           out_led : out STD_LOGIC_VECTOR (7 downto 0)
           );
END COMPONENT;
 
--Inputs
signal clock : std_logic := '0';
signal reset : std_logic := '0';
signal swL   : std_logic;
signal swR   : std_logic; 
signal led   : std_logic_vector(7 downto 0);
--Outputs
--signal counter : std_logic_vector(3 downto 0);
 
-- Clock period definitions
constant clock_period : time := 20 ns;
 
BEGIN
 
-- Instantiate the Unit Under Test (UUT)
uut: pingpong PORT MAP (
           clk     => clock,
           rst     => reset, 
           i_swL   => swL,
           i_swR   => swR,
           out_led => led
);
 
-- Clock process definitions
clock_process :process
begin
clock <= '0';
wait for clock_period/2;
clock <= '1';
wait for clock_period/2;
end process;
 
-- Stimulus process
stim_proc: process
begin
    -- 初始化
    reset <= '0';
    swL   <= '0';
    swR   <= '0';
    wait for 23 ns;
    reset <= '1';


    wait for 500 ns;
    swR <= '1';
    wait for 100 ns;
    swR <= '0';


    wait for 300 ns;
    swR <= '1';     -- 右方發球
    wait for 100 ns;
    swR <= '0';


    wait for 450 ns;
    swL <= '1';
    wait for 100 ns;
    swL <= '0';


    wait for 120 ns;
    swR <= '1';
    wait for 100 ns;
    swR <= '0';

    wait for 120 ns;
    swL <= '1';     -- 左方發球
    wait for 120 ns;
    swL <= '0';

 
    wait for 550 ns;
    swR <= '1';
    wait for 100 ns;
    swR <= '0';


    wait for 700 ns;
    swR <= '1';
    wait for 100 ns;
    swR <= '0';


    wait for 500 ns;
    swL <= '1';
    wait for 100 ns;
    swL <= '0';


    wait;
end process;

END;
