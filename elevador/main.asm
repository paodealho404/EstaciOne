setup:
	.def temp = r16 ;Define o nome 'temp' para o registrador r16
	ldi temp, 0b00000000 ;Carrega em temp 00000000
	out DDRB, temp 

	ldi temp, 0b11111100 ;Carrega em temp 11111100
	out DDRD, temp ;Configura PORTD7 e PORTD6 como saída usadas pelo led e buzzer. 
	;Configura PORTD5, PORTD4, PORTD3 e PORTD2 como saída usadas pelo CI

	ldi temp, 0b00000000 ;Carrega em temp 00000000
	out DDRC, temp ;Na porta C terá apenas botões

	ldi temp, 0b00001111;Carrega 00001111 em temp
	out PORTB, temp ;inicializa as portas PB4 (Buzzer) e PB3 (Led) em LOW, e habilita pull-up em PB3, PB2, PB1 e PB0

	ldi temp, 0b00111111 ;Carrega 00111111 em temp
	out PORTC, temp ;Habilita pull-up em PC5, PC4, PC3, PC2, PC1 e PC0
	
	;         0b00DCBA00
	ldi temp, 0b00000000 ;Carrega 00000000 em temp
	out PORTD, temp ;inicializa as portas PD5, PD4, PD3 e PD2 (CI) em LOW, mostrando um 0 no display de 7 segmentos

	/* Tabela de estados
	* 0000 - Inicio
	* 0001 - Parado
	* 0010 - Abrir
	* 0011 - BuzzerLigado
	* 0100 - AtualizaFila
	* 0101 - MovendoCima
	* 0110 - MovendoBaixo
	* 0111 - TrocaAndar
	* 1000 - Chegou
	*/
	
	.equ inicio = 0b0000
	.equ parado = 0b0001
	.equ abrir = 0b0010
	.equ buzzerLigado = 0b0011
	.equ atualizaFila = 0b0100
	.equ movendoCima = 0b0101
	.equ movendoBaixo = 0b0110
	.equ trocaAndar = 0b0111
	.equ chegou = 0b1000

	.equ terreo   = 0b0000
	.equ primeiro = 0b0001
	.equ segundo  = 0b0010
	.equ terceiro = 0b0011

	.equ botaoInterno = 0b0000
	.equ botaoExterno = 0b0001

	; PORTD
	.equ led = PD7
	.equ buzzer = PD6
	.equ ci_D = PD5
	.equ ci_C = PD4
	.equ ci_B = PD3
	.equ ci_A = PD2
	.equ display_zero = 0b00000000
	.equ display_um   = 0b00000100
	.equ display_dois = 0b00001000
	.equ display_tres = 0b00001100

	; PORTC
	.equ botao_interno_terreo = PC0
	.equ botao_interno_andar1 = PC1
	.equ botao_interno_andar2 = PC2
	.equ botao_interno_andar3 = PC3

	.equ botao_abrir = PC4
	.equ botao_fechar = PC5

	; PORTB
	.equ botao_externo_terreo = PB0
	.equ botao_externo_andar1 = PB1
	.equ botao_externo_andar2 = PB2
	.equ botao_externo_andar3 = PB3

	.equ descendo = 0b0000
	.equ subindo 	= 0b0001

	.def state = r17 ;Define o nome 'state' para o registrador r17
	ldi state, inicio ;Define o estado para 'inicio'

	.def andarAtual = r18 ;Define o nome 'andarAtual' para o registrador r18
	ldi andarAtual, terreo ;Define o andar atual para 0

	.def andarDestino = r20 ;Define o nome 'andarDestino' para o registrador r20
	.def andarPressionado = r21 ;Define o nome 'andarPressionado' para o registrador r21
	.def localPressionado = r22 ;Define o nome 'localPressionado' para o registrador r22, 0 para interno e 1 para externo
	.def tempoAguardando = r23 ;Define o nome 'tempoAguardando' para o registrador r23
	.def sentido = r24 ;Define o nome 'sentido' para o registrador r24, 1 para cima e 0 para baixo
	.def var_chegou = r25 ;Define o nome 'var_chegou' para o registrador r25, 1 para chegou e 0 para não chegou

	.equ ClockMHz = 16 ;16MHz
	.equ DelayMs = 20 ;20ms

	rjmp loop

delay20ms:
	ldi r31, byte3(ClockMHz * 1000 * DelayMs / 5)
	ldi r30, high(ClockMHz * 1000 * DelayMs / 5)
	ldi r29, low(ClockMHz * 1000 * DelayMs / 5)

	subi r29, 1
	sbci r30, 0
	sbci r31, 0
	brcc pc-3

	ret

loop:
	sbic PINC, botao_interno_terreo ;Se o botão interno do térreo for pressionado
	rjmp botao_interno_terreo_pressed ;Pula para a rotina botao_interno_terreo_pressed

	sbic PINC, botao_interno_andar1 ;Se o botão interno do primeiro andar for pressionado
	rjmp botao_interno_andar1_pressed ;Pula para a rotina botao_interno_andar1_pressed

	sbic PINC, botao_interno_andar2 ;Se o botão interno do segundo andar for pressionado
	rjmp botao_interno_andar2_pressed ;Pula para a rotina botao_interno_andar2_pressed

	sbic PINC, botao_interno_andar3 ;Se o botão interno do terceiro andar for pressionado
	rjmp botao_interno_andar3_pressed ;Pula para a rotina botao_interno_andar3_pressed

	sbic PINB, botao_externo_terreo ;Se o botão externo do térreo for pressionado
	rjmp botao_externo_terreo_pressed ;Pula para a rotina botao_externo_terreo_pressed

	sbic PINB, botao_externo_andar1 ;Se o botão externo do primeiro andar for pressionado
	rjmp botao_externo_andar1_pressed ;Pula para a rotina botao_externo_andar1_pressed

	sbic PINB, botao_externo_andar2 ;Se o botão externo do segundo andar for pressionado
	rjmp botao_externo_andar2_pressed ;Pula para a rotina botao_externo_andar2_pressed

	sbic PINB, botao_externo_andar3 ;Se o botão externo do terceiro andar for pressionado
	rjmp botao_externo_andar3_pressed ;Pula para a rotina botao_externo_andar3_pressed

	sbic PINC, botao_abrir ;Se o botão de abrir for pressionado
	rjmp botao_abrir_pressed ; Pula para a rotina botao_abrir_pressed

	sbic PINC, botao_fechar ;Se o botão de fechar for pressionado
	rjmp botao_fechar_pressed ; Pula para a rotina botao_fechar_pressed

	rjmp maquina_estados

	botao_interno_terreo_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_interno_terreo ;Define o andar pressionado como 0
		ldi localPressionado, botaoInterno ;Define o local pressionado como interno
		rjmp maquina_estados

	botao_interno_andar1_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_interno_andar1 ;Define o andar pressionado como 1
		ldi localPressionado, botaoInterno ;Define o local pressionado como interno
		rjmp maquina_estados

	botao_interno_andar2_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_interno_andar2 ;Define o andar pressionado como 2
		ldi localPressionado, botaoInterno ;Define o local pressionado como interno
		rjmp maquina_estados

	botao_interno_andar3_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_interno_andar3 ;Define o andar pressionado como 3
		ldi localPressionado, botaoInterno ;Define o local pressionado como interno
		rjmp maquina_estados

	botao_externo_terreo_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_externo_terreo ;Define o andar pressionado como 0
		ldi localPressionado, botaoExterno ;Define o local pressionado como externo
		rjmp maquina_estados

	botao_externo_andar1_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_externo_andar1 ;Define o andar pressionado como 1
		ldi localPressionado, botaoExterno ;Define o local pressionado como externo
		rjmp maquina_estados
	
	botao_externo_andar2_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_externo_andar2 ;Define o andar pressionado como 2
		ldi localPressionado, botaoExterno ;Define o local pressionado como externo
		rjmp maquina_estados
	
	botao_externo_andar3_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_externo_andar3 ;Define o andar pressionado como 3
		ldi localPressionado, botaoExterno ;Define o local pressionado como externo
		rjmp maquina_estados

	botao_abrir_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi state, abrir

	botao_fechar_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi state, parado
		

	maquina_estados:
		; switch(state)

		cpi state, inicio
		breq case_inicio

		cpi state, parado
		breq case_parado

		cpi state, abrir
		breq case_abrir

		cpi state, buzzerLigado
		breq case_buzzerLigado

		cpi state, atualizaFila
		breq case_atualizaFila

		cpi state, movendoCima
		breq case_movendoCima

		cpi state, movendoBaixo
		breq case_movendoBaixo

		cpi state, trocaAndar
		breq case_trocaAndar

		cpi state, chegou
		breq case_chegou

		;sbic PINC, PC0 ;botão solto? ;sbic = skip if bit in I/O register cleared
		;rjmp led_on ;Não, desvia para ligar LED
		;cbi PORTB, PB4 ;Sim ,desliga LED ;cbi = clear bit in I/O register
		rjmp loop ;Volta ao começo do loop

case_inicio:
	call exec_inicio
	jmp loop
case_parado:
	call exec_parado
	jmp loop
case_abrir:
	call exec_abrir
	jmp loop
case_buzzerLigado:
	call exec_buzzerLigado
	jmp loop
case_atualizaFila:
	call exec_atualizaFila
	jmp loop
case_movendoCima:
	call exec_movendoCima
	jmp loop
case_movendoBaixo:
	call exec_movendoBaixo
	jmp loop
case_trocaAndar:
	call exec_trocaAndar
	jmp loop
case_chegou:
	call exec_chegou
	jmp loop



exec_inicio:
	ldi state, parado       ; Transição do estado para parado
	ldi andarAtual, 0		; Inicia o andarAtual como 0
	clr andarPressionado	; Inicia o andarPressionado como 0
	ret

exec_parado:
	clr tempoAguardando    ; O contador de tempoAguardando é zerado
	cbi PORTD, led         ; Desliga o LED
	cbi PORTD, buzzer      ; Desliga o Buzzer

	

	//TODO: Fazer as transições
	ret

exec_abrir:
	sbi PORTD, led 				; Liga Led 
	ldi var_chegou, 0 			; Define var_chegou como 0

	sbic PORTC, botao_fechar	; Verifica se o botao de abrir está pressionado
	rjmp t_fechar_porta        ;
	
	cpi tempoAguardando, 5
	brne t_final_abrir
	ldi state, buzzerLigado
	rjmp t_final_abrir
	
	t_fechar_porta:
		ldi state, parado

	t_final_abrir:
	ret

exec_buzzerLigado:
	sbi PORTD, buzzer 		 ; Liga Buzzer 
	
	sbic PORTC, botao_abrir  ; Verifica se o botao de abrir está pressionado
	rjmp fim_b_ligado		 ; Se pressionado pula para o fim
	
	sbic PORTC, botao_fechar ; Verifica se o botao de fechar está pressionado
	rjmp t_fechar_porta2      ; Se pressionado pula para o fim

	cpi tempoAguardando, 10  
	brge t_fechar_porta2		 ; Verifica se o tempo aguardando é maior ou igual a 5
	rjmp fim_b_ligado 		 ; Se o tempo aguardando for menor que 5 pula pro fim

	t_fechar_porta2:
		ldi state, parado    ; Vai para o estado de parado
	fim_b_ligado:
	ret

exec_atualizaFila:
	//TODO: Implementar tudo
	/* Implementacao da Fila */
	
	//Decisao do Destino 
	clr andarDestino
	add andarDestino, andarPressionado ;Define o andar destino como o andar pressionado

	cp andarAtual, andarDestino ;Compara andar destino com andar atual
	brlt destino_maior ;Desvia para destino_maior se andarAtual < andarDestino
	cp andarAtual, andarDestino ;Compara andar destino com andar atual
	breq destino_igual ;Desvia para destino_igual se andarAtual = andarDestino
	
	destino_menor:
		ldi state, movendoBaixo ;Define o estado como movendoBaixo
		rjmp desvio_final ; O elevador precisa descer

	destino_maior:
		ldi state, movendoCima
		rjmp desvio_final

	destino_igual:
		ldi state, parado

	desvio_final:
	ret


exec_movendoCima:
	ldi var_chegou, 0      ;Define var_chegou como 0
	ldi sentido, 1         ;Define sentido como 1 (Subindo)
	
	//TODO: Fazer as transições
	cpi tempoAguardando, 3 ; Compara tempoAguardando com 3
	brlt nao_subiu         ; Se tempoAguardando < 3 desvia para nao_subiu
	ldi state, trocaAndar  ; Se tempoAguardando >= 3 define o estado como trocaAndar

	nao_subiu:
	
	ret

exec_movendoBaixo:
	ldi var_chegou, 0      ;Define var_chegou como 0
	ldi sentido, 0         ;Define sentido como 1 (Subindo)
	//TODO: Fazer as transições
	cpi tempoAguardando, 3 ; Compara tempoAguardando com 3
	brlt nao_desceu        ; Se tempoAguardando < 3 desvia para nao_subiu
	ldi state, trocaAndar  ; Se tempoAguardando >= 3 define o estado como trocaAndar
	
	nao_desceu:

	ret

exec_trocaAndar:
	clr tempoAguardando  		    ; Zera o tempoAguardando
	
	cpi sentido, 1 			  	    ; Compara o sentido com 1
	brne subtrai_andar 			    ; se sentido != 1 desvia para subtrai_andar
	subi andarAtual, -1   		  ; Se sentido == 1 soma 1 ao andarAtual
	rjmp t_ok_calc        		  ; Se o andarAtual já foi alterado pula para t_ok_calc

	subtrai_andar: 
	subi andarAtual, 1          ; Se sentido != 1 subtrai 1 do andarAtual  

	t_ok_calc:
	cp andarAtual, andarDestino ; Compara andarAtual com andarDestino
	brne t_nao_chegou           ; Se andarAtual != andarDestino desvia para t_nao_chegou
	ldi state, chegou           ; Se andarAtual == andarDestino define o estado como chegou
	rjmp t_fim_troca_andar     ; Se o elevador já chegou no andar destino pula para t_fim_troca_andar

	t_nao_chegou:
	cpi sentido, 1              ; Compara o sentido com 1
	brne volta_a_descer         ; Se sentido != 1 desvia para volta_a_descer
	ldi state, movendoCima      ; Se sentido == 1 define o estado como movendoCima
	rjmp t_fim_troca_andar      ; O elevador não chegou no andar destino, mas ele precisa continuar a subir

	volta_a_descer: 
	ldi state, movendoBaixo     ; O elevador não chegou no andar destino, mas ele precisa continuar a descer

	t_fim_troca_andar:
	ret

exec_chegou:
	ldi var_chegou, 1 ;Define var_chegou como 1
	ldi state, atualizaFila

	ret

led_on:
	cpi andarPressionado, 0
	brne next1
	rcall set_display_zero

	next1:
	cpi andarPressionado, 1
	brne next2
	rcall set_display_um

	next2:
	cpi andarPressionado, 2
	brne next3
	rcall set_display_dois

	next3:
	cpi andarPressionado, 3
	brne continue
	rcall set_display_tres

	continue: 

	;ldi temp, display_dois
	ldi r19, (1 << led)
	or temp, r19
	out PORTD, temp
	;sbi PORTD, led ;Liga LED ;sbi set bit in I/O register
	;sbi PORTD, buzzer ;Liga Buzzer ;sbi set bit in I/O register
	rjmp loop


set_display_zero:
	ldi temp, display_zero
	ret

set_display_um:
	ldi temp, display_um
	ret

set_display_dois:
	ldi temp, display_dois
	ret

set_display_tres:
	ldi temp, display_tres
	ret
