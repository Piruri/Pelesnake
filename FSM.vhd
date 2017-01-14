library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

use IEEE.NUMERIC_STD.ALL;

entity FSM is
	Generic( CNT: integer :=26); -- numero de veces que cuenta antes de hacer otro movimiento
    Port (
	 reset : in std_logic;
	 clk : in std_logic;
	 tframe : in std_logic; --seal vsinc del vga, est a 0 un clk al refrescar terminar una pantalla    
	UP : in STD_LOGIC;
	LEF : in STD_LOGIC;
	RIG : in STD_LOGIC;
	DOW : in STD_LOGIC;
--  FSM_Plotter : out  STD_LOGIC_VECTOR (1 downto 0); --informacin que se enviar al plotter y a la musica
    bdir : out  STD_LOGIC_VECTOR (7 downto 0); --bus direcciones
    bdatin : out  STD_LOGIC_VECTOR (3 downto 0); --bus datos que introduce info en la memoria
    bdatout : in  STD_LOGIC_VECTOR (3 downto 0); --bus datos que saxa datos de la memoria
    rw : out STD_LOGIC_vector(0 downto 0);--seal de lectura/escritura
	 muerto : out STD_LOGIC; --es una seal para que el top se ponga a resetear la chulamaquina
	 revivio : in STD_LOGIC); -- nos indica que el top ya ha resetado la chulamaquina (chulamaquina igual a tablero)
end FSM;

architecture Behavioral of FSM is
   type mi_estado is (Inicio, Reposo, Movimiento,  Analisis, KO, Avanza, Sumar, OK); --estados
   signal estado,p_estado: mi_estado;
   signal cuenta, p_cuenta: unsigned(4 downto 0); --contador
   signal pDserp,Dserp,pnxDserp,nxDserp,Dcola,pDcola: unsigned(7 downto 0); --registros de direcciones
   signal pcasilla, casilla : std_logic_vector (3 downto 0); --registro para analizar las casillas
   signal pRS,RS :std_logic_vector (4 downto 0); --bms bit de inicio, 3 y 2 mov cola, 1 y 0 mov cabeza
signal mov,pmov :  STD_LOGIC_VECTOR (1 downto 0); --vector de movimiento
signal direcciones : std_logic_vector (3 downto 0); --Para codificar el movimiento
begin
	
direcciones(0)<=UP;
direcciones(1)<=LEF;
direcciones(2)<=RIG;
direcciones(3)<=DOW;
comb:process (direcciones,mov) --Codificacin para el movimiento
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

-----------------------------------------------------------
-----------------------------------------------------------

   estadosync: process (clk, reset, tframe) --Actualizacin de datos
       begin
           if (reset='1')then
               estado<=Inicio;
					Dserp <= "01101000"; -- Direcciones iniciales de posicion
					nxDserp <= (others => '0');
					Dcola <= "01101000";
					casilla <= (others => '0');
					RS <= (others=>'0');
               cuenta<=(others=>'0');
					
	   	mov<="00";
           elsif (rising_edge(clk) and reset='0' and tframe='0') then
               estado<=p_estado;
               cuenta<=p_cuenta;
					Dserp <= pDserp;
					Dcola <= pDcola;
					casilla <= pcasilla;
					nxDserp <= pnxDserp;
					RS <= pRS;
					mov<=pmov;
           end if;
       end process;
-----------------------------------------------------------
-----------------------------------------------------------

   combi: process(estado,cuenta,mov,bdatout,dserp,dcola,direcciones,rs,nxDserp,casilla,revivio)
       begin
				pDserp <= Dserp;
			  pnxDserp <= nxDserp;
			  pDcola <= Dcola;
			  pcasilla <= casilla;
			  p_cuenta <= cuenta;
			  bdir <= (others => '0');
			  bdatin <= (others => '0');
           case estado is
-----------------------------------------------------------
					when inicio =>
					muerto<='0';
						rw<="0";
						pRS (3 downto 0) <= RS (3 downto 0);	
						pRS(4)<='1'; --bit de inicio
	       if (direcciones/="0000") then p_estado<=reposo;
	       else p_estado<=inicio;
	       end if;
-----------------------------------------------------------
					when reposo=>
							muerto<='0';
							rw<="0";
							pRS (3 downto 0) <= RS (3 downto 0);
                   if(RS(4)='1') then --se viene de inicio
                    pRS(1 downto 0)<=mov;
                     pRS(4)<='0';
                     p_estado<=movimiento;
                 else
                    pRS(4)<='0';
                    p_estado<=movimiento;
               end if;
-----------------------------------------------------------
					when Movimiento=>
					muerto<='0';
						rw<="0";
                 case RS(1 downto 0) is --se ve el ultimo movimiento
                    when "00" => --arriba
						  pRS (4 downto 2) <= RS (4 downto 2);
                         if (mov/="11" and cuenta = CNT) then --si no se esta realizando el mov contrario se guarda
                            pRS(1 downto 0)<=mov;
									 p_estado <= analisis;
                            p_cuenta<=(others=>'0');
                         else
                            pRS(1 downto 0)<="00"; --si no se mantiene
									 p_estado <= estado;
                            p_cuenta<=cuenta+1;
                         end if;
          
                     when "01" => --derecha
							pRS (4 downto 2) <= RS (4 downto 2);
                         if (mov/="10" and cuenta = CNT) then
                            pRS(1 downto 0)<=mov;
									 p_estado <= analisis;
                            p_cuenta<=(others=>'0');
                         else
                            pRS(1 downto 0)<=RS(1 downto 0);
									 p_estado <= estado;
                            p_cuenta<=cuenta+1;
                         end if;
								 
                     when "10" => --izquierda
							pRS (4 downto 2) <= RS (4 downto 2);
                         if (mov/="01"and cuenta = CNT) then
                            pRS(1 downto 0)<=mov;
									 p_estado <= analisis;
                            p_cuenta<=(others=>'0');
                         else
                            pRS(1 downto 0)<=RS(1 downto 0);
									 p_estado <= estado;
                            p_cuenta<=cuenta+1;
                         end if;
								 
                     when "11" => --abajo
							pRS (4 downto 2) <= RS (4 downto 2);
                        if (mov/="00"and cuenta = CNT) then
                            pRS(1 downto 0)<=mov;
									 p_estado <= analisis;
                            p_cuenta<=(others=>'0');
                         else
                            pRS(1 downto 0)<=RS(1 downto 0);
									 p_estado <= estado;
                            p_cuenta<=cuenta+1;
                         end if;
								 
                         when others => --en otro caso(para evitar latch) se hace como si fuese hacia arriba
								 pRS (4 downto 2) <= RS (4 downto 2);
								if (mov/="11"and cuenta = CNT) then
                            pRS(1 downto 0)<=mov;
									 p_estado <= analisis;
                            p_cuenta<=(others=>'0');
                         else
                            pRS(1 downto 0)<=RS(1 downto 0);
									 p_estado <= estado;
                            p_cuenta<=cuenta+1;
                         end if;
                   end case;
-----------------------------------------------------------
					when analisis=>
					muerto<='0';
					rw<="0";
					pRS <= RS;
                case RS(1 downto 0) is --se genera la proxima direccion de la cabeza
                    when "00" =>
                         pnxDserp <= Dserp - 16; --se resta una linea vertical
                    when "01" =>
                         pnxDserp <= Dserp + 1; --se suma una horizontal    
                    when "10" =>
                         pnxDserp <= Dserp - 1; --se resta una horizontal
                    when "11" =>
                         pnxDserp <= Dserp + 16; --se suma una vertical
                        when others =>
                             pnxDserp <= Dserp;
                  end case;
						rw<="0";
                bdir<=std_logic_vector(nxDserp); --se escribe la casilla
                pcasilla<=bdatout;
						if(casilla(3)='1')then --si el bMs es uno es muro o cola
                    p_estado<=ko;
						else
                    p_estado<=avanza; --si no avanza
						end if;
-----------------------------------------------------------
					when avanza=>
					muerto<='0';
					rw<="0";
					pRS <= RS;
						if(casilla(1)='1')then --si el bit 1 es 1 es una seta
                    p_estado<=sumar;
						else
                    p_estado<=ok; --si no, esta vacio
		 				 end if;
-----------------------------------------------------------
               when sumar=>
					muerto<='0';
					pRS <= RS;
						rw<="1"; --se va a escribir en la memoria
						bdir<=std_logic_vector(nxDserp); --se escribe la nueva cabeza
						bdatin(3 downto 2)<="01";
						bdatin(1 downto 0)<=mov;
						  
						bdir<=std_logic_vector(Dserp); --se escribe en la antigua cabeza un cuerpo
						bdatin(3 downto 2)<="10";
                  bdatin(1 downto 0)<=mov;
						p_estado<=reposo;
						pDserp <= nxDserp; --Actualizar valor de la Dserp.
-----------------------------------------------------------
						when OK=>
						muerto<='0';
						pRS <= RS;
						rw<="1"; --se va a escribir en la memoria
						bdir<=std_logic_vector(nxDserp); --se escribe la nueva cabeza
						bdatin(3 downto 2)<="01";
						bdatin(1 downto 0)<=mov;
						
						bdir<=std_logic_vector(Dserp); --se escribe en la antigua cabeza un cuerpo
						bdatin(3 downto 2)<="10";
						bdatin(1 downto 0)<=mov;
						pDserp <= nxDserp; --Actualizar valor de la Dserp.
						
						rw<="0"; -- se va a leer
						bdir<=std_logic_vector(Dcola); --se busca la cola
						pcasilla<=bdatout; --se guarda el valor
						
						rw<="1"; --se va a escribir
						bdir<=std_logic_vector(Dcola); --se busca la cola
						bdatin<="0000"; --se vacia la direccion de la cola
						case casilla(1 downto 0) is --se actualiza la direccion de la cola
							when "00" =>
								pDcola <= Dcola - 16; --se resta una linea vertical
							when "01" =>
                        pDcola <= Dcola + 1; --se suma una horizontal    
							when "10" =>
                        pDcola <= Dcola - 1; --se resta una horizontal
							when "11" =>
                        pDcola <= Dcola + 16; --se suma una vertical
							when others =>
								pDcola <= Dcola;
							end case;
						p_estado<=reposo; 
-----------------------------------------------------------
               when KO=>
					rw<="0";
					pRS <= RS;
						muerto<='1';
						if (revivio='1') then
                   p_estado <= inicio;
						else p_estado<=estado;
						end if;
           end case;
       end process;
		 
end Behavioral;
