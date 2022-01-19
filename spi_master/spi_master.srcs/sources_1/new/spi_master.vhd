----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.12.2020 13:43:20
-- Design Name: 
-- Module Name: spi_master - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;



entity spi_master is
Generic(
    data_length:integer:=16);
Port(
    clk:in std_logic;
    reset_n:in std_logic;
    enable:in std_logic;
    cpol:in std_logic;
    cpha:in std_logic;
    miso:in std_logic;
    sclk:out std_logic;
    ss_n:out std_logic;
    mosi:out std_logic;
    busy:out std_logic;
    tx:in std_logic_vector(data_length-1 downto 0);             --Mikroi�lemciden veya mikrodenetleyiciden al�nan paralel veri (G�nderilecek Veri)
    rx:out std_logic_vector(data_length-1 downto 0)             --Bu paralel veriyi slave serile�tirerek seri olarak g�nderilecek veri (Al�nacak Veri)
);        
end spi_master;

architecture Behavioral of spi_master is

    type FSM is (init, execute);                                 --Sonlu Durum Makinesi
    signal state: FSM;
    signal receive_transmit: std_logic;                          -- '1' tx, '0' rx i�in
    signal clk_toggles:integer range 0 to data_length*2 +1;      --Saat tersleme say�s�
    signal last_bit:integer range 0 to data_length*2;            --Son bit g�stergesi
    signal rxBuffer:std_logic_vector(data_length-1 downto 0):=(others =>'0');              --Al�nacak Veri S�r�c�s�
    signal txBuffer:std_logic_vector(data_length-1 downto 0):=(others =>'0');              --G�nderilecek Veri S�r�c�s�
    signal INT_ss_n:std_logic;                             --ss_n i�in haf�za
    signal INT_sclk:std_logic;                             --sclk i�in haf�za
    
begin

    ss_n <=INT_ss_n;
    sclk <=INT_sclk;
    
    process(clk, reset_n)
    begin
        if (reset_n = '0') then
            busy<='1';                                --busy, Master me�gul sinyalidir. 
            INT_ss_n <= '1';                          --Slave se�im sinyalidir '1' olmas� demek cihaz se�imi olmad�, haberle�meye ba�lamas� i�in '0' olmas� laz�m
            mosi <= 'Z';                              --y�ksek empedans (High Impedance)
            rx <= (others => '0');
            state <=init;

        elsif (falling_edge(clk)) then
            case state is
                when init =>
                    busy <='0';                       --Haberle�meye hen�z uygun de�il sinyalini verir
                    INT_ss_n <= '1';                  --Cihaz suanda da se�ili de�il
                    mosi <= 'Z';                      
                    
                    if (enable = '1') then             --Haberle�meyi ba�lat
                    
                    busy <='1';
                    INT_sclk <= cpol;                  --SPI saat polaritesini olu�turma
                    receive_transmit <= not cpha;       --cpol '1' ise y�kselen kenarda veri g�nderme demek, 
                                                       --bu ifadede ise cpha '0' olaca��ndan tx mosunda y�kselen kenarda veriyi g�nderir
                                                           
                    txBuffer<=tx;                     --Mikrodenetleyiciden al�nan arabellek veriyi txBuffer sinyaline at�yor
                    clk_toggles<=0;                   --saat tersleme say�c�s�n� ba�lat
                    last_bit <= data_length*2 + conv_integer(cpha)-1;          --Son rx biti olu�umu
                                                                              --cpha '0' olaca��ndan, bu de�er son bit 31 olan son y�kselen kenar�d�r
                    state <= execute;
                    
                    else
                        state <= init;
                    end if;                                                               
                                                                                
                when execute =>
                    busy <= '1';
                    INT_ss_n <= '0';                                  --Slave se�im sinyalini d���k yapmam�z cihaz� se�tik sinyalini g�nderir
                    receive_transmit <= not receive_transmit;         --Al�c� verici modu de�i�imi
                    
                    --Say�c� 
                    if (clk_toggles =data_length*2 +1) then
                        clk_toggles <= 0;                             --Say�c� S�f�rlama(Reset)
                    else
                        clk_toggles <= clk_toggles + 1;               --Say�c� art�r�m�     
                    end if;
                    
                    --Saat Terslemesi
                    if (clk_toggles <= clk_toggles*2 and INT_ss_n= '0') then                   --Saatin �ift kenarlar�nda hep bir bit g�nderiliyor bu y�zden �arp� 2 ve tabiki cihaz�n se�ili olmas� gerekir
                        INT_sclk <= not INT_sclk;                                              --Spi saat Terslemesi
                    end if;    
                    
                    --Al�nan miso Bit
                    if (receive_transmit = '0' and clk_toggles < last_bit +1 and INT_ss_n = '0') then       --receive_transmit '0' demek rx den veriyi g�nderiyor
                        rxBuffer <= rxBuffer(data_length-2 downto 0) & miso;                                --Sola kayd�rma yap�l�yor
                    end if;
                    
                    --G�nderilen mosi Bit
                    if (receive_transmit = '1' and clk_toggles < last_bit) then
                        mosi <= txBuffer(data_length-1);
                        txBuffer <= txBuffer(data_length-2 downto 0) & '0';                                  --Sola kayd�rma
                    end if;        
                    
                    --Bitirme/Bekletme haberle�me i�lemleri
                    if (clk_toggles = data_length*2 +1) then
                        busy <= '0';
                        INT_ss_n <= '1';
                        mosi <='Z';
                        rx <= rxBuffer;
                        state <= init;
                    else
                        state <= execute;
                    end if;
                end case;
            end if;
        end process;
    end Behavioral;                        
                    
                    
                    





