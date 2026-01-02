library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity pingpong is
    Port (
        clk     : in  STD_LOGIC;
        rst     : in  STD_LOGIC;
        i_swL   : in  STD_LOGIC;
        i_swR   : in  STD_LOGIC;
        out_led : out STD_LOGIC_VECTOR (7 downto 0)
    );
end pingpong;

architecture Behavioral of pingpong is

    -- 狀態定義
    type STATE_TYPE is (Moving_Left, Moving_Right, Lwin, Rwin);
    signal state      : STATE_TYPE;
    signal prev_state : STATE_TYPE;

    -- LED 與分數
    signal led_r   : STD_LOGIC_VECTOR(7 downto 0);
    signal score_L : STD_LOGIC_VECTOR(3 downto 0);
    signal score_R : STD_LOGIC_VECTOR(3 downto 0);

    -- 除頻用
    signal div_clk : STD_LOGIC;
    signal cnt     : unsigned(25 downto 0) := (others => '0');

begin

    -- LED 輸出
    out_led <= led_r;

    --------------------------------------------------------------------
    -- 時脈除頻
    -- 依照雙方分數總和調整球速，分數越高速度越快
    --------------------------------------------------------------------
    clk_div : process(clk, rst)
    begin
        if rst = '0' then
            cnt     <= (others => '0');
            div_clk <= '0';
        elsif rising_edge(clk) then
            cnt <= cnt + 1;

            -- 分數總和 >= 4 時，加快速度
            if (score_L + score_R) >= "0100" then
                div_clk <= cnt(23);
            else
                div_clk <= cnt(24);  -- 位元越大，速度越慢
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- 狀態機：控制球的移動方向與勝負判斷
    --------------------------------------------------------------------
    FSM : process(clk, rst)
    begin
        if rst = '0' then
            state <= Moving_Right;   -- 初始由左往右
        elsif rising_edge(clk) then
            case state is
                when Moving_Right =>
                    -- 右邊漏接或提早按
                    if (led_r < "00000001") or
                       (led_r > "00000001" and i_swR = '1') then
                        state <= Lwin;
                    -- 右邊正確擊球
                    elsif led_r(0) = '1' and i_swR = '1' then
                        state <= Moving_Left;
                    end if;

                when Moving_Left =>
                    -- 左邊漏接或提早按
                    if (led_r = "00000000") or
                       (led_r < "10000000" and i_swL = '1') then
                        state <= Rwin;
                    -- 左邊正確擊球
                    elsif led_r(7) = '1' and i_swL = '1' then
                        state <= Moving_Right;
                    end if;

                when Lwin =>
                    -- 左方發球
                    if i_swL = '1' then
                        state <= Moving_Right;
                    end if;

                when Rwin =>
                    -- 右方發球
                    if i_swR = '1' then
                        state <= Moving_Left;
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;

    --------------------------------------------------------------------
    -- LED 顯示控制
    --------------------------------------------------------------------
    LED_P : process(div_clk, rst)
    begin
        if rst = '0' then
            led_r <= "10000000";
        elsif rising_edge(div_clk) then
            prev_state <= state;

            case state is
                when Moving_Right =>
                    if prev_state = Lwin then
                        led_r <= "10000000";
                    else
                        led_r(7)          <= '0';
                        led_r(6 downto 0) <= led_r(7 downto 1);
                    end if;

                when Moving_Left =>
                    if prev_state = Rwin then
                        led_r <= "00000001";
                    else
                        led_r(7 downto 1) <= led_r(6 downto 0);
                        led_r(0)          <= '0';
                    end if;

                when Lwin =>
                    if prev_state = Moving_Right then
                        case score_L is
                            when "0000" => led_r <= "10000000";
                            when "0001" => led_r <= "01000000";
                            when "0010" => led_r <= "00100000";
                            when "0011" => led_r <= "00010000";
                            when others => led_r <= "11110000";
                        end case;
                    end if;

                when Rwin =>
                    if prev_state = Moving_Left then
                        case score_R is
                            when "0000" => led_r <= "00000001";
                            when "0001" => led_r <= "00000010";
                            when "0010" => led_r <= "00000100";
                            when "0011" => led_r <= "00001000";
                            when others => led_r <= "00001111";
                        end case;
                    end if;

                when others =>
                    null;
            end case;
        end if;
    end process;

    --------------------------------------------------------------------
    -- 左方計分
    --------------------------------------------------------------------
    score_L_p : process(div_clk, rst)
    begin
        if rst = '0' then
            score_L <= "0000";
        elsif rising_edge(div_clk) then
            if state = Lwin and prev_state = Moving_Right then
                score_L <= score_L + '1';
            end if;
        end if;
    end process;

    --------------------------------------------------------------------
    -- 右方計分
    --------------------------------------------------------------------
    score_R_p : process(div_clk, rst)
    begin
        if rst = '0' then
            score_R <= "0000";
        elsif rising_edge(div_clk) then
            if state = Rwin and prev_state = Moving_Left then
                score_R <= score_R + '1';
            end if;
        end if;
    end process;

end Behavioral;
