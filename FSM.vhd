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
    bdir : out  STD_LOGIC_VECTOR (7 downto 0); --bus direcciones
    bdatin : out  STD_LOGIC_VECTOR (3 downto 0); --bus datos que introduce info en la memoria
    bdatout : in  STD_LOGIC_VECTOR (3 downto 0); --bus datos que saxa datos de la memoria
    rw : out STD_LOGIC_VECTOR(0 downto 0)); --seal de lectura/escritura
	 
	 end FSM;

architecture Behavioral of FSM is
   type mi_estado is (Inicio, Reposo, Movimiento,CalculoCasilla , Analisis, KO, Avanza,Sumar, OK1, OK2, OK3, OK, Ponpez); --estados
   signal estado,p_estado: mi_estado;
   signal cuenta, p_cuenta: unsigned(4 downto 0); --contador
   signal pDserp,Dserp,pnxDserp,nxDserp,Dcola,pDcola: unsigned(7 downto 0); --registros de direcciones
   signal pcasilla, casilla : std_logic_vector (3 downto 0); --registro para analizar las casillas
   signal pRS,RS :std_logic_vector (4 downto 0); --bms bit de inicio, 3 y 2 mov cola, 1 y 0 mov cabeza
signal mov,pmov :  STD_LOGIC_VECTOR (1 downto 0); --vector de movimiento
signal direcciones : std_logic_vector (3 downto 0); --Para codificar el movimiento
signal bdirs, pbdirs : std_logic_vector (7 downto 0); --Seales para hacer sincronas esa salida
signal bdatins, pbdatins : std_logic_vector (3 downto 0); -- Seales para hacer sincrona la salida
signal auxtframe,pflag,flag: std_logic;
signal pezcnt, p_pezcnt : unsigned (7 downto 0); --Seal para el contador para pintar el pescado
signal bdatouts: std_logic_vector (3 downto 0); --Seal que se corresponde con bdataout para el pescado
begin
	
direcciones(0)<=UP;
direcciones(1)<=RIG;
direcciones(2)<=LEF;
direcciones(3)<=DOW;
comb:process (direcciones,mov,tframe, flag) --Codificacin para el movimiento
	begin
		if (tframe='0') then
		pflag<='1';
		else
		pflag<='0';
		end if;
		if (flag='0' and tframe='0') then
		auxtframe<='1';
		else
		auxtframe<='0';
		end if;
				
		
		case direcciones is
			when "0001" => -- arriba
				pmov <= "00";
			when "0010" => -- derecha
				pmov <= "01";
			when "0100" => -- izquierda
				pmov <= "10";
			when "1000" => -- abajo
				pmov <= "11";
			when others =>
				pmov <= mov;
		end case;
	end process;
-----------------------------------------------------------
-----------------------------------------------------------

-----------------------------------------------------------
-----------------------------------------------------------

   estadosync: process (clk, reset) --Actualizacin de datos --tframe
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
					bdirs <= (others => '0'); -- OJO, si reset=1, la dir de mem va a 0.
					bdatins <= (others => '0'); -- OJO. Este realmente debe tener el valor que vaya en la dir "00..0"
					flag<='0';
			  elsif (rising_edge(clk) and reset='0') then
               estado<=p_estado;
--					if(tframe='0') then
						cuenta<=p_cuenta;
--					end if;
					Dserp <= pDserp;
					Dcola <= pDcola;
					casilla <= pcasilla;
					nxDserp <= pnxDserp;
					RS <= pRS;
					mov<=pmov;
					bdirs <= pbdirs;
					bdatins <= pbdatins;
					flag<=pflag;
           end if;
       end process;
-----------------------------------------------------------
-- Conexion de las seales a las salidas.
bdir <= bdirs;
bdatin <= bdatins;
bdatouts <= bdatout;
-----------------------------------------------------------
pescadoc: process(pezcnt)
	begin
		if (pezcnt<240) then
			p_pezcnt<=pezcnt+1;
		else
			p_pezcnt<=(others=>'0');
		end if;
	end process;
------------------------------------------------------------

   combi: process(estado,cuenta,mov,bdatout,Dserp,Dcola,direcciones,RS,nxDserp,casilla,bdirs,bdatins,auxtframe,pezcnt,bdatouts)
       begin
				pDserp <= Dserp;
			  pnxDserp <= nxDserp;
			  pDcola <= Dcola;
			  pcasilla <= casilla;
			  p_cuenta <= cuenta;
			  pbdirs <= bdirs; --aunque la seal este aqu sigue dando latch
			  pbdatins <= bdatins; -- the same
           case estado is
-----------------------------------------------------------
					when inicio =>
						rw<="0";
						pRS (3 downto 0) <= (others => '0');	
						pRS(4)<='1'; --bit de inicio
				 if (direcciones/="0000") then 
					pRS(1 downto 0)<=mov;
					p_estado<=inicio;
				elsif (direcciones="0000" and mov/="00") then
					p_estado<=reposo;
				 else 
					p_estado<=inicio;
				 end if;
-----------------------------------------------------------
					when reposo=>
							rw<="0";
							pRS (3 downto 0) <= RS (3 downto 0);
                   if(RS(4)='1') then --se viene de inicio
                     pRS(4)<='0';
                     p_estado<=movimiento;
                 else
                    pRS(4)<='0';
                    p_estado<=movimiento;
               end if;
-----------------------------------------------------------
					when Movimiento=>
						rw<="0";
                 case RS(1 downto 0) is --se ve el ultimo movimiento
                    when "00" => --arriba
						  pRS (4 downto 2) <= RS (4 downto 2);
                         if (mov/="11" and cuenta=CNT) then --si no se esta realizando el mov contrario se guarda
                            pRS(1 downto 0)<=mov;
									 p_estado <= CalculoCasilla;
                            p_cuenta<=(others=>'0');
								 elsif(auxtframe = '1') then --solo aumenta la cuenta al alcanzarse un vsinc
								     p_cuenta<=cuenta+1;
									  pRS(1 downto 0)<="00"; --si no se mantiene
									  p_estado<=estado;
                         else
									 p_cuenta<=cuenta;
                            pRS(1 downto 0)<="00"; --si no se mantiene
									 p_estado <= estado;
                         end if;
          
                     when "01" => --derecha
							pRS (4 downto 2) <= RS (4 downto 2);
                         if (mov/="10" and cuenta=CNT) then --si no se esta realizando el mov contrario se guarda
                            pRS(1 downto 0)<=mov;
									 p_estado <= CalculoCasilla;
                            p_cuenta<=(others=>'0');
								 elsif(auxtframe = '1') then --solo aumenta la cuenta al alcanzarse un vsinc
								     p_cuenta<=cuenta+1;
									  pRS(1 downto 0)<="01"; --si no se mantiene
									  p_estado<=estado;
                         else
									p_cuenta<=cuenta;
                            pRS(1 downto 0)<="01"; --si no se mantiene
									 p_estado <= estado;
                         end if;
								 
                     when "10" => --izquierda
							pRS (4 downto 2) <= RS (4 downto 2);
                         if (mov/="01" and cuenta=CNT) then --si no se esta realizando el mov contrario se guarda
                            pRS(1 downto 0)<=mov;
									 p_estado <= CalculoCasilla;
                            p_cuenta<=(others=>'0');
								 elsif(auxtframe = '1') then --solo aumenta la cuenta al alcanzarse un vsinc
								     p_cuenta<=cuenta+1;
									  pRS(1 downto 0)<="10"; --si no se mantiene
									  p_estado<=estado;
                         else
									p_cuenta<=cuenta;
                            pRS(1 downto 0)<="10"; --si no se mantiene
									 p_estado <= estado;
                         end if;
								 
                     when "11" => --abajo
							pRS (4 downto 2) <= RS (4 downto 2);
                        if (mov/="00" and cuenta=CNT) then --si no se esta realizando el mov contrario se guarda
                            pRS(1 downto 0)<=mov;
									 p_estado <= CalculoCasilla;
                            p_cuenta<=(others=>'0');
								 elsif(auxtframe = '1') then --solo aumenta la cuenta al alcanzarse un vsinc
								     p_cuenta<=cuenta+1;
									  pRS(1 downto 0)<="11"; --si no se mantiene
									  p_estado<=estado;
                         else
									p_cuenta<=cuenta;
                            pRS(1 downto 0)<="11"; --si no se mantiene
									 p_estado <= estado;
                         end if;
								 
                         when others => --en otro caso(para evitar latch) se hace como si fuese hacia arriba
								 pRS (4 downto 2) <= RS (4 downto 2);
								if (mov/="11" and cuenta=CNT) then --si no se esta realizando el mov contrario se guarda
                            pRS(1 downto 0)<=mov;
									 p_estado <= CalculoCasilla;
                            p_cuenta<=(others=>'0');
								 elsif(auxtframe = '1') then --solo aumenta la cuenta al alcanzarse un vsinc
								     p_cuenta<=cuenta+1;
									  pRS(1 downto 0)<="00"; --si no se mantiene
									  p_estado<=estado;
                         else
									p_cuenta<=cuenta;
                            pRS(1 downto 0)<="00"; --si no se mantiene
									 p_estado <= estado;
                         end if;
                   end case;
-----------------------------------------------------------
					when CalculoCasilla=>
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
					 p_estado<=analisis;
-----------------------------------------------------------
					when analisis=>
					rw<="0";
						pRS<=RS;
						pbdirs<=std_logic_vector(nxDserp); --se escribe la casilla
						pcasilla<=bdatout;
						if (cuenta=6) then
								p_cuenta<=(others=>'0');
								if(casilla(3)='1')then --si el bMs es uno es muro o cola
								  p_estado<=ko;
								else
								  p_estado<=avanza; --si no avanza
								end if;
						else 
							p_cuenta<=cuenta+1;
							p_estado<=analisis;
						end if;
-----------------------------------------------------------
					when avanza=>
					rw<="0";
					pRS <= RS;
						if(casilla(1)='1')then --si el bit 1 es 1 es una seta
                    p_estado<=sumar;
						else
                    p_estado<=OK1; --si no, esta vacio
		 				 end if;
-----------------------------------------------------------
               when sumar=>
						pRS <= RS;
						rw<="1"; --se va a escribir en la memoria
						if (cuenta=6) then 
							pbdirs<=std_logic_vector(Dserp); --se escribe en la antigua cabeza un cuerpo
							pbdatins(3 downto 2)<="10";
							pbdatins(1 downto 0)<=mov;
							p_estado<=reposo;
							pDserp <= nxDserp; --Actualizar valor de la Dserp.
							pDcola <= Dserp; -- ILLO CABESA, K ASE K NO ACTULISA LA KOLITA
							p_cuenta <= (others=>'0');
						else	
							
							pbdirs<=std_logic_vector(nxDserp); --se escribe la nueva cabeza
							pbdatins(3 downto 2)<="01";
							pbdatins(1 downto 0)<=mov;
							p_estado<=sumar;
							pDcola <= Dcola;-- ILLO CABESA, K AKI NO CANVIA
							p_cuenta<=cuenta +1;
						end if;	
-----------------------------------------------------------
						when Ponpez=>
							pRS<=RS;
							rw<="0"; --se va a leer en la memoria
							pbdirs<=std_logic_vector(pezcnt); --la direccin aleatoria para posible pesacado
							if(cuenta>3) then
								if(bdatouts="0000") then
									if(cuenta>9) then
										rw<="1"; --escribimos en memoria
										pbdatins<="0011"; --cdigo del pescado
										p_estado<=reposo;
										p_cuenta<=(others=>'0');
									else
										p_cuenta<=cuenta+1;
										p_estado<=Ponpez;
									end if;
								else
									p_estado<=Ponpez;
									p_cuenta<=cuenta;
								end if;
							else
								p_cuenta<=cuenta+1;
								p_estado<=Ponpez;
							end if;
-----------------------------------------------------------
						when OK1=> --nueva cabeza de movimiento normal
						
						pRS <= RS;
						rw<="1"; --se va a escribir en la memoria
						if (cuenta=2) then
						pbdirs<=std_logic_vector(nxDserp); --se elige la nueva direccin
						pbdatins(3 downto 2)<="01"; --se escribe la nueva cabeza
						pbdatins(1 downto 0)<=mov;
						p_estado<=OK2;
						p_cuenta<=(others=>'0');
						else
						pbdirs<=std_logic_vector(nxDserp); --se elige la nueva direccin
						p_cuenta<=cuenta + 1;
						p_estado<=OK1;
						end if;
-----------------------------------------------------------
						when OK2=> --cuerpo en la antigua cabeza
						
						pRS <= RS;
						rw<="1"; --se va a escribir en la memoria
						if (cuenta=2) then
						pbdirs<=std_logic_vector(Dserp); --se elige la antigua direccin
						pbdatins(3 downto 2)<="10"; --se escribe un nuevo cuerpo
						pbdatins(1 downto 0)<=mov;
						p_estado<=OK; --OK3
						p_cuenta<=(others=>'0');
						else
						pbdirs<=std_logic_vector(Dserp); --se elige la antigua direccin
						p_cuenta<=cuenta + 1;
						p_estado<=OK2;
						end if;
-----------------------------------------------------------
						when OK3=> --se busca la cola y se guarda en casilla
						
						pRS <= RS;
						rw<="0"; --se va a leer de la memoria
						if (cuenta=2) then
						pbdirs<=std_logic_vector(Dcola); --se elige la direccin de la cola
						pcasilla<=bdatout;
						p_estado<=OK;
						p_cuenta<=(others=>'0');
						else
						pbdirs<=std_logic_vector(Dcola); --se elige la direccin de la cola
						p_cuenta<=cuenta + 1;
						p_estado<=OK2;
						end if;

-----------------------------------------------------------
						when OK=> --se limpia la cola
						pRS <= RS;
						pDserp<=nxDserp;
						pbdirs<=std_logic_vector(Dcola); --se busca la cola
						rw<="1"; --se va a escribir
						pbdatins<="0000"; --se vacia la direccion de la cola
						if (cuenta>4) then
							p_cuenta<=(others=>'0');
							p_estado<=reposo;
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
						else
							p_cuenta<=cuenta+1;
							p_estado<=OK;
						end if;
						
-----------------------------------------------------------
               when KO=>
					rw<="0";
					pRS <= RS;
					p_estado <= inicio;
           end case;
       end process;
		 
end Behavioral;
