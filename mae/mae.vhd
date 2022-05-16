LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

--Description VHDL du module MAE
ENTITY MAE IS
  PORT (--Les entr�es:
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;

    --Emit par le module reg_dcc
    emptyFreg : IN STD_LOGIC;--emit quand le registre est vide
    bitFreg : IN STD_LOGIC;--le MSB de la trame � transmettre
    shiftedFreg : IN STD_LOGIC;--recu apr�s chaque d�calage
    
    --Emit par le module BIT0
    startedFzero : IN STD_LOGIC;--re�u si le module BIT0 a d�but� la g�n�ration
    endFzero : IN STD_LOGIC;--re�u � la fin de g�n�ration

    --Emit par le module BIT1
    startedFone : IN STD_LOGIC;--re�u si le module BIT1 a d�but� la g�n�ration
    endFone : IN STD_LOGIC;--re�u � la fin de g�n�ration

    -- Emit par le module temporisateur
    endFtempo : IN STD_LOGIC; --re�u � la fin de temporisation

    --Les sorties:
    rst_sys : OUT STD_LOGIC;-- �mit pour r�initialiser tous les modules

    -- commande du module reg
    load2reg : OUT STD_LOGIC;--�mit pour demander un chargement d'une nouvelle tramme
    shift2reg : OUT STD_LOGIC;--�mit pour effectuer un d�calage
    read2reg : OUT STD_LOGIC;--�mit pour communiquer la fin de lecture du MSB

    -- commande du module BIT1 et BIT0
    enable2one : OUT STD_LOGIC;--�mit pour activer le module BIT1/effectuer une transmission d'un 1 
    enable2zero : OUT STD_LOGIC;--�mit pour activer le module BIT0/effectuer une transmission d'un 0   
    
    --commande du module temporisateur
    enable2tempo : OUT STD_LOGIC -- �mit pour activer le module temporisateur/commander une nouvelle temporisation de 6ms
  );
END MAE;

ARCHITECTURE Behavioral OF MAE IS
  --Les signaux:
  -- signaux de la machine � �tat:
  TYPE etat IS (STARTN, WAITING, LOAD_TRAME, READING, SENDING_ZERO, SENDING_ONE, COUNT_INC, COUNT_READ, CHECK_EMPTY, SHIFTING);--10 �tats
  SIGNAL EP, EF : etat;
  SIGNAL cpt_inc : STD_LOGIC;--�mit pour incr�menter le compteur
  SIGNAL cpt_reset : STD_LOGIC;--�mit pour remetre le compteur � z�ro
  SIGNAL cpt_read : STD_LOGIC;--�mit pour communiquer la lecture du compteur

  --signaux du module d'incr�mentation
  TYPE state_type IS (IDLE, INCREMENT, INCREMENTED, END_INC);--4 �tats
  SIGNAL PS, NS : state_type;
  SIGNAL cpt : INTEGER RANGE 0 TO 42; --compteur du nombre de bits transmits 
  SIGNAL cpt_incremented : STD_LOGIC;--pour confirmer l'incr�mentation � la machine � �tat
  SIGNAL inc_end : STD_LOGIC;--fin de l'incr�mentation

BEGIN
  --process : Fonction de transition de la machine � �tat 
  clocked : PROCESS (clk, reset)
  BEGIN
    IF reset = '1' THEN
      EP <= STARTN;
    ELSIF rising_edge(clk) THEN
      EP <= EF;
    END IF;
  END PROCESS clocked;

  --process: Calcule de L'�tat futur selon diagrame des �tats
  nextstate : PROCESS (EP, endFtempo, emptyFreg, bitFreg, startedFzero, endFzero, startedFone, endFone, shiftedFreg, cpt, cpt_incremented, inc_end)
  BEGIN
    CASE EP IS
      WHEN STARTN =>
        EF <= WAITING;--on passe inconditionellement pour attendre 6 ms

      WHEN WAITING =>
        IF endFtempo = '1' THEN --si fin de temporisation
          EF <= LOAD_TRAME;-- charger une nouvelle tramme
        ELSE
          EF <= WAITING; --sinon continuer d'attendre
        END IF;

      WHEN LOAD_TRAME =>
        IF emptyFreg = '0' THEN --si chargement effectu� et le registre n'est plus vide
          EF <= READING; --lecture du MSB de la tramme
        ELSE
          EF <= LOAD_TRAME;--sinon ne pas changer d'�tat
        END IF;

      WHEN READING => --Lecture du bit courant et confirmation envoy�e au module REG
        IF shiftedFreg = '0' THEN--si le module reg a re�u la confirmation et a pass� � l'�tat REG_END "fin de d�calage"
          IF bitFreg = '0' THEN -- si le MSB lu est un 0
            IF (startedFzero = '0' AND endFzero = '0') THEN --puis v�rifier si la g�n�ration n'a ni commenc�e ni finie
              EF <= SENDING_ZERO; --g�n�ration d'un 0
            ELSE
              EF <= READING;-- sinon ne pas changer d'�tat
            END IF;

          ELSIF bitFreg = '1' THEN -- si le MSB lu est un 0
            IF (startedFone = '0' AND endFone = '0') THEN --puis v�rifier si la g�n�ration n'a ni commenc�e ni finie
              EF <= SENDING_ONE; --g�n�ration d'un 1
            ELSE
              EF <= READING; --sinon ne pas changer d'�tat
            END IF;

          ELSE
            EF <= READING;--sinon ne pas changer d'�tat
          END IF;
        ELSE
          EF <= READING;--sinon ne pas changer d'�tat
        END IF;

      WHEN SENDING_ZERO =>
        IF (startedFzero = '1' AND endFzero = '1') THEN -- si la g�n�ration a d�but� et elle est arriv� � la fin
          EF <= COUNT_INC; --incr�mentation du compteur
        ELSE
          EF <= SENDING_ZERO; --sinon attendre la fin de g�n�ration
        END IF;

      WHEN SENDING_ONE =>
        IF (startedFone = '1' AND endFone = '1') THEN -- si la g�n�ration a d�but� et elle est arriv� � la fin
          EF <= COUNT_INC;--incr�mentation du compteur
        ELSE
          EF <= SENDING_ONE;--sinon attendre la fin de g�n�ration
        END IF;

      WHEN COUNT_INC =>
        IF cpt_incremented = '1' THEN --si l'incr�mentation effectu�e
          EF <= COUNT_READ;-- lecture de la nouvelle valeur du compteur
        ELSE
          EF <= COUNT_INC;--sinon attendre
        END IF;

      WHEN COUNT_READ => --lecture du compteur et confirmation
        IF inc_end = '1' THEN --si la confiramtion re�u par le module de l'incr�mentation
          EF <= CHECK_EMPTY;-- v�rifier si tous les bits de la tramme ont �t�s transmis
        ELSE
          EF <= COUNT_READ;-- sinon attendre la r�ponse du module de l'incr�mentation
        END IF;

      WHEN CHECK_EMPTY =>
        IF cpt = 42 THEN -- si le compteur a atteint 42, la totalit� de la tramme a �t� transimise
          EF <= STARTN; --fin et aller � l'�tat initial
        ELSE
          EF <= SHIFTING; --sinon commander un d�calage du registre
        END IF;

      WHEN OTHERS => --ici ETAT  SHIFTING
        IF shiftedFreg = '1' THEN --si fin de d�calge
          EF <= READING;--on lit le nouveau bit
        ELSE
          EF <= SHIFTING;--sinon attendre la r�ponse du registre
        END IF;
    END CASE;
  END PROCESS nextstate;

  -- process de calcul des sorties 
  outputs : PROCESS (EP)
  BEGIN
    CASE EP IS
      WHEN STARTN =>
        rst_sys <= '1'; --r�initialiser tous les module
        enable2tempo <= '0';
        load2reg <= '0';
        enable2zero <= '0';
        enable2one <= '0';
        read2reg <= '0';
        shift2reg <= '0';
        cpt_reset <= '1';--r�initialiser le compteur
        cpt_inc <= '0';
        cpt_read <= '0';

      WHEN WAITING =>
        rst_sys <= '0';
        enable2tempo <= '1'; --commander une nouvelle temporisation
        load2reg <= '0';
        enable2zero <= '0';
        enable2one <= '0';
        read2reg <= '0';
        shift2reg <= '0';
        cpt_reset <= '1';--maintenir
        cpt_inc <= '0';
        cpt_read <= '0';

      WHEN LOAD_TRAME =>
        rst_sys <= '0';
        enable2tempo <= '0';
        load2reg <= '1'; --commander un chargement d'une nouvelle tramme
        enable2zero <= '0';
        enable2one <= '0';
        read2reg <= '0';
        shift2reg <= '0';
        cpt_reset <= '1';--maintenir
        cpt_inc <= '0';
        cpt_read <= '0';

      WHEN READING =>
        rst_sys <= '0';
        enable2tempo <= '0';
        load2reg <= '0';
        enable2zero <= '0';
        enable2one <= '0';
        read2reg <= '1'; --confirmation de la lecture au module reg
        shift2reg <= '0';
        cpt_reset <= '0';--relach�/pret pour une incr�mentation
        cpt_inc <= '0';
        cpt_read <= '0';

      WHEN SENDING_ZERO =>
        rst_sys <= '0';
        enable2tempo <= '0';
        load2reg <= '0';
        enable2zero <= '1';--activer le module BIT0
        enable2one <= '0';
        read2reg <= '0';
        shift2reg <= '0';
        cpt_reset <= '0';--relach�/pret pour une incr�mentation
        cpt_inc <= '0';
        cpt_read <= '0';
      WHEN SENDING_ONE =>
        rst_sys <= '0';
        enable2tempo <= '0';
        load2reg <= '0';
        enable2zero <= '0';
        enable2one <= '1';--activer le module BIT1
        read2reg <= '0';
        shift2reg <= '0';
        cpt_reset <= '0';--relach�/pret pour une incr�mentation
        cpt_inc <= '0';
        cpt_read <= '0';

      WHEN COUNT_INC =>
        rst_sys <= '0';
        enable2tempo <= '0';
        load2reg <= '0';
        enable2zero <= '0';
        enable2one <= '0';
        read2reg <= '0';
        shift2reg <= '0';
        cpt_reset <= '0';--relach�/pret pour une incr�mentation
        cpt_inc <= '1'; --incr�menter le compteur
        cpt_read <= '0';
      WHEN COUNT_READ =>
        rst_sys <= '0';
        enable2tempo <= '0';
        load2reg <= '0';
        enable2zero <= '0';
        enable2one <= '0';
        read2reg <= '0';
        shift2reg <= '0';
        cpt_reset <= '0';
        cpt_inc <= '0';
        cpt_read <= '1'; --confirmer la lecture de la nouvelle valeur du compteur                                                                                                                                                                                                          
      WHEN CHECK_EMPTY => --aucun signal activ�
        rst_sys <= '0';
        enable2tempo <= '0';
        load2reg <= '0';
        enable2zero <= '0';
        enable2one <= '0';
        read2reg <= '0';
        shift2reg <= '0';
        cpt_reset <= '0';
        cpt_inc <= '0';
        cpt_read <= '0';

      WHEN OTHERS => --ici ETAT  SHIFTING 
        rst_sys <= '0';
        enable2tempo <= '0';
        load2reg <= '0';
        enable2zero <= '0';
        enable2one <= '0';
        read2reg <= '0';
        shift2reg <= '1';--commande de d�calage
        cpt_reset <= '0';
        cpt_inc <= '0';
        cpt_read <= '0';
    END CASE;
  END PROCESS outputs;

  --Description du module d'incr�mentation
  --process : Fonction de transition de la machine � �tat 
  count_process : PROCESS (cpt_reset, clk)
  BEGIN
    IF cpt_reset = '1' THEN --r�initialisation
      PS <= IDLE;
      cpt <= 0;
    ELSIF rising_edge(clk) THEN
      PS <= NS;--transition
      IF PS = INCREMENT THEN --incr�mentation
        cpt <= cpt + 1;
      END IF;
    END IF;
  END PROCESS count_process;

  n_state : PROCESS (PS, cpt_inc, cpt_read)
  BEGIN
    CASE PS IS
      WHEN IDLE =>
        IF cpt_inc = '1' THEN--si commande d'incr�mentation re�u
          NS <= INCREMENT;
        ELSE
          NS <= IDLE;--sinon rester � l'�tat initial
        END IF;

      WHEN INCREMENT => --cet �tat est r�serv� uniquement pour l'incr�mentation
        NS <= INCREMENTED;

      WHEN INCREMENTED =>
        IF cpt_read = '1' THEN --si une confirmation re�u 
          NS <= END_INC; --on passe � la fin
        ELSE
          NS <= INCREMENTED;--sinon atendre
        END IF;

      WHEN OTHERS => --ici �tat END
        IF cpt_inc = '1' THEN --si une nouvelle commande pour l'incr�mentation re�u
          NS <= INCREMENT;
        ELSE
          NS <= END_INC;--sinon rester dans cet �tat
        END IF;
    END CASE;
  END PROCESS n_state;

  --process : Fonction de calcul des sorties 
  p8 : PROCESS (PS)
  BEGIN
    CASE PS IS
      WHEN IDLE =>
        cpt_incremented <= '0';
        inc_end <= '0';

      WHEN INCREMENT =>
        cpt_incremented <= '0';
        inc_end <= '0';

      WHEN INCREMENTED =>
        cpt_incremented <= '1';--incr�mentation effectu�, le compteur dispose d'une nouvelle valeur valide
        inc_end <= '0';

      WHEN OTHERS =>
        cpt_incremented <= '0';
        inc_end <= '1'; --fin
    END CASE;
  END PROCESS p8;
END Behavioral;