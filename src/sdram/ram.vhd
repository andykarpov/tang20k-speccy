-------------------------------------------------------------------------------
-- RAM Controller
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity ram is
	port(
        CLK             : in std_logic; -- 140
		CLK_MEM			: in std_logic; -- 140 deg 180
		CLK_BUS 		: in std_logic; -- 28
        RESET           : in std_logic;

        -- Loader port
        loader_act 		: in std_logic;
        loader_ram_a 	: in std_logic_vector(20 downto 0);
        loader_ram_do 	: in std_logic_vector(7 downto 0);
        loader_ram_wr 	: in std_logic;

		-- Memory port
		A				: in std_logic_vector(20 downto 0);
		DI				: in std_logic_vector(7 downto 0);
		DO				: out std_logic_vector(7 downto 0);
		WR				: in std_logic;
		RD				: in std_logic;
		RFSH			: in std_logic;
        BUSY            : out std_logic;

		-- SDRAM Pins
		O_sdram_clk : out std_logic;
		O_sdram_cke : out std_logic;
		O_sdram_cs_n : out std_logic;
		O_sdram_cas_n : out std_logic;
		O_sdram_ras_n : out std_logic;
		O_sdram_wen_n : out std_logic;
		IO_sdram_dq : inout std_logic_vector(31 downto 0);
		O_sdram_addr : out std_logic_vector(10 downto 0);
		O_sdram_ba : out std_logic_vector(1 downto 0);
		O_sdram_dqm : out std_logic_vector(3 downto 0)
);
end ram;

architecture rtl of ram is

	signal sdr_rd : std_logic;
	signal sdr_wr : std_logic;
	signal sdr_refresh : std_logic;
	signal sdr_addr : std_logic_vector(22 downto 0);
	signal sdr_din : std_logic_vector(7 downto 0);
	signal sdr_dout : std_logic_vector(7 downto 0);
	signal sdr_dout32 : std_logic_vector(31 downto 0);
	signal sdr_data_ready : std_logic;
	signal sdr_busy : std_logic;

    type qmachine is (init, idle, read, write, refresh);
    signal state : qmachine := init;

    signal rd_req : std_logic := '0';
    signal wr_req : std_logic := '0';
	signal rfsh_req : std_logic := '0';

    signal int_busy : std_logic := '0';
	signal rd_ready : std_logic := '0';
    signal buf : std_logic_vector(7 downto 0);

begin

U_SDRAM: entity work.sdram
	port map (

		SDRAM_DQ => IO_sdram_dq,
		SDRAM_A => O_sdram_addr,
		SDRAM_BA => O_sdram_ba,
		SDRAM_nCS => O_sdram_cs_n,
		SDRAM_nWE => O_sdram_wen_n,
		SDRAM_nRAS => O_sdram_ras_n,
		SDRAM_nCAS => O_sdram_cas_n,
		SDRAM_CLK => O_sdram_clk,
		SDRAM_CKE => O_sdram_cke,
		SDRAM_DQM => O_sdram_dqm,

		clk => CLK,
		clk_sdram => CLK_MEM,
		resetn => not RESET,

		rd => sdr_rd,
		wr => sdr_wr,
		refresh => sdr_refresh,
		addr => sdr_addr,
		din => sdr_din,
		dout => sdr_dout,
		dout32 => sdr_dout32,
		data_ready => sdr_data_ready,
		busy => sdr_busy
	);

rd_req <= '0' when loader_act = '1' else RD;
wr_req <= loader_ram_wr when loader_act = '1' else WR;
rfsh_req <= '0' when loader_act = '1' else RFSH;

process (CLK, RESET, loader_act, loader_ram_wr) 
begin 
    if RESET = '1' then 
        int_busy <= '1';
		rd_ready <= '0';
    elsif rising_edge(CLK) then 

        case state is

            when init =>
                if sdr_busy = '0' then 
                    state <= idle;
                end if;

            when idle =>
                int_busy <= '0';
                if (wr_req = '1') then
					int_busy <= '1';
                    state <= write;
					sdr_wr <= '1';
                    if (loader_act = '1') then 
                        sdr_addr <= "00" & loader_ram_a;
                        sdr_din <= loader_ram_do;
                    else 
                        sdr_addr <= "00" & A;
                        sdr_din <= DI;
                    end if;
					sdr_wr <= '1';
                elsif (rd_req = '1') then
					rd_ready <= '0';
					int_busy <= '1';
                    state <= read;
                    sdr_addr <= "00" & A;
                    sdr_rd <= '1';
				elsif (rfsh_req = '1') then 
					int_busy <= '1';
					state <= refresh;
					sdr_addr <= "00" & A;
					sdr_refresh <= '1';
                end if;

            when read => 
                sdr_rd <= '0';
                if (sdr_data_ready = '1') then 
					--buf <= sdr_dout(7 downto 0);
					DO <= sdr_dout(7 downto 0);
					rd_ready <= '1';
					state <= idle;
                end if;

            when write =>
				sdr_wr <= '0';
                if (sdr_busy = '0') then 
                    state <= idle;
                end if; 

			when refresh =>
				sdr_refresh <= '0';
                if (sdr_busy = '0') then 
                    state <= idle;
                end if; 
        end case;
    end if;
end process;

--process (CLK_BUS, int_busy)
--begin 
--    if rising_edge(CLK_BUS) then 
--        BUSY <= int_busy;
--        if rd_ready = '1' then 
--            DO <= buf;
--        end if;
--    end if;
--end process;

end rtl;