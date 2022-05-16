LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY DCC IS
  PORT (
    -- INPUTS
    clk : IN STD_LOGIC;
    reset : IN STD_LOGIC;
    send : IN STD_LOGIC;
    buttons : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
    dcc_output : OUT STD_LOGIC;
    leds : OUT STD_LOGIC_VECTOR(15 DOWNTO 0)
  );
END DCC;

ARCHITECTURE Structural OF DCC IS
  COMPONENT CLK_DIV
    PORT (
      clk_100M : IN STD_LOGIC;
      raz : IN STD_LOGIC;
      clk_1M : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT TEMPO
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      start : IN STD_LOGIC;
      fin : OUT STD_LOGIC
    );
  END COMPONENT;

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

  COMPONENT BIT0
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      go_0 : IN STD_LOGIC;

      fin_0 : OUT STD_LOGIC;
      dcc_0 : OUT STD_LOGIC;
      started_0 : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT BIT1
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      go_1 : IN STD_LOGIC;

      fin_1 : OUT STD_LOGIC;
      dcc_1 : OUT STD_LOGIC;
      started_1 : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT REG_DCC
    PORT (
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      load : IN STD_LOGIC;
      shift : IN STD_LOGIC;
      read : IN STD_LOGIC;
      trame_in : IN STD_LOGIC_VECTOR(41 DOWNTO 0);
      emptyy : OUT STD_LOGIC;
      decale : OUT STD_LOGIC;
      data_bit : OUT STD_LOGIC
    );
  END COMPONENT;

  COMPONENT MAE
    PORT (
      -- INPUTS
      clk : IN STD_LOGIC;
      reset : IN STD_LOGIC;
      
      --from REG
      emptyFreg : IN STD_LOGIC;
      bitFreg : IN STD_LOGIC;
      shiftedFreg : IN STD_LOGIC;
      
      --from zero
      startedFzero : IN STD_LOGIC;
      endFzero : IN STD_LOGIC;

      --from zero
      startedFone : IN STD_LOGIC;
      endFone : IN STD_LOGIC;

      -- from tempo
      endFtempo : IN STD_LOGIC;

      -- OUTPUTS  
      -- reset the system
      rst_sys : OUT STD_LOGIC;

      -- to reg
      load2reg : OUT STD_LOGIC;
      shift2reg : OUT STD_LOGIC;
      read2reg : OUT STD_LOGIC;

      -- to send_zero_one modules
      enable2one : OUT STD_LOGIC;
      enable2zero : OUT STD_LOGIC;
      
      --to tempo
      enable2tempo : OUT STD_LOGIC
    );
  END COMPONENT;

  SIGNAL sig0 : STD_LOGIC;
  SIGNAL sig1 : STD_LOGIC;
  SIGNAL sig2 : STD_LOGIC;
  SIGNAL sig3 : STD_LOGIC;
  SIGNAL sig4 : STD_LOGIC;
  SIGNAL sig5 : STD_LOGIC;
  SIGNAL sig6 : STD_LOGIC;
  SIGNAL sig7 : STD_LOGIC;
  --signal sig8: STD_LOGIC;
  SIGNAL sig9 : STD_LOGIC;
  SIGNAL sig10 : STD_LOGIC;
  SIGNAL sig11 : STD_LOGIC;
  SIGNAL sig12 : STD_LOGIC;
  SIGNAL sig13 : STD_LOGIC;
  SIGNAL sig14 : STD_LOGIC;
  SIGNAL sig15 : STD_LOGIC;
  SIGNAL sig16 : STD_LOGIC;
  SIGNAL sig17 : STD_LOGIC;
  SIGNAL sig18 : STD_LOGIC;
  SIGNAL sig19 : STD_LOGIC;
  SIGNAL sig20 : STD_LOGIC_VECTOR(41 DOWNTO 0);

BEGIN
  clk_div_inst : CLK_DIV PORT MAP(clk_100M => sig1, raz => sig0, clk_1M => sig2);
  tempo_inst : TEMPO PORT MAP(clk => sig2, reset => sig0, start => sig3, fin => sig4);
  gen_trame_inst : GEN_TRAME PORT MAP(clk => sig1, reset => reset, send_trame => send, buttons => buttons, trame => sig20, leds => leds);
  bit0_inst : BIT0 PORT MAP(clk => sig2, reset => sig0, go_0 => sig5, fin_0 => sig7, dcc_0 => sig18, started_0 => sig6);
  bit1_inst : BIT1 PORT MAP(clk => sig2, reset => sig0, go_1 => sig11, fin_1 => sig10, dcc_1 => sig19, started_1 => sig9);
  reg_dcc_inst : REG_DCC PORT MAP(
    clk => sig1, reset => sig0, load => sig17, shift => sig16, read => sig15, trame_in => sig20, emptyy => sig14, decale => sig13, data_bit => sig12
  );

  mae_inst : MAE PORT MAP(
    clk => sig1, reset => reset, emptyFreg => sig14, bitFreg => sig12, shiftedFreg => sig13, startedFzero => sig6, endFzero => sig7, startedFone => sig9, endFone => sig10, endFtempo => sig4, rst_sys => sig0, load2reg => sig17, shift2reg => sig16, read2reg => sig15, enable2one => sig11, enable2zero => sig5, enable2tempo => sig3

  );

  sig1 <= clk;
  dcc_output <= sig18 OR sig19;
END Structural;