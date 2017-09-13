library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library altera_mf;
use altera_mf.altera_mf_components.all;

entity buffered_uart is
    generic (
        DEVICE_FAMILY   : string                    := "";
        DIVIDER_BITS    : integer range 1 to 16     := 1;
        DIVIDER_INIT    : integer range 1 to 65535  := 1;
        DIVIDER_FIXED   : integer range 0 to 1      := 0;
        DATA_BITS       : integer range 5 to 9      := 8;
--      PARITY          : string                    := "NONE";
--      STOP_BITS       : string                    := "1";
        RTSCTS_ENABLE   : integer range 0 to 1      := 0;
        RX_DEPTH_BITS   : integer range 2 to 17     := 7;
        TX_DEPTH_BITS   : integer range 2 to 17     := 7
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
end entity;

-- Register map
--
-- 0: STATUS
--        +----+----+----+----+----+----+----+----+----+----+
--        | 15 | 14 | 13 | 12 | 11 | 10 |  9 |  8 |  7 |    |
--        +----+----+----+----+----+----+----+----+----+----+
--    R   |RXE |RXNE|RXF |RXHF|TXF |TXNF|TXE |TXHE|ROVF|    |
--        +----+----+----+----+----+----+----+----+----+----+
--    W   |                                       |ROVF|    |
--        +---------------------------------------+----+----+
--
-- 1: INTR
--        +----+----+----+----+----+----+----+----+----+--+----+
--        | 15 | 14 | 13 | 12 | 11 | 10 |  9 |  8 |  7 |  |  0 |
--        +----+----+----+----+----+----+----+----+----+--+----+
--    R/W |    |RXNE|RXF |RXHF|    |TXNF|TXE |TXHE|ROVF|  |IRQE|
--        +----+----+----+----+----+----+----+----+----+--+----+
--
-- 2: DATA
--        +----+----+--+--+--+--+--+--+--+--+--+--+
--        | 15 | 14 |  |*8|*7| 6| 5| 4| 3| 2| 1| 0|
--        +----+----+--+--+--+--+--+--+--+--+--+--+
--    R   |RXE |    |  |          RXDATA          |
--        +----+----+--+--+--+--+--+--+--+--+--+--+
--    W   |            |          TXDATA          |
--        +------------+--+--+--+--+--+--+--+--+--+
--

architecture rtl of buffered_uart is

    type phase_t is (PHASE0, PHASE1, PHASE2, PHASE3);
    type rxstate_t is (RXS_IDLE, RXS_START, RXS_DATA, RXS_STOP);
    type txstate_t is (TXS_IDLE, TXS_START, TXS_DATA, TXS_STOP);
    subtype divider_t is integer range 0 to ((2 ** DIVIDER_BITS) - 1);
    subtype bitcnt_t is integer range 0 to DATA_BITS;
    subtype data_t is std_logic_vector(DATA_BITS-1 downto 0);

    signal div_max_reg      : divider_t;
    signal rsel_sts_sig     : boolean;
    signal rsel_int_sig     : boolean;
    signal rsel_dat_sig     : boolean;
    signal rsel_div_sig     : boolean;
    signal avs_read_1d_reg  : std_logic;

    signal rval_sts_sig : std_logic_vector(15 downto 0);
    signal rval_int_sig : std_logic_vector(15 downto 0);
    signal rval_dat_sig : std_logic_vector(15 downto 0);
    signal rval_div_sig : std_logic_vector(15 downto 0);

    signal irxne_reg    : std_logic;
    signal irxf_reg     : std_logic;
    signal irxhf_reg    : std_logic;
    signal itxnf_reg    : std_logic;
    signal itxe_reg     : std_logic;
    signal itxhe_reg    : std_logic;
    signal irovf_reg    : std_logic;
    signal irqe_reg     : std_logic;
    signal irq_sig      : boolean;

    signal div_reg      : divider_t;

    signal rx_phase_reg : phase_t;
    signal rx_step0_reg : boolean;
    signal rx_step2_reg : boolean;
    signal rx_state_reg : rxstate_t;
    signal rx_bits_reg  : bitcnt_t;
    signal rx_shift_reg : data_t;
    signal rts_reg      : std_logic;
    signal rxd_1d_reg   : std_logic;
    signal rxd_2d_reg   : std_logic;
    signal rx_ovf_reg   : std_logic;

    signal rx_wdata_sig : data_t;
    signal rx_wreq_reg  : std_logic;
    signal rx_rdata_sig : data_t;
    signal rx_rreq_sig  : std_logic;
    signal rxe_sig      : std_logic;
    signal rxe_1d_reg   : std_logic;
    signal rxne_sig     : std_logic;
    signal rxf_sig      : std_logic;
    signal rxhf_sig     : std_logic;

    signal tx_phase_reg : phase_t;
    signal tx_step0_reg : boolean;
    signal tx_step2_reg : boolean;
    signal tx_state_reg : txstate_t;
    signal tx_bits_reg  : bitcnt_t;
    signal tx_shift_reg : data_t;
    signal txd_reg      : std_logic;
    signal cts_1d_reg   : std_logic;
    signal cts_2d_reg   : std_logic;

    signal tx_wdata_sig : data_t;
    signal tx_wreq_sig  : std_logic;
    signal tx_rdata_sig : data_t;
    signal tx_rreq_reg  : std_logic;
    signal txf_sig      : std_logic;
    signal txnf_sig     : std_logic;
    signal txe_sig      : std_logic;
    signal txhe_sig     : std_logic;

begin

    -- Register select
    rsel_sts_sig <= (avs_address = "00");
    rsel_int_sig <= (avs_address = "01");
    rsel_dat_sig <= (avs_address = "10");
    rsel_div_sig <= (avs_address = "11");

    -- Register read
    avs_readdata    <=
        rval_dat_sig when rsel_dat_sig else
        rval_int_sig when rsel_int_sig else
        rval_div_sig when rsel_div_sig else
        rval_sts_sig;

    process (clk, reset)
    begin
        if (reset = '1') then
            avs_read_1d_reg <= '0';
        elsif (rising_edge(clk)) then
            avs_read_1d_reg <= avs_read;
        end if;
    end process;

    -- Status register
    rval_sts_sig <=
        rxe_sig & rxne_sig & rxf_sig & rxhf_sig &
        txf_sig & txnf_sig & txe_sig & txhe_sig &
        rx_ovf_reg & "000" &
        "0000";

    -- Interrupt mask bits
    process (clk, reset)
    begin
        if (reset = '1') then
            irxne_reg   <= '0';
            irxf_reg    <= '0';
            irxhf_reg   <= '0';
            itxnf_reg   <= '0';
            itxe_reg    <= '0';
            itxhe_reg   <= '0';
            irovf_reg   <= '0';
            irqe_reg    <= '0';
        elsif (rising_edge(clk)) then
            if (rsel_int_sig and avs_write = '1') then
                irxne_reg   <= avs_writedata(14);
                irxf_reg    <= avs_writedata(13);
                irxhf_reg   <= avs_writedata(12);
                itxnf_reg   <= avs_writedata(10);
                itxe_reg    <= avs_writedata( 9);
                itxhe_reg   <= avs_writedata( 8);
                irovf_reg   <= avs_writedata( 7);
                irqe_reg    <= avs_writedata( 0);
            end if;
        end if;
    end process;

    rval_int_sig <=
        '0' & irxne_reg & irxf_reg & irxhf_reg &
        '0' & itxnf_reg & itxe_reg & itxhe_reg &
        irovf_reg & "000" &
        "0000";

    -- Interrupt sending
    irq_sig <=
        (irxne_reg = '1' and rxne_sig = '1') or
        (irxf_reg  = '1' and rxf_sig  = '1') or
        (irxhf_reg = '1' and rxhf_sig = '1') or
        (itxnf_reg = '1' and txnf_sig = '1') or
        (itxe_reg  = '1' and txe_sig  = '1') or
        (itxhe_reg = '1' and txhe_sig = '1') or
        (irovf_reg = '1' and rx_ovf_reg = '1');
    ins_irq <=
        '0' when (irqe_reg = '0') else
        '0' when irq_sig else '1';

    -- Data read
    rval_dat_sig(15) <= rxe_1d_reg;
    rval_dat_sig(14 downto DATA_BITS) <= (others => '0');
    rval_dat_sig(DATA_BITS-1 downto 0) <= rx_rdata_sig;

    -- ================================================================
    --   Divider
    -- ================================================================
    fixed_div: if (DIVIDER_FIXED = 1) generate
        div_max_reg <= DIVIDER_INIT;
    end generate;
    variable_div: if (DIVIDER_FIXED = 0) generate
        process (clk, reset)
        begin
            if (reset = '1') then
                div_max_reg <= DIVIDER_INIT;
            elsif (rising_edge(clk)) then
                if (rsel_div_sig and (avs_write = '1')) then
                    div_max_reg <= to_integer(unsigned(avs_writedata(DIVIDER_BITS-1 downto 0)));
                end if;
            end if;
        end process;
    end generate;

    rval_div_sig <= std_logic_vector(to_unsigned(div_max_reg, rval_div_sig'length));

    process (clk, reset)
    begin
        if (reset = '1') then
            div_reg <= DIVIDER_INIT;
        elsif (rising_edge(clk)) then
            if (div_reg = 0) then
                div_reg <= div_max_reg;
            else
                div_reg <= div_reg - 1;
            end if;
        end if;
    end process;

    -- ================================================================
    --   Receiver side (RXD, RTS)
    -- ================================================================

    -- RXD      ~~~____________000000000000111111111111^^^^^^^^^^^^~~~~
    -- div      1021021021021021021021021021021021021021021021021021021
    -- rx_state IIIIIISSSSSSSSSSSSDDDDDDDDDDDDDDDDDDDDDDDDssssssssssssI
    -- rx_phase 0000000011122233300011122233300011122233300011122233300
    -- rx_bits  ------------222222222222111111111111000000000000-------
    -- rx_shift ------------------------PPPPPPPPPPPPQQQQQQQQQQQQQQQQQQQ
    -- rx_step0 __~__~___________~___________~___________~___________~_
    -- rx_step2 ___________~___________~___________~___________~_______
    -- rx_wreq  _____________________________________________~_________
    -- rx_ovf   ______________________________________________~~~~~~~~~

    -- External signal
    coe_rts <= rts_reg;
    process (clk, reset)
    begin
        if (reset = '1') then
            rxd_1d_reg <= '0';
            rxd_2d_reg <= '0';
        elsif (rising_edge(clk)) then
            rxd_1d_reg <= coe_rxd;
            rxd_2d_reg <= rxd_1d_reg;
        end if;
    end process;

    -- Receiver timing generator
    process (clk, reset)
    begin
        if (reset = '1') then
            rx_phase_reg <= PHASE0;
            rx_step0_reg <= false;
            rx_step2_reg <= false;
        elsif (rising_edge(clk)) then
            if (div_reg = 0) then
                if (rx_state_reg = RXS_IDLE) then
                    rx_phase_reg <= PHASE0;
                    rx_step0_reg <= true;
                else
                    case (rx_phase_reg) is
                        when PHASE0 =>
                            rx_phase_reg <= PHASE1;
                        when PHASE1 => 
                            rx_phase_reg <= PHASE2;
                            rx_step2_reg <= true;
                        when PHASE2 =>
                            rx_phase_reg <= PHASE3;
                        when others =>
                            rx_phase_reg <= PHASE0;
                            rx_step0_reg <= true;
                    end case;
                end if;
            else
                rx_step0_reg <= false;
                rx_step2_reg <= false;
            end if;
        end if;
    end process;

    -- Receiver data shifter
    process (clk, reset)
    begin
        if (reset = '1') then
            rx_shift_reg <= (others => '0');
            rx_bits_reg  <= DATA_BITS;
        elsif (rising_edge(clk)) then
            if (rx_step2_reg) then
                if (rx_state_reg = RXS_DATA) then
                    rx_shift_reg <= rxd_2d_reg & rx_shift_reg(DATA_BITS-1 downto 1);
                end if;
                if (rx_state_reg /= RXS_DATA) then
                    rx_bits_reg <= DATA_BITS;
                else
                    rx_bits_reg <= rx_bits_reg - 1;
                end if;
            end if;
        end if;
    end process;

    -- Receiver data store
    process (clk, reset)
    begin
        if (reset = '1') then
            rx_wreq_reg <= '0';
        elsif (rising_edge(clk)) then
            if (rx_step2_reg and (rx_state_reg = RXS_STOP)) then
                rx_wreq_reg <= '1';
            else
                rx_wreq_reg <= '0';
            end if;
        end if;
    end process;

    -- Receiver overflow detection
    process (clk, reset)
    begin
        if (reset = '1') then
            rx_ovf_reg <= '0';
            rxe_1d_reg <= '0';
        elsif (rising_edge(clk)) then
            if ((rx_wreq_reg = '1') and (rxf_sig = '1')) then
                rx_ovf_reg <= '1';
            elsif (rsel_sts_sig and (avs_write = '1') and (avs_writedata(7) = '1')) then
                rx_ovf_reg <= '0';
            end if;
            rxe_1d_reg <= rxe_sig;
        end if;
    end process;

    -- RTS generation
    rts: if (RTSCTS_ENABLE = 1) generate
        process (clk, reset)
        begin
            if (reset = '1') then
                rts_reg <= '1';
            elsif (rising_edge(clk)) then
                rts_reg <= not rxf_sig;
            end if;
        end process;
    end generate;
    no_rts: if (RTSCTS_ENABLE = 0) generate
        rts_reg <= '1';
    end generate;

    -- Receiver state machine
    process (clk, reset)
    begin
        if (reset = '1') then
            rx_state_reg <= RXS_IDLE;
        elsif (rising_edge(clk)) then
            if (rx_step0_reg) then
                case (rx_state_reg) is
                    when RXS_IDLE =>
                        if (rxd_1d_reg = '0') then
                            rx_state_reg <= RXS_START;
                        end if;
                    when RXS_START =>
                        rx_state_reg <= RXS_DATA;
                    when RXS_DATA =>
                        if (rx_bits_reg = 0) then
                            rx_state_reg <= RXS_STOP;
                        end if;
                    when others =>
                        null;
                end case;
            elsif ((rx_state_reg = RXS_STOP) and rx_step2_reg) then
                rx_state_reg <= RXS_IDLE;
            end if;
        end if;
    end process;

    -- Receiver data FIFO
    rx_wdata_sig <= rx_shift_reg;
    rx_rreq_sig  <= '1' when (rsel_dat_sig and (avs_read = '1') and (avs_read_1d_reg = '0')) else '0';
    rxne_sig     <= not rxe_sig;

    u_rxfifo : scfifo
        generic map (
            add_ram_output_register => "ON",
            almost_full_value       => 2 ** (RX_DEPTH_BITS - 1),
            intended_device_family  => DEVICE_FAMILY,
            lpm_numwords            => 2 ** RX_DEPTH_BITS,
            lpm_showahead           => "OFF",
            lpm_type                => "scfifo",
            lpm_width               => DATA_BITS,
            lpm_widthu              => RX_DEPTH_BITS,
            overflow_checking       => "ON",
            underflow_checking      => "ON",
            use_eab                 => "ON"
        )
        port map (
            aclr            => reset,
            clock           => clk,
            data            => rx_wdata_sig,
            rdreq           => rx_rreq_sig,
            wrreq           => rx_wreq_reg,
            almost_full     => rxhf_sig,
            empty           => rxe_sig,
            full            => rxf_sig,
            q               => rx_rdata_sig
        );

    -- ================================================================
    --   Transmitter side (TXD, CTS)
    -- ================================================================

    -- div      1021021021021021021021021021021021021021021021021021021
    -- tx_state IIISSSSSSSSSSSSDDDDDDDDDDDDDDDDDDDDDDDDssssssssssssIIII
    -- tx_phase 3300011122233300011122233300011122233300011122233300011
    -- tx_bits  ---------222222222222111111111111000000000000----------
    -- tx_shift ---------PPPPPPPPPPPPQQQQQQQQQQQQRRRRRRRRRRRR----------
    -- tx_step0 __~___________~___________~___________~___________~____
    -- tx_step2 ________~___________~___________~___________~__________
    -- tx_rreq  ___~___________________________________________________
    -- TXD      ~~~____________000000000000111111111111^^^^^^^^^^^^~~~~

    -- Transmitter timing generator
    process (clk, reset)
    begin
        if (reset = '1') then
            tx_phase_reg <= PHASE0;
            tx_step0_reg <= false;
            tx_step2_reg <= false;
        elsif (rising_edge(clk)) then
            if (div_reg = 0) then
                case (tx_phase_reg) is
                    when PHASE0 =>
                        tx_phase_reg <= PHASE1;
                    when PHASE1 =>
                        tx_phase_reg <= PHASE2;
                        tx_step2_reg <= true;
                    when PHASE2 =>
                        tx_phase_reg <= PHASE3;
                    when others =>
                        tx_phase_reg <= PHASE0;
                        tx_step0_reg <= true;
                end case;
            else
                tx_step0_reg <= false;
                tx_step2_reg <= false;
            end if;
        end if;
    end process;

    -- Transmitter data shifter
    process (clk, reset)
    begin
        if (reset = '1') then
            tx_shift_reg <= (others => '0');
            tx_bits_reg  <= DATA_BITS;
        elsif (rising_edge(clk)) then
            if (tx_step2_reg) then
                if (tx_state_reg /= TXS_DATA) then
                    tx_shift_reg <= tx_rdata_sig;
                    tx_bits_reg  <= DATA_BITS;
                else
                    tx_shift_reg(DATA_BITS-2 downto 0) <=
                        tx_shift_reg(DATA_BITS-1 downto 1);
                    tx_bits_reg  <= tx_bits_reg - 1;
                end if;
            end if;
        end if;
    end process;

    -- External signal
    coe_txd <= txd_reg;

    cts: if (RTSCTS_ENABLE = 1) generate
        process (clk, reset)
        begin
            if (reset = '1') then
                cts_1d_reg <= '0';
                cts_2d_reg <= '0';
            elsif (rising_edge(clk)) then
                cts_1d_reg <= coe_cts;
                cts_2d_reg <= cts_1d_reg;
            end if;
        end process;
    end generate;
    no_cts: if (RTSCTS_ENABLE = 0) generate
        cts_2d_reg <= '1';
    end generate;

    -- Transmitter state machine & output generator
    process (clk, reset)
    begin
        if (reset = '1') then
            tx_state_reg <= TXS_IDLE;
            txd_reg      <= '1';
            tx_rreq_reg  <= '0';
        elsif (rising_edge(clk)) then
            if (tx_step0_reg) then
                case (tx_state_reg) is
                    when TXS_IDLE =>
                        if ((txe_sig = '0') and (cts_2d_reg = '1')) then
                            tx_state_reg <= TXS_START;
                            txd_reg      <= '0';
                            tx_rreq_reg  <= '1';
                        end if;
                    when TXS_START =>
                        tx_state_reg <= TXS_DATA;
                        txd_reg  <= tx_shift_reg(0);
                    when TXS_DATA =>
                        if (tx_bits_reg = 0) then
                            tx_state_reg <= TXS_STOP;
                            txd_reg <= '1';
                        else
                            txd_reg <= tx_shift_reg(0);
                        end if;
                    when TXS_STOP =>
                        tx_state_reg <= TXS_IDLE;
                end case;
            else
                tx_rreq_reg <= '0';
            end if;
        end if;
    end process;

    -- Transmitter data FIFO
    tx_wdata_sig <= avs_writedata(DATA_BITS-1 downto 0);
    tx_wreq_sig  <= '1' when (rsel_dat_sig and avs_write = '1') else '0';
    txnf_sig     <= not txf_sig;

    u_txfifo : scfifo
        generic map (
            add_ram_output_register => "OFF",
            almost_empty_value      => 2 ** (TX_DEPTH_BITS - 1),
            intended_device_family  => DEVICE_FAMILY,
            lpm_numwords            => 2 ** TX_DEPTH_BITS,
            lpm_showahead           => "OFF",
            lpm_type                => "scfifo",
            lpm_width               => DATA_BITS,
            lpm_widthu              => TX_DEPTH_BITS,
            overflow_checking       => "ON",
            underflow_checking      => "ON",
            use_eab                 => "ON"
        )
        port map (
            aclr            => reset,
            clock           => clk,
            data            => tx_wdata_sig,
            wrreq           => tx_wreq_sig,
            rdreq           => tx_rreq_reg,
            almost_empty    => txhe_sig,
            empty           => txe_sig,
            full            => txf_sig,
            q               => tx_rdata_sig
        );

end architecture;

