LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
--Description VHDL du module DIVISEUR d'HORLOGE
ENTITY CLK_DIV IS
	PORT (
		clk_100M : IN STD_LOGIC; --sortie: horloge de fr�quence 1 MHs
		raz : IN STD_LOGIC; -- remise � z�ro
		clk_1M : OUT STD_LOGIC -- sortie: horloge de fr�quence 1 MHs
	);
END CLK_DIV;

ARCHITECTURE Behavioral OF CLK_DIV IS

	SIGNAL cpt : INTEGER RANGE 0 TO 50; -- Compteur d'impulsions
	SIGNAL imp : STD_LOGIC; -- signal horloge de sortie

BEGIN
	PROCESS (clk_100M, raz)
	BEGIN
		IF raz = '1' THEN
			cpt <= 0;
			imp <= '0';

		ELSE
			IF rising_edge(clk_100M) THEN
				cpt <= cpt + 1;
				IF cpt = 49 THEN
					cpt <= 0;
					imp <= NOT imp;
				END IF;
			END IF;
		END IF;
	END PROCESS;
	clk_1M <= imp;
END Behavioral;