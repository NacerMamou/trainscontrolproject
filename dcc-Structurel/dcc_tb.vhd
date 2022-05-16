LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY DCC_TB IS
END ENTITY;
ARCHITECTURE tb OF DCC_TB IS
  COMPONENT DCC
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      send : IN STD_LOGIC;
      buttons : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      dcc_output : OUT STD_LOGIC;
      leds : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;
  --constant clk_period : time := 1000ns; 

  SIGNAL clk : STD_LOGIC;
  SIGNAL reset : STD_LOGIC;
  SIGNAL send : STD_LOGIC;
  SIGNAL buttons : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL dcc_output : STD_LOGIC;
  SIGNAL leds : STD_LOGIC_VECTOR(15 DOWNTO 0);

BEGIN
  INSTANCE : DCC PORT MAP(clk => clk, reset => reset, send => send, buttons => buttons, dcc_output => dcc_output, leds => leds);
  reset <= '1',
    '0' AFTER 40 ns,
    '1' AFTER 90 ms;

  buttons <= x"0000",
    x"FF00" AFTER 10 ns,
    x"FFFF" AFTER 30 ms,
    x"0000" AFTER 50 ms;

  send <= '0',
    '1' AFTER 50 ns,
    '0' AFTER 80 ns,
    '1' AFTER 120 ns,
    '1' AFTER 29 ms;

  clocking : PROCESS
    VARIABLE i : INTEGER RANGE 0 TO 6000000;
  BEGIN
    i := 0;
    LOOP
      EXIT WHEN i = 6000000;
      clk <= '0';
      
      WAIT FOR 5 ns;
      clk <= '1';
      
      WAIT FOR 5 ns;
      i := i + 1;
    END LOOP;
    WAIT;
  END PROCESS clocking;
END TB;