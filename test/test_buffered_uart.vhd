library ieee;
use ieee.std_logic_1164.all;

entity test_buffered_uart is
end entity;

architecture behavior of test_buffered_uart is

    component buffered_uart is
        generic (
            DEVICE_FAMILY   : string                    := "";
            CLOCK_FREQ      : integer                   := 50000000;
            BAUDRATE        : integer                   := 115200;
    --      DIVIDER_BITS    : integer range 1 to 16     := 8;
            DATA_BITS       : integer range 5 to 9      := 8;
    --      PARITY          : string                    := "NONE";
    --      STOP_BITS       : string                    := "1";
    --      FLOW_CONTROL    : string                    := "NONE";
            RXFIFO_DEPTH    : integer                   := 128;
            TXFIFO_DEPTH    : integer                   := 128
        );
        port (
            clk             : in    std_logic;
            reset           : in    std_logic;

            avs_address     : in    std_logic_vector(1 downto 0);
            avs_read        : in    std_logic;
            avs_readdata    : out   std_logic_vector(15 downto 0);
            avs_write       : in    std_logic;
            avs_writedata   : in    std_logic_vector(15 downto 0);

            ins_irq         : out   std_logic;

            coe_rxd         : in    std_logic;
            coe_txd         : out   std_logic;
            coe_rts         : out   std_logic;
            coe_cts         : in    std_logic
        );
    end component;

    constant CLOCK_FREQ1    : integer := 1000000;
    constant CLOCK_FREQ2    : integer := integer(real(CLOCK_FREQ1) * 1.05);
    constant CLOCK_PERIOD1  : time := (1000 ms / CLOCK_FREQ1);
    constant CLOCK_PERIOD2  : time := (1000 ms / CLOCK_FREQ2);
    constant BAUDRATE1      : integer := (CLOCK_FREQ1 / 12);
    constant BAUDRATE2      : integer := (CLOCK_FREQ2 / 12);

    constant DEVICE_FAMILY  : string := "Cyclone IV E";

    type bytearray_t is array (natural range <>) of std_logic_vector(7 downto 0);
    constant TEST_DATA1 : bytearray_t(0 to 7) := ( X"00", X"aa", X"55", X"ff", X"ba", X"ad", X"ca", X"fe" );
    constant TEST_DATA2 : bytearray_t(0 to 7) := ( X"de", X"ad", X"be", X"ef", X"fa", X"ce", X"fe", X"ed" );

    signal clk1_reg         : std_logic := '0';
    signal reset1_reg       : std_logic := '0';

    signal avs1_addr_reg    : std_logic_vector(1 downto 0) := (others => 'X');
    signal avs1_read_reg    : std_logic := '0';
    signal avs1_rdata_sig   : std_logic_vector(15 downto 0);
    signal avs1_write_reg   : std_logic := '0';
    signal avs1_wdata_reg   : std_logic_vector(15 downto 0) := (others => 'X');
    signal ins1_irq_sig     : std_logic;
    signal coe1_rxd_sig     : std_logic;
    signal coe1_txd_sig     : std_logic;
    signal coe1_rts_sig     : std_logic;
    signal coe1_cts_sig     : std_logic;

    signal clk2_reg         : std_logic := '0';
    signal reset2_reg       : std_logic := '0';

    signal avs2_addr_reg    : std_logic_vector(1 downto 0) := (others => 'X');
    signal avs2_read_reg    : std_logic := '0';
    signal avs2_rdata_sig   : std_logic_vector(15 downto 0);
    signal avs2_write_reg   : std_logic := '0';
    signal avs2_wdata_reg   : std_logic_vector(15 downto 0) := (others => 'X');
    signal ins2_irq_sig     : std_logic;
    signal coe2_rxd_sig     : std_logic;
    signal coe2_txd_sig     : std_logic;
    signal coe2_rts_sig     : std_logic;
    signal coe2_cts_sig     : std_logic;

    signal test_stop_reg    : boolean := false;
    signal test_done1_reg   : boolean := false;
    signal test_done2_reg   : boolean := false;

begin

    -- Clock generation
    process
    begin
        clk1_reg <= not clk1_reg;
        wait for (CLOCK_PERIOD1 / 2);
        if (test_stop_reg) then
            wait;
        end if;
    end process;
    process
    begin
        clk2_reg <= not clk2_reg;
        wait for (CLOCK_PERIOD2 / 2);
        if (test_stop_reg) then
            wait;
        end if;
    end process;

    -- Reset generation (deassertion is on the edge of clk)
    process
    begin
        wait for (CLOCK_PERIOD1 * 1.3);
        reset1_reg <= '1';
        wait until rising_edge(clk1_reg);
        wait until rising_edge(clk1_reg);
        reset1_reg <= '0';
        wait;
    end process;
    process
    begin
        wait for (CLOCK_PERIOD2 * 1.3);
        reset2_reg <= '1';
        wait until rising_edge(clk2_reg);
        wait until rising_edge(clk2_reg);
        reset2_reg <= '0';
        wait;
    end process;

    -- Test data input (dut1)
    process
        variable i: integer := 0;
        variable j: integer;
    begin
        wait until falling_edge(reset1_reg);
        wait until rising_edge(clk1_reg);
        for i in TEST_DATA1'low to TEST_DATA1'high loop
            avs1_addr_reg  <= "10";
            avs1_wdata_reg(7 downto 0) <= TEST_DATA1(i);
            avs1_wdata_reg(15 downto 8) <= (others => '0');
            avs1_write_reg <= '1';
            wait until rising_edge(clk1_reg);
            avs1_addr_reg  <= (others => 'X');
            avs1_wdata_reg <= (others => 'X');
            avs1_write_reg <= '0';
            wait until rising_edge(clk1_reg);
        end loop;

        readback:
        while true loop
            wait until falling_edge(coe1_rts_sig);
            wait until rising_edge(clk1_reg);

            for j in 0 to 3 loop
                if (i <= TEST_DATA2'high) then
                    avs1_addr_reg <= "10";
                    avs1_read_reg <= '1';
                    wait until rising_edge(clk1_reg);
                    avs1_addr_reg <= (others => 'X');
                    avs1_read_reg <= '0';
                    wait until rising_edge(clk1_reg);
                    assert avs1_rdata_sig = (X"00" & TEST_DATA2(i))
                        report "dut1 received incorrect data"
                        severity failure;
                    i := i + 1;
                end if;
            end loop;

            if (i >= TEST_DATA2'high) then
                exit readback;
            end if;

            avs1_addr_reg <= "10";
            avs1_read_reg <= '1';
            wait until rising_edge(clk1_reg);
            avs1_addr_reg <= (others => 'X');
            avs1_read_reg <= '0';
            wait until rising_edge(clk1_reg);
            assert avs1_rdata_sig(15) = '1'
                report "dut1 should assert RXF bit"
                severity failure;
        end loop;

        assert false report "dut1 test OK" severity note;
        test_done1_reg <= true;
        wait;
    end process;

    -- Test data input (dut2)
    process
        variable i: integer := 0;
        variable j: integer;
    begin
        wait until falling_edge(reset2_reg);
        wait until rising_edge(clk2_reg);
        for i in TEST_DATA2'low to TEST_DATA2'high loop
            avs2_addr_reg   <= "10";
            avs2_wdata_reg(7 downto 0) <= TEST_DATA2(i);
            avs2_wdata_reg(15 downto 8) <= (others => '0');
            avs2_write_reg  <= '1';
            wait until rising_edge(clk2_reg);
            avs2_addr_reg   <= (others => 'X');
            avs2_wdata_reg  <= (others => 'X');
            avs2_write_reg  <= '0';
            wait until rising_edge(clk2_reg);
        end loop;

        readback:
        while true loop
            wait until falling_edge(coe2_rts_sig);
            wait until rising_edge(clk2_reg);

            for j in 0 to 3 loop
                if (i <= TEST_DATA1'high) then
                    avs2_addr_reg <= "10";
                    avs2_read_reg <= '1';
                    wait until rising_edge(clk2_reg);
                    avs2_addr_reg <= (others => 'X');
                    avs2_read_reg <= '0';
                    wait until rising_edge(clk2_reg);
                    assert avs2_rdata_sig = (X"00" & TEST_DATA1(i))
                        report "dut2 received incorrect data"
                        severity failure;
                    i := i + 1;
                end if;
            end loop;

            if (i >= TEST_DATA1'high) then
                exit readback;
            end if;

            avs2_addr_reg <= "10";
            avs2_read_reg <= '1';
            wait until rising_edge(clk2_reg);
            avs2_addr_reg <= (others => 'X');
            avs2_read_reg <= '0';
            wait until rising_edge(clk2_reg);
            assert avs2_rdata_sig(15) = '1'
                report "dut2 should assert RXF bit"
                severity failure;
        end loop;

        assert false report "dut2 test OK" severity note;
        test_done2_reg <= true;
        wait;
    end process;

    -- Simulation stop trigger
    process
    begin
        wait until (test_done1_reg and test_done2_reg);
        assert false report "All tests passed! :-)" severity note;
        test_stop_reg <= true;
        wait;
    end process;

    -- Instantiation
    dut1 : buffered_uart
        generic map (
            DEVICE_FAMILY   => DEVICE_FAMILY,
            CLOCK_FREQ      => CLOCK_FREQ1,
            BAUDRATE        => BAUDRATE1,
            RXFIFO_DEPTH    => 4,
            TXFIFO_DEPTH    => 8
        )
        port map (
            clk             => clk1_reg,
            reset           => reset1_reg,

            avs_address     => avs1_addr_reg,
            avs_read        => avs1_read_reg,
            avs_readdata    => avs1_rdata_sig,
            avs_write       => avs1_write_reg,
            avs_writedata   => avs1_wdata_reg,

            ins_irq         => ins1_irq_sig,

            coe_rxd         => coe1_rxd_sig,
            coe_txd         => coe1_txd_sig,
            coe_rts         => coe1_rts_sig,
            coe_cts         => coe1_cts_sig
        );

    dut2 : buffered_uart
        generic map (
            DEVICE_FAMILY   => DEVICE_FAMILY,
            CLOCK_FREQ      => CLOCK_FREQ2,
            BAUDRATE        => BAUDRATE2,
            RXFIFO_DEPTH    => 4,
            TXFIFO_DEPTH    => 8
        )
        port map (
            clk             => clk2_reg,
            reset           => reset2_reg,

            avs_address     => avs2_addr_reg,
            avs_read        => avs2_read_reg,
            avs_readdata    => avs2_rdata_sig,
            avs_write       => avs2_write_reg,
            avs_writedata   => avs2_wdata_reg,

            ins_irq         => ins2_irq_sig,

            coe_rxd         => coe2_rxd_sig,
            coe_txd         => coe2_txd_sig,
            coe_rts         => coe2_rts_sig,
            coe_cts         => coe2_cts_sig
        );

    coe1_rxd_sig <= coe2_txd_sig;
    coe1_cts_sig <= coe2_rts_sig;
    coe2_rxd_sig <= coe1_txd_sig;
    coe2_cts_sig <= coe1_rts_sig;

end architecture;

