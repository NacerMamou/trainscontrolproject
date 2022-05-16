LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--Description VHDL du module BIT0
ENTITY BIT0 IS
	PORT (
		--les entr�es:
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		go_0 : IN STD_LOGIC;
		
		--Les sorties: 
		fin_0 : OUT STD_LOGIC;
		dcc_0 : OUT STD_LOGIC;
		started_0 : OUT STD_LOGIC
	);
END BIT0;

ARCHITECTURE Behavioral OF BIT0 IS
	--les signaux
	TYPE etat IS (IDLE, GEN_HIGH, GEN_LOW, GEN_END);
	SIGNAL EP, EF : etat;
	SIGNAL cpt : INTEGER RANGE 0 TO 201;--compteurs de p�riodes

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
				cpt <= cpt + 1;--incr�mentation du compteur, 1 uS pass�
				IF (cpt = 199) THEN
					cpt <= 0; --r�initialisation
				END IF;
			END IF;
		END IF;
	END PROCESS clocked;

--process: fonction de calcule de l'�tat futur
nextstate : PROCESS (EP, cpt, go_0)
	BEGIN
		CASE EP IS
			WHEN IDLE =>
				IF go_0 = '1' THEN --d�but de g�n�ration
					EF <= GEN_LOW;
				ELSE
					EF <= IDLE;
				END IF;
			
			WHEN GEN_LOW =>
				IF cpt = 99 THEN --apr�s une demi-p�riode changer le signal de sortie � 1
					EF <= GEN_HIGH;
				ELSE
					EF <= GEN_LOW;
				END IF;

			WHEN GEN_HIGH =>
				IF cpt = 199 THEN -- fin de g�neration
					EF <= GEN_END;
				ELSE
					EF <= GEN_HIGH;
				END IF;

			WHEN GEN_END =>
				IF go_0 = '1' THEN --deux g�n�ration cons�cutifs
					EF <= GEN_LOW;
				ELSE
					EF <= IDLE;
				END IF;

			WHEN OTHERS => EF <= EP;
		END CASE;
	END PROCESS nextstate;

--process: fonction de calcule des sorties 
p2 : PROCESS (EP, cpt)
	BEGIN
		CASE EP IS
			WHEN IDLE =>
				fin_0 <= '0';
				started_0 <= '0';
				dcc_0 <= '0';

			WHEN GEN_LOW =>
				fin_0 <= '0';
				started_0 <= '1';--la g�n�ration a d�but�
				dcc_0 <= '0';--le signal de sortie � z�ro

			WHEN GEN_HIGH =>
				IF cpt = 199 THEN
					fin_0 <= '1';--signal indiquant la fin de g�n�ration
					dcc_0 <= '1';--maintenir le signal � 1 pour le uS restant
					started_0 <= '1';
				ELSE --sinon
					fin_0 <= '0';--g�n�ration toujours en cours
					dcc_0 <= '1';--signal de sortie � z�ro
					started_0 <= '1';--g�n�ration a d�but�
				END IF;

			WHEN OTHERS => --ici etat GEN_END
				--aucune sortie est activ�e
				fin_0 <= '0';
				started_0 <= '0';
				dcc_0 <= '0';
		END CASE;
END PROCESS p2;
END Behavioral;