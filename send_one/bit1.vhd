LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--Description VHDL du module BIT1
ENTITY BIT1 IS
  PORT (
    --Les entr�es: 
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    go_1 : IN STD_LOGIC;
    
    --Les sorties:
    fin_1 : OUT STD_LOGIC;
    dcc_1 : OUT STD_LOGIC;
    started_1 : OUT STD_LOGIC
  );
END BIT1;

ARCHITECTURE Behavioral OF BIT1 IS
  TYPE etat IS (IDLE, GEN_HIGH, GEN_LOW, GEN_END);
  SIGNAL EP, EF : etat;
  SIGNAL cpt : INTEGER RANGE 0 TO 201;

BEGIN

--process: fonction de transition
clocked : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      cpt <= 0;
      EP <= IDLE;
    ELSIF rising_edge(clk) THEN
      EP <= EF;
      IF EP = GEN_HIGH OR EP = GEN_LOW THEN
        cpt <= cpt + 1; --incr�mentation
        IF (cpt = 115) THEN
          cpt <= 0; --r�initialisation
        END IF;
      END IF;
    END IF;
  END PROCESS clocked;
  
--process: fonction de calcule de l'�tat futur
nextstate : PROCESS (EP, cpt, go_1)
  BEGIN
    CASE EP IS
      WHEN IDLE =>
        IF go_1 = '1' THEN
          EF <= GEN_LOW; --d�but
        ELSE
          EF <= IDLE;
        END IF;

      WHEN GEN_LOW =>
        IF cpt = 57 THEN --demi-p�riode �coul�
          EF <= GEN_HIGH;
        ELSE
          EF <= GEN_LOW;
        END IF;

      WHEN GEN_HIGH =>
        IF cpt = 115 THEN
          EF <= GEN_END;
        ELSE
          EF <= GEN_HIGH;
        END IF;

      WHEN GEN_END =>
        IF go_1 = '1' THEN
          EF <= GEN_LOW;
        ELSE
          EF <= IDLE;
        END IF;

      WHEN OTHERS => EF <= EP;
    END CASE;
END PROCESS nextstate;

--process: fonction de calcule de sorties 
p2 : PROCESS (EP, cpt)
  BEGIN
    CASE EP IS
      WHEN IDLE =>
        fin_1 <= '0';
        started_1 <= '0';
        dcc_1 <= '0';

      WHEN GEN_LOW =>
        fin_1 <= '0';
        started_1 <= '1';
        dcc_1 <= '0';

      WHEN GEN_HIGH =>
        IF cpt = 115 THEN
          fin_1 <= '1';
          dcc_1 <= '1';
          started_1 <= '1';
        ELSE
          fin_1 <= '0';
          dcc_1 <= '1';
          started_1 <= '1';
        END IF;

      WHEN OTHERS =>
        fin_1 <= '0';
        started_1 <= '0';
        dcc_1 <= '0';
    END CASE;
END PROCESS p2;
END Behavioral;