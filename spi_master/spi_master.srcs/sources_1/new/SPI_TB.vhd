----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 27.12.2020 16:14:29
-- Design Name: 
-- Module Name: SPI_TB - Behavioral
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


LIBRARY ieee;
USE ieee.STD_LOGIC_1164.ALL; 
USE ieee.numeric_std.ALL;
 
ENTITY SPI_TB IS
END SPI_TB;
 
ARCHITECTURE behavior OF SPI_TB IS 
 
    --Bile�en(component) tan�mlamas� UUT i�in 
 
    COMPONENT spi_master
    PORT(
         clk 		: IN  STD_LOGIC;
         reset_n 	: IN  STD_LOGIC;
         enable 	: IN  STD_LOGIC;
		 cpol    	: IN  STD_LOGIC;
		 cpha    	: IN  STD_LOGIC;
		 miso		: IN  STD_LOGIC;
         sclk 		: OUT STD_LOGIC;
         ss_n 		: OUT STD_LOGIC;
         mosi 		: OUT STD_LOGIC;
         busy 		: OUT STD_LOGIC;
         tx 		: IN  STD_LOGIC_VECTOR(15 downto 0);
         rx 		: OUT STD_LOGIC_VECTOR(15 downto 0)
        );
    END COMPONENT;
	 
	COMPONENT spi_slave
	  PORT(
		 reset_n      : IN     STD_LOGIC; 
    	 cpol    	  : IN 	  STD_LOGIC;  																	 
         cpha    	  : IN 	  STD_LOGIC;  																	 
		 sclk         : IN     STD_LOGIC; 
		 ss_n         : IN     STD_LOGIC; 
		 mosi         : IN     STD_LOGIC; 
		 miso         : OUT    STD_LOGIC;
		 rx_enable    : IN     STD_LOGIC; 
		 tx 			  : IN     STD_LOGIC_VECTOR(15 DOWNTO 0);  
		 rx           : OUT    STD_LOGIC_VECTOR(15 DOWNTO 0);  
		 busy         : OUT    STD_LOGIC  
		 ); 
	END COMPONENT;		

	COMPONENT clk_gen is
		 port ( 
			clk 	 : out STD_LOGIC);
	END COMPONENT;

	SIGNAL clk, miso, mosi, sclk, ss_n, busy_slave, busy_master, reset_n :STD_LOGIC;
	SIGNAL start :STD_LOGIC := '0';
	SIGNAL enable, rx_enable:STD_LOGIC := '1';
	SIGNAL rx_master, rx_slave: STD_LOGIC_VECTOR(15 downto 0);

	-- Master ve Slave cihazlar�na aktar�lacak veriler:
	SIGNAL tx_master: STD_LOGIC_VECTOR(15 downto 0) := "1111111100000000";
	SIGNAL tx_slave:  STD_LOGIC_VECTOR(15 downto 0) := "0000000011111111";
	
	-- Master ve Slave i�in CPHA ve CPOL yap�land�r�lmas�
	SIGNAL cpha :STD_LOGIC := '0';
	SIGNAL cpol :STD_LOGIC := '0';

	
BEGIN
 
	-- UUT Ba�latma (Unit Under Test)
   uut1: spi_master PORT MAP (
          clk => clk,
          reset_n => reset_n,
          enable => enable,
		  cpol => cpol,
		  cpha => cpha,
          miso => miso,
          sclk => sclk,
          ss_n => ss_n,
          mosi => mosi,
          busy => busy_master,
          tx => tx_master,
          rx => rx_master
        );
		  
	uut2: spi_slave PORT MAP (
		     reset_n => reset_n,       
       	     cpol => cpol,  	    																	 
             cpha => cpha,  	    																	 
			 sclk => sclk, 
			 ss_n => ss_n, 
			 mosi => mosi, 
			 miso => miso,
			 rx_enable => rx_enable, 
			 tx => tx_slave,   
			 rx	=> rx_slave, 
			 busy => busy_slave  			  
	);	  
		
	
   uut3: clk_gen PORT MAP (
			 clk  => clk 
	);
			 
			 

	PROCESS(clk)
	BEGIN
	IF (rising_edge(clk)) then
		IF(start = '0') then		
			start <= '1';
			reset_n <= '0';
		ELSIF(start = '1') then
			start <= '1';
			reset_n <= '1';		
		END IF;
	END IF;
	END PROCESS;

END;