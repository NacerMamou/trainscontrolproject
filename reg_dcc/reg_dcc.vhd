LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--Description VHDL du module REGISTRE DCC
ENTITY REG_DCC IS
   PORT (
      --Les entr�es:
      clk : IN STD_LOGIC; --horloge 100Mhz
      reset : IN STD_LOGIC; -- r�initialisation �mit par le module MAE
      load : IN STD_LOGIC; -- chargement d'une trame disponible � la sortie du module gen�rateur de trame
      shift : IN STD_LOGIC;-- re�u pour effectuer le d�calage
      read : IN STD_LOGIC;-- �mit par le module MAE pour communiquer la fin de lecture
      trame_in : IN STD_LOGIC_VECTOR(41 DOWNTO 0); --trame g�n�r�e par le module g�nerateur de trame
      
      --les sorties:  
      emptyy : OUT STD_LOGIC; --pour indiquer que le registre est vide
      decale : OUT STD_LOGIC; -- pour indiquer au module MAE la fin de d�calage
      data_bit : OUT STD_LOGIC --MSB de la trame
   );
END REG_DCC;

ARCHITECTURE Behavioral OF REG_DCC IS
   -- d�claration des signaux
   SIGNAL trame_load : STD_LOGIC; --signal �mit pour s�l�tion pour charger une nouvelle trame
   SIGNAL shifted : STD_LOGIC; --signal �mit pour informer le module MAE que le d�calge est effectu� (nouveau bit valable pour la lecture)
   SIGNAL trame_shift : STD_LOGIC; --signal �mit pour s�lectionner d�caler la trame
   SIGNAL empty : STD_LOGIC; --signal �mit pour signal que le registre est vide
   SIGNAL trame_reset : STD_LOGIC; --signal �mit pour r�initialiser le registre
   TYPE etat IS (REG_EMPTY, REG_LOAD, LOAD_END, REG_SHIFT, REG_SHIFTED, REG_END); -- 5 �tats
   SIGNAL EP, EF : etat;
   SIGNAL trame_inn : STD_LOGIC_VECTOR (41 DOWNTO 0);-- sortie Mux et entr�e du registre
   SIGNAL trame_decale : STD_LOGIC_VECTOR (41 DOWNTO 0);--signal trame d�cal�
   SIGNAL trame_out : STD_LOGIC_VECTOR (41 DOWNTO 0); --sortie du registre
   SIGNAL cmd : STD_LOGIC_VECTOR (2 DOWNTO 0); --signal de selection pour le Mux, construit par concat�nation

BEGIN
   data_bit <= trame_out(41); -- Bit de sortie pour la machine est toujours connect� au MSB de la trame
   cmd <= trame_reset & trame_load & trame_shift; --construction du signal de selection de la trame � enregister dans la m�moire
   trame_decale <= trame_out(40 DOWNTO 0) & '0'; -- signal de d�calage de la trame d'un bit � gauche

   -- selection du signal appropri� � l'�criture dans le registre
   WITH cmd SELECT trame_inn <=
      "000000000000000000000000000000000000000000" WHEN "100", --remise � z�ro du registre
      trame_in WHEN "010", --chargement d'une nouvelle trame
      trame_decale WHEN "001", --d�calage de la trame
      trame_out WHEN OTHERS; -- la trame prend sa valeur pr�cedente

   memory : PROCESS (clk)
   BEGIN
      IF rising_edge(clk) THEN
         trame_out <= trame_inn; -- enregistrement dans le registre de la trame appropri�e s�l�ction�e par le bloc combinatoire pr�c�dent
      END IF;
   END PROCESS memory;

   decale <= shifted;
   emptyy <= empty;

   --Description de la machine de moore
   --process : Fonction de transition de la machine � �tat
   clocked : PROCESS (clk, reset)
   BEGIN
      IF reset = '1' THEN
         EP <= REG_EMPTY; -- r�initialisation de la machine � �tat   
      ELSIF rising_edge(clk) THEN
         EP <= EF; --enregistrement de l'�tat futur dans le registre ds �tat pr�sent
      END IF;
   END PROCESS clocked;
   --process: Calcule de L'�tat futur selon diagrame des �tats
   nextstate : PROCESS (EP, load, read, shift) IS
   BEGIN
      CASE EP IS

         WHEN REG_EMPTY =>
            IF load = '1' THEN -- r�c�ption du signal load �mit par le module MAE
               EF <= REG_LOAD; -- transition pour chargement
            ELSE
               EF <= REG_EMPTY; --sinon ne pas changer d'�tat
            END IF;

         WHEN REG_LOAD => -- �tat r�serv� au chargement d'une nouvelle trame
            EF <= LOAD_END;

         WHEN LOAD_END => -- puis informer le module MAE de la fin du chargement
            IF shift = '1' THEN -- si le module MAE demande un d�calge
               EF <= REG_SHIFT;-- changer d'�tat pour effectuer le d�calage
            ELSE
               EF <= LOAD_END; --sinon ne pas changer d'�tats
            END IF;

         WHEN REG_SHIFT => -- �tat r�serv� au d�calage
            EF <= REG_SHIFTED;

         WHEN REG_SHIFTED => -- puis informer le module MAE de la fin de d�calage
            IF read = '1' THEN --Le module MAE a lu le bit et �mit le signal read
               EF <= REG_END; --arriv� � la fin d'envoie d'un bit de la trame
            ELSE
               EF <= REG_SHIFTED; --ne pas changer d'�tat et attendre la lecture du bit par le module MAE
            END IF;

         WHEN OTHERS =>
            IF shift = '1' THEN --Le module MAE n'a pas encore fini de trasmettre la totalit� de la trame, il demande un nouveau d�calage
               EF <= REG_SHIFT;--effectuer un nouveau d�calage
            ELSE
               EF <= REG_END; --sinon la mae reste dans cette �tat jusqua la reseption du reset par le module MAE
            END IF;
      END CASE;
   END PROCESS nextstate;

   -- process de calcul des sorties           
   outputs : PROCESS (EP)
   BEGIN
      CASE EP IS
         WHEN REG_EMPTY =>
            trame_reset <= '1'; -- r�initialisation du registre
            trame_load <= '0';
            trame_shift <= '0';
            empty <= '1'; --indiquer que le registre est vide
            shifted <= '0';

         WHEN REG_LOAD =>
            trame_reset <= '0';
            trame_load <= '1'; -- activer ce signal pour charger une nouvelle trame dans le registre
            trame_shift <= '0';
            shifted <= '0';
            empty <= '1'; -- la trame n'a pas encore �t� charg�

         WHEN LOAD_END =>
            trame_reset <= '0';
            shifted <= '0';
            empty <= '0'; -- le registre n'est plus vide et une trame est disponible
            trame_load <= '0';
            trame_shift <= '0';

         WHEN REG_SHIFT =>
            trame_reset <= '0';
            trame_load <= '0';
            shifted <= '0';
            empty <= '0';
            trame_shift <= '1'; --�mission de ce signal pour enregistrer la trame d�cal� dans le registre

         WHEN REG_SHIFTED =>
            trame_reset <= '0';
            trame_load <= '0';
            shifted <= '1'; -- �mission de ce signal pour informer le module MAE de la fin de d�calge
            empty <= '0';
            trame_shift <= '0';
         WHEN OTHERS =>
            --Ne rien faire
            trame_reset <= '0';
            trame_load <= '0';
            shifted <= '0';
            empty <= '0';
            trame_shift <= '0';
      END CASE;
   END PROCESS outputs;
END Behavioral;