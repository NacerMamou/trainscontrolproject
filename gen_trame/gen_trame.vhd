LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--Description VHDL du module GEN_TRAME
ENTITY GEN_TRAME IS
  PORT (
    --Les entr�es:
    clk : IN STD_LOGIC; --horloge 100_Mhz
    reset : IN STD_LOGIC;
    send_trame : IN STD_LOGIC;--validation de la trame "bouton centrale sur la carte
    buttons : IN STD_LOGIC_VECTOR(15 DOWNTO 0);--les 16 switchs de la carte pour configurer l'octet d'adresse et de commande
    
    --Les sorties:
    trame : OUT STD_LOGIC_VECTOR(41 DOWNTO 0); --la tramme g�n�r�e
    leds : OUT STD_LOGIC_VECTOR(15 DOWNTO 0) --affiche l'�tat courant du train
  );
END GEN_TRAME;

ARCHITECTURE Behavioral OF GEN_TRAME IS
  --Les signaux
  SIGNAL cntrl_oct : STD_LOGIC_VECTOR(7 DOWNTO 0);--signal octet de controle
  SIGNAL trame_generated : STD_LOGIC_VECTOR(41 DOWNTO 0);--signal de la trame g�n�r�e

BEGIN
  --calcule de l'octet de controle
  cntrl_oct <= buttons(15 DOWNTO 8) XOR buttons(7 DOWNTO 0);
  trame <= trame_generated;
  leds <= trame_generated(26 DOWNTO 19) & trame_generated(17 DOWNTO 10);

  generation : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      trame_generated <= (OTHERS => '0');
    ELSIF (rising_edge(clk)) THEN
      IF send_trame = '1' THEN
        --construction de la tramme en utilisant operateur de concat�nation
        trame_generated <= "11111111111111" & '0' & buttons(15 DOWNTO 8) & '0' & buttons(7 DOWNTO 0) & '0' & cntrl_oct & '1';
      ELSE
        trame_generated <= trame_generated;
      END IF;
    ELSE
      trame_generated <= trame_generated;
    END IF;
  END PROCESS generation;
END Behavioral;