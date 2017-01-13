library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity FSM is
	Generic( CNT: integer :=26); -- numero de veces que cuenta antes de hacer otro movimiento
    Port (
	 reset : in std_logic;
	 clk : in std_logic;
	 tframe : in std_logic; --señal vsinc del vga, está a 0 un clk al refrescar terminar una pantalla    
	UP : in STD_LOGIC;
	LEF : in STD_LOGIC;
	RIG : in STD_LOGIC;
	DOW : in STD_LOGIC;
--  FSM_Plotter : out  STD_LOGIC_VECTOR (1 downto 0); --información que se enviará al plotter y a la musica
    bdir : out  STD_LOGIC_VECTOR (7 downto 0); --bus direcciones
    bdata : in  STD_LOGIC_VECTOR (4 downto 0); --bus datos
    rw : out STD_LOGIC);--señal de lectura/escritura
end FSM;

architecture Behavioral of FSM is
   type mi_estado is (Inicio, Reposo, Movimiento,  Analisis, KO, Avanza, Sumar, OK); --estados
   signal estado,p_estado: mi_estado;
   signal cuenta, p_cuenta: unsigned(4 downto 0); --contador
   signal flag: std_logic; --para evitar que cuente de más
   signal Dserp,p_Dserp,Dcola,p_Dcola : unsigned(7 downto 0); --registros de direcciones
   signal p_casilla : std_logic_vector (3 downto 0); --registro para analizar las casillas
   signal RS :std_logic_vector (4 downto 0); --bms bit de inicio, 3 y 2 mov cola, 1 y 0 mov cabeza
signal mov,pmov :  STD_LOGIC_VECTOR (1 downto 0); --vector de movimiento
signal direcciones : std_logic_vector (3 downto 0); --Para codificar el movimiento
begin
	
direcciones(0)<=UP;
direcciones(1)<=LEF;
direcciones(2)<=RIG;
direcciones(3)<=DOW;
comb:process (direcciones,mov) --Codificación para el movimiento
	begin
		case direcciones is
			when "0001" => --
				pmov <= "00";
			when "0010" => --
				pmov <= "01";
			when "0100" =>
				pmov <= "10";
			when "1000" =>
				pmov <= "11";
			when others =>
				pmov <= mov;
		end case;
	end process;
-----------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------
   contcomb: process (tframe, cuenta) --Contador
       begin
           if (tframe='0' and flag='0') then
               flag<='1';
               p_cuenta<=cuenta+1;
           elsif (tframe='0' and flag='1') then
               flag<='1';
               p_cuenta<=cuenta;
           else
               flag<='0';
               p_cuenta<=cuenta;
           end if;
       end process;
-----------------------------------------------------------
-----------------------------------------------------------

   estadosync: process (clk, reset) --Actualización de datos
       begin
           if (reset='1')then
               estado<=Inicio;
               cuenta<=(others=>'0');
	   	mov<="00";
           elsif (rising_edge(clk) and reset='0') then
               estado<=p_estado;
               cuenta<=p_cuenta;
		pmov<=mov;
           end if;
       end process;
-----------------------------------------------------------
-----------------------------------------------------------

   comb: process(estado,cuenta,mov,bdir,bdata,dserp,dcola)
       begin
           case estado is
			  
-----------------------------------------------------------
					when inicio =>
                 RS(4)<='1'; --bit de inicio
-----------------------------------------------------------
					when reposo=>
                   if(RS(4)='1') then --se viene de inicio
                    RS(1 downto 0)<=mov;
                     RS(4)<='0';
                     p_estado<=movimiento;
                 else
                    RS(4)<='0';
                    p_estado<=movimiento;
               end if;
-----------------------------------------------------------
					when Movimiento=>
                 case RS(1 downto 0) is --se ve el ultimo movimiento
                    when "00" => --arriba
                         if (mov/="11") then --si no se esta realizando el mov contrario se guarda
                            RS(1 downto 0)<=mov;
                         else
                            RS(1 downto 0)<="00"; --si no se mantiene
                         end if;
                        if (cuenta = CNT) then --si la cuenta llega al final se avanza
                              p_estado <= analisis;
                             p_cuenta<=(others=>'0');
                          else
                              p_estado <= estado;
                             p_cuenta<=cuenta;
                         end if;
                     when "01" => --derecha
                         if (mov/="10") then
                            RS(1 downto 0)<=mov;
                         else
                            RS(1 downto 0)<="01";
                         end if;
                        if (cuenta = CNT) then
                              p_estado <= analisis;
                             p_cuenta<=(others=>'0');
                          else
                              p_estado <= estado;
                             p_cuenta<=cuenta;
                         end if;        
                     when "10" => --izquierda
                         if (mov/="01") then
                            RS(1 downto 0)<=mov;
                         else
                            RS(1 downto 0)<="10";
                         end if;
                        if (cuenta = CNT) then
                              p_estado <= analisis;
                             p_cuenta<=(others=>'0');
                          else
                              p_estado <= estado;
                             p_cuenta<=cuenta;
                         end if;
                     when "11" => --abajo
                        if (mov/="00") then
                           RS(1 downto 0)<=mov;
                         else
									RS(1 downto 0)<="11";
                        end if;
                        if (cuenta = CNT) then
										p_estado <= analisis;
										p_cuenta<=(others=>'0');
                          else
                              p_estado <= estado;
										p_cuenta<=cuenta;
                         end if;
                         when others => --en otro caso(para evitar latch) se hace como si fuese hacia arriba
										if (mov/="11") then
										RS(1 downto 0)<=mov;
                         else
                            RS(1 downto 0)<="00";
                        end if;
                        if (cuenta = CNT) then
                              p_estado <= analisis;
										p_cuenta<=(others=>'0');
                        else
                              p_estado <= estado;
										p_cuenta<=cuenta;
                        end if;
                   end case;
-----------------------------------------------------------
					when analisis=>
                case RS(1 downto 0) is --se genera la proxima direccion de la cabeza
                    when "00" =>
                         p_Dserp <= Dserp - 16; --se resta una linea vertical
                    when "01" =>
                         p_Dserp <= Dserp + 1; --se suma una horizontal    
                    when "10" =>
                         p_Dserp <= Dserp - 1; --se resta una horizontal
                    when "11" =>
                         p_Dserp <= Dserp + 16; --se suma una vertical
                        when others =>
                             p_Dserp <= Dserp;
                  end case;
                bdir<=std_logic_vector(p_Dserp); --se escribe la casilla
                p_casilla<=bdata;
						if(p_casilla(3)='1')then --si el bms es uno es muro o cola
                    p_estado<=ko;
						else
                    p_estado<=avanza; --si no avanza
						end if;
-----------------------------------------------------------
					when avanza=>
						if(p_casilla(1)='1')then --si el bit 1 es 1 es una seta
                    p_estado<=sumar;
						else
                    p_estado<=ok; --si no, esta vacio
						 end if;
-----------------------------------------------------------
               when sumar=>
						rw<='1'; --se va a escribir en la memoria
						bdir<=std_logic_vector(p_Dserp); --se escribe la nueva cabeza
						bdata(3 downto 0)<="01";
						bdata(0 downto 1)<=mov;
						  
						bdir<=std_logic_vector(Dserp); --se escribe en la antigua cabeza un cuerpo
						bdata(3 downto 0)<="10";
                  bdata(0 downto 1)<=mov;
						p_estado<=reposo;
-----------------------------------------------------------
						when OK=>
						rw<='1'; --se va a escribir en la memoria
						bdir<=std_logic_vector(p_Dserp); --se escribe la nueva cabeza
						bdata(3 downto 0)<="01";
						bdata(0 downto 1)<=mov;
						
						bdir<=std_logic_vector(Dserp); --se escribe en la antigua cabeza un cuerpo
						bdata(3 downto 0)<="10";
						bdata(0 downto 1)<=mov;
						
						rw<='0'; -- se va a leer
						bdir<=std_logic_vector(Dcola); --se busca la cola
						p_casilla<=bdata; --se guarda el valor
						
						rw<='1'; --se va a escribir
						bdir<=std_logic_vector(Dcola); --se busca la cola
						bdata<="0000"; --se vacia la direccion de la cola
						case p_casilla(1 downto 0) is --se actualiza la direccion de la cola
							when "00" =>
								Dcola <= Dcola - 16; --se resta una linea vertical
							when "01" =>
                        Dcola <= Dcola + 1; --se suma una horizontal    
							when "10" =>
                        Dcola <= Dcola - 1; --se resta una horizontal
							when "11" =>
                        Dcola <= Dcola + 16; --se suma una vertical
							when others =>
								Dcola <= Dcola;
							end case;
						p_estado<=reposo; 
-----------------------------------------------------------
               when KO=>
                   p_estado <= reposo;
           end case;
       end process;
		 
end Behavioral;
