LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;

ENTITY GEN_TRAME_TB IS
END ENTITY;
ARCHITECTURE tb OF GEN_TRAME_TB IS
  COMPONENT GEN_TRAME
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      send_trame : IN STD_LOGIC;
      buttons : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
      trame : OUT STD_LOGIC_VECTOR(41 DOWNTO 0);
      leds : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
    );
  END COMPONENT;
  
  --constant clk_period : time := 1000ns; 
  SIGNAL clk : STD_LOGIC;
  SIGNAL reset : STD_LOGIC;
  SIGNAL send_trame : STD_LOGIC;
  SIGNAL buttons : STD_LOGIC_VECTOR(15 DOWNTO 0);
  SIGNAL trame : STD_LOGIC_VECTOR(41 DOWNTO 0);
  SIGNAL leds : STD_LOGIC_VECTOR(15 DOWNTO 0);

  BEGIN
INSTANCE : GEN_TRAME PORT MAP(clk => clk, reset => reset, send_trame => send_trame, buttons => buttons, trame => trame, leds => leds);
  buttons <= x"0000",
    x"FF00" AFTER 10 ns,
    x"0000" AFTER 100 ns;

  reset <= '1',
    '0' AFTER 40 ns,
    '1' AFTER 300 ns;

  send_trame <= '0',
    '1' AFTER 50 ns,
    '0' AFTER 80 ns,
    '1' AFTER 120 ns,
    '1' AFTER 300 ns;

clocking : PROCESS
  VARIABLE i : INTEGER RANGE 0 TO 1000;

  BEGIN
    i := 0;
    LOOP
      EXIT WHEN i = 1000;
      clk <= '0';
      WAIT FOR 5 ns;
      clk <= '1';
      WAIT FOR 5 ns;
      i := i + 1;
    END LOOP;
    WAIT;
  END PROCESS clocking;
END TB;