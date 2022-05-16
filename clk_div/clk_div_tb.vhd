LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY CLK_DIV_TB IS
END ENTITY;
ARCHITECTURE tb OF CLK_DIV_TB IS
  COMPONENT CLK_DIV
    PORT (
      clk_100M : IN STD_LOGIC;
      raz : IN STD_LOGIC;
      clk_1M : OUT STD_LOGIC);
  END COMPONENT;

  SIGNAL clk_100M : STD_LOGIC := '0';
  SIGNAL raz : STD_LOGIC;
  SIGNAL clk_1M : STD_LOGIC;
  CONSTANT clk_period : TIME := 10 ns; --period

BEGIN
  instance : CLK_DIV PORT MAP(clk_100M => clk_100M, raz => raz, clk_1M => clk_1M);
  raz <= '1', '0' AFTER 1000 ns;

  clocking : PROCESS
    VARIABLE i : INTEGER RANGE 0 TO 1000;
  BEGIN
    i := 0;
    LOOP
      EXIT WHEN i = 1000;
      clk_100M <= '0';
      WAIT FOR clk_period/2;
      clk_100M <= '1';
      WAIT FOR clk_period/2;
      i := i + 1;
    END LOOP;
    WAIT;
  END PROCESS clocking;
END TB;