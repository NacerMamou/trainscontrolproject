LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY TEMPO_TB IS
END ENTITY;

ARCHITECTURE tb OF TEMPO_TB IS
  COMPONENT TEMPO
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      start : IN STD_LOGIC;
      fin : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL clk : STD_LOGIC := '0';
  SIGNAL reset : STD_LOGIC;
  SIGNAL start : STD_LOGIC := '0';
  SIGNAL fin : STD_LOGIC;
  CONSTANT clk_period : TIME := 1000 ns; --period

BEGIN
instance : TEMPO PORT MAP(clk => clk, reset => reset, start => start, fin => fin);
reset <= '1', '0' AFTER 1 ms;
start <= '0',
  '1' AFTER 500 us,
  '0' AFTER 7500 us,
  '1' AFTER 14 ms,
  '0' AFTER 19 ms,
  '1' AFTER 20 ms;

clocking : PROCESS
  VARIABLE i : INTEGER RANGE 0 TO 100000;
  BEGIN
    i := 0;
    LOOP
      EXIT WHEN i = 100000;
      clk <= '0';
      WAIT FOR clk_period/2;
      clk <= '1';
      WAIT FOR clk_period/2;
      i := i + 1;
    END LOOP;
    WAIT;
END PROCESS clocking;
END TB;