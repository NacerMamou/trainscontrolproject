LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY BIT1_TB IS
END ENTITY;

ARCHITECTURE tb OF BIT1_TB IS
  COMPONENT BIT1
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      go_1 : IN STD_LOGIC;
      fin_1 : OUT STD_LOGIC;
      dcc_1 : OUT STD_LOGIC;
      started_1 : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC;
  SIGNAL go_1 : STD_LOGIC := '0';
  SIGNAL fin_1 : STD_LOGIC;
  SIGNAL dcc_1 : STD_LOGIC;
  SIGNAL started_1 : STD_LOGIC;
  --constant clk_period : time := 1000ns; 

BEGIN
instance : BIT1 PORT MAP(clk => clk, reset => reset, go_1 => go_1, started_1 => started_1, fin_1 => fin_1, dcc_1 => dcc_1);
reset <= '0', '0' AFTER 10 us;
go_1 <= '1',
  '0' AFTER 115500 ns,
  '1' AFTER 116200 ns;

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