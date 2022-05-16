LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY BIT0_TB IS
END ENTITY;

ARCHITECTURE tb OF BIT0_TB IS
  COMPONENT BIT0
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      go_0 : IN STD_LOGIC;
      fin_0 : OUT STD_LOGIC;
      dcc_0 : OUT STD_LOGIC;
      started_0 : OUT STD_LOGIC
      );
  END COMPONENT;

  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC;
  SIGNAL go_0 : STD_LOGIC := '0';
  SIGNAL fin_0 : STD_LOGIC;
  SIGNAL dcc_0 : STD_LOGIC;
  SIGNAL started_0 : STD_LOGIC;
  --constant clk_period : time := 1000ns; 

BEGIN
instance : BIT0 PORT MAP(clk => clk, reset => reset, go_0 => go_0, fin_0 => fin_0, dcc_0 => dcc_0, started_0 => started_0);
reset <= '0', '0' AFTER 10 us;
go_0 <= '1',
  '0' AFTER 4 us,
  '1' AFTER 200200 ns;

clocking : PROCESS
  VARIABLE i : INTEGER RANGE 0 TO 1000;
  BEGIN
    i := 0;
    LOOP
      EXIT WHEN i = 1000;
      clk <= '0';
      WAIT FOR 500 ns;
      clk <= '1';
      WAIT FOR 500 ns;
      i := i + 1;
    END LOOP;
    WAIT;
  END PROCESS clocking;
END TB;