library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
--Description VHDL du module TEMPORISATEUR
entity TEMPO is
    Port ( 
          --entr�es:
           clk   : in  STD_LOGIC;
           reset : in  STD_LOGIC;
           start : in  STD_LOGIC; 
          
          --sorties:
           fin   : out  STD_LOGIC);
end TEMPO;

architecture Behavioral of TEMPO is
--signaux
signal cpt : integer range 0 to 6001;
signal count_end : STD_LOGIC;

begin
process(clk,reset)
  begin
  fin <= count_end;
    if reset = '1' then 
			   cpt <= 0;
			   count_end <= '0';
    else
	  if rising_edge(clk) then 
      if start='1' then 
               cpt <= cpt + 1;--incr�mentation du compteur de p�riodes
	      if cpt = 5999 then 
		       cpt <= 0;--r�initialisation 
		       count_end <= '1';--et �mition du signal de fin
		    end if; 
      else 
        count_end <= '0';
        cpt <= 0;
      end if;
    end if;
  end if;
end process;
end Behavioral;

