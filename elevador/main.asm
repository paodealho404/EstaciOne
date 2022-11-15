.cseg
jmp setup
.org OC1Aaddr
jmp timer_1_sec_interrupt

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

	.equ naoPressionado = 0b0000 ;Identifica se algum botão foi pressionado ou se a fila está vazia
	.equ botaoInterno = 0b0001
	.equ botaoExterno = 0b0010

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
	.def tipoChamado = r22 ;Define o nome 'tipoChamado' para o registrador r22, 1 para interno e 2 para externo
	.def tempoAguardando = r23 ;Define o nome 'tempoAguardando' para o registrador r23
	.def sentido = r24 ;Define o nome 'sentido' para o registrador r24, 1 para cima e 0 para baixo
	.def var_chegou = r25 ;Define o nome 'var_chegou' para o registrador r25, 1 para chegou e 0 para não 


	.equ ClockMHz = 16 ;16MHz
	.equ DelayMs = 20 ;20ms
	
	/* Configurando Timer de 1 segundo */
	.equ TimerDelaySeg = 1
	.equ PreScaleDiv = 256
	.equ PreScaleMask = 0b100
	.equ TOP = int(0.5 + ((ClockMhz*1000000/PreScaleDiv)*TimerDelaySeg)); 1s --> TOP = 62500 com prescaler de 256
	.equ WGM = 0b0100 ; Configura o modo de operação do timer para CTC 

	ldi temp, high(TOP) ; Carregando TOP em OCR1A
	sts OCR1AH, temp    
	ldi temp, low(TOP)
	sts OCR1AL, temp

	ldi temp, ((WGM&0b11)<<WGM10) ; Carrega WGM e PreScale
	sts TCCR1A, temp 
	ldi temp, ((WGM>> 2) << WGM12)|(PreScaleMask << CS10)
	sts TCCR1B, temp 

	lds temp, TIMSK1
	sbr temp, 1 <<OCIE1A
	sts TIMSK1, temp

	rjmp loop

timer_1_sec_interrupt:
	push r16
	in r16, SREG
	push r16
	
	cpi state, parado								;Compara o estado com o estado parado
	breq timer_1_sec_interrupt_end  ;Se state == parado, não incrementa o tempoAguardando
	inc tempoAguardando
	 

	timer_1_sec_interrupt_end:	
		pop r16
		out SREG, r16
		pop r16
	

	sei
	reti

debounce:
	ldi r31, byte3(ClockMHz * 1000 * DelayMs / 5)
	ldi r30, high(ClockMHz * 1000 * DelayMs / 5)
	ldi r29, low(ClockMHz * 1000 * DelayMs / 5)

	subi r29, 1
	sbci r30, 0
	sbci r31, 0
	brcc pc-3

	ret

loop:
	sei
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

	;sbic PINC, botao_abrir ;Se o botão de abrir for pressionado
	;rjmp botao_abrir_pressed ; Pula para a rotina botao_abrir_pressed

	;sbic PINC, botao_fechar ;Se o botão de fechar for pressionado
	;rjmp botao_fechar_pressed ; Pula para a rotina botao_fechar_pressed

	rjmp maquina_estados

	botao_interno_terreo_pressed:
		rcall debounce ;Aguarda 20ms
		ldi andarPressionado, botao_interno_terreo ;Define o andar pressionado como 0
		ldi tipoChamado, botaoInterno ;Define o local pressionado como interno
		rjmp maquina_estados

	botao_interno_andar1_pressed:
		rcall debounce ;Aguarda 20ms
		ldi andarPressionado, botao_interno_andar1 ;Define o andar pressionado como 1
		ldi tipoChamado, botaoInterno ;Define o local pressionado como interno
		rjmp maquina_estados

	botao_interno_andar2_pressed:
		rcall debounce ;Aguarda 20ms
		ldi andarPressionado, botao_interno_andar2 ;Define o andar pressionado como 2
		ldi tipoChamado, botaoInterno ;Define o local pressionado como interno
		rjmp maquina_estados

	botao_interno_andar3_pressed:
		rcall debounce ;Aguarda 20ms
		ldi andarPressionado, botao_interno_andar3 ;Define o andar pressionado como 3
		ldi tipoChamado, botaoInterno ;Define o local pressionado como interno
		rjmp maquina_estados

	botao_externo_terreo_pressed:
		rcall debounce ;Aguarda 20ms
		ldi andarPressionado, botao_externo_terreo ;Define o andar pressionado como 0
		ldi tipoChamado, botaoExterno ;Define o local pressionado como externo
		rjmp maquina_estados

	botao_externo_andar1_pressed:
		rcall debounce ;Aguarda 20ms
		ldi andarPressionado, botao_externo_andar1 ;Define o andar pressionado como 1
		ldi tipoChamado, botaoExterno ;Define o local pressionado como externo
		rjmp maquina_estados
	
	botao_externo_andar2_pressed:
		rcall debounce ;Aguarda 20ms
		ldi andarPressionado, botao_externo_andar2 ;Define o andar pressionado como 2
		ldi tipoChamado, botaoExterno ;Define o local pressionado como externo
		rjmp maquina_estados
	
	botao_externo_andar3_pressed:
		rcall debounce ;Aguarda 20ms
		ldi andarPressionado, botao_externo_andar3 ;Define o andar pressionado como 3
		ldi tipoChamado, botaoExterno ;Define o local pressionado como externo
		rjmp maquina_estados

	botao_abrir_pressed:
		rcall debounce ;Aguarda 20ms
		ldi state, abrir
		ret

	botao_fechar_pressed:
		rcall debounce ;Aguarda 20ms
		ldi state, parado
		ret	

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
	ldi tipoChamado, naoPressionado
	clr andarPressionado	; Inicia o andarPressionado como 0
	ret

exec_parado:
	clr tempoAguardando    ; O contador de tempoAguardando é zerado
	cbi PORTD, led         ; Desliga o LED
	cbi PORTD, buzzer      ; Desliga o Buzzer

	;cpi filaVazia, 1 ;Verifica se a fila está vazia
	;breq fim_parado ;Se sim, desvia para fim_parado

	sbic PINC, botao_abrir  ; Verifica se o botao de abrir está pressionado
	rjmp abrir_porta_inicio		 ; Se pressionado pula para abrir_porta_inicio

	cpi var_chegou, 1 ;Verifica se chegou no andar
	brne nao_chegou ; Se chegou != 1, desvia para nao_chegou
	ldi state, abrir ;Se chegou == 1, muda o estado para abrir
	rjmp fim_parado

	nao_chegou:

	cpi tipoChamado, naoPressionado  ;Compara o tipoChamado com o valor de naoPressionado (0)
	breq fim_parado                  ;Se tipoChamado == 0, desvia para fim_parado
	ldi state, atualizaFila          ;Se tipoChamado != 0, define o estado como atualizaFila
  rjmp fim_parado

	abrir_porta_inicio:
		call botao_abrir_pressed

	fim_parado:

	clr tempoAguardando		; O contador de tempoAguardando é zerado
	ret

exec_abrir:
	sbi PORTD, led 				; Liga Led 
	ldi var_chegou, 0 			; Define var_chegou como 0

	sbic PINC, botao_fechar	; Verifica se o botao de abrir está pressionado
	rjmp t_fechar_porta        ;
	
	cpi tempoAguardando, 5   ; Compara tempoAguardando com 5
	brne t_final_abrir       ; Se tempoAguardando != 5, desvia para t_final_abrir
	ldi state, buzzerLigado  ; Se TempoAguardando == 5, seta o estado para buzzerLigado
	rjmp t_final_abrir       ; Desvia para t_final_abrir
	
	t_fechar_porta:
		call botao_fechar_pressed
		;ldi state, parado

	t_final_abrir:
	ret

exec_buzzerLigado:
	sbi PORTD, buzzer 		 ; Liga Buzzer 
	
	sbic PINC, botao_abrir  ; Verifica se o botao de abrir está pressionado
	rjmp fim_b_ligado		 ; Se pressionado pula para o fim
	
	sbic PINC, botao_fechar ; Verifica se o botao de fechar está pressionado
	rjmp t_fechar_porta2      ; Se pressionado pula para o fim

	cpi tempoAguardando, 10  ; Compara tempoAguardando com 10
	brge t_fechar_porta2		 ; Se tempoAguardando >= 10, desvia para t_fechar_porta2
	rjmp fim_b_ligado 		 	 ; Se tempoAguardando < 10, desvia para fim_b_ligado

	t_fechar_porta2:
		call botao_fechar_pressed
		;ldi state, parado    ; Vai para o estado de parado
	fim_b_ligado:
	ret

exec_atualizaFila:
	//TODO: Implementar tudo
	/* Implementacao da Fila */
	;cpi sentido, subindo            ; Verifica se o sentido é subindo
	;brne fila_descendo 			    ; Se sentido não for subindo desvia para fila_descendo
	; Operações para fila subindo
	;subi andarAtual, -1   		  	; Se sentido for subindo soma 1 ao andarAtual
	;rjmp t_ok_calc        		  	; Se o andarAtual já foi alterado pula para t_ok_calc

	;fila_descendo: 
		; Operações para fila descendo
		;subi andarAtual, 1          ; Se sentido não for subindo subtrai 1 do andarAtual 

	;; Precisa dar clear no tipoChamado
	clr tipoChamado
	//Decisao do Destino 
	clr andarDestino                   ; Zera o andarDestino
	add andarDestino, andarPressionado ;Define o andar destino como o andar pressionado

	cp andarAtual, andarDestino ;Compara andar destino com andar atual
	brlt destino_maior ;Desvia para destino_maior se andarAtual < andarDestino
	cp andarAtual, andarDestino ;Compara andar destino com andar atual
	breq destino_igual ;Desvia para destino_igual se andarAtual = andarDestino
	
	
	destino_menor:
		ldi state, movendoBaixo ;Define o estado como movendoBaixo
		rjmp desvio_final       ;O elevador precisa descer, então desvia para o final

	destino_maior:
		ldi state, movendoCima  ;Define o estado como movendoCima
		rjmp desvio_final       ;O elevador precisa subir, então desvia para o final

	destino_igual:
		ldi state, parado       ;Define o estado como parado

	desvio_final:
	ret


exec_movendoCima:
	ldi var_chegou, 0      ;Define var_chegou como 0
	ldi sentido, 1         ;Define sentido como 1 (Subindo)
	
	//TODO: Fazer as transições
	cpi tipoChamado, naoPressionado ; Compara tipoChamado com 0
	brne movendo_cima_chamada						; Se tipoChamado != 0, pula para movendo_cima_chamada

	cpi tempoAguardando, 3 ; Compara tempoAguardando com 3
	brlt nao_subiu         ; Se tempoAguardando < 3 desvia para nao_subiu
	ldi state, trocaAndar  ; Se tempoAguardando >= 3 define o estado como trocaAndar
	rjmp nao_subiu

	movendo_cima_chamada:
		ldi state, atualizaFila

	nao_subiu:
	
	ret

exec_movendoBaixo:
	ldi var_chegou, 0      ;Define var_chegou como 0
	ldi sentido, 0         ;Define sentido como 0 (Descendo)
	//TODO: Fazer as transições
	cpi tipoChamado, naoPressionado ; Compara tipoChamado com 0
	brne movendo_baixo_chamada						; Se tipoChamado != 0, pula para movendo_baixo_chamada

	cpi tempoAguardando, 3 ; Compara tempoAguardando com 3
	brlt nao_desceu        ; Se tempoAguardando < 3 desvia para nao_subiu
	ldi state, trocaAndar  ; Se tempoAguardando >= 3 define o estado como trocaAndar
	rjmp nao_desceu
	
	movendo_baixo_chamada:
		ldi state, atualizaFila

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
		call muda_display_andar  ; Atualiza o display do andar
	ret

exec_chegou:
	ldi var_chegou, 1 			;Define var_chegou como 1
	ldi state, atualizaFila ;Define o estado como atualizaFila

	ret

muda_display_andar:
	cpi andarAtual, 0       ; Compara andarAtual com 0
	brne next1              ; Se andarAtual != 0 desvia para next1
	rcall set_display_zero  ; Se andarAtual == 0 chama a rotina set_display_zero, que define o 'temp' como 0

	next1:
	cpi andarAtual, 1       ; Compara andarAtual com 1
	brne next2							; Se andarAtual != 1 desvia para next2
	rcall set_display_um    ; Se andarAtual == 1 chama a rotina set_display_um, que define o 'temp' como 1

	next2:
	cpi andarAtual, 2       ; Compara andarAtual com 2
	brne next3              ; Se andarAtual != 2 desvia para next3
	rcall set_display_dois  ; Se andarAtual == 2 chama a rotina set_display_dois, que define o 'temp' como 2

	next3:
	cpi andarAtual, 3 			; Compara andarAtual com 3
	brne continue           ; Se andarAtual != 3 desvia para continue
	rcall set_display_tres  ; Se andarAtual == 3 chama a rotina set_display_tres, que define o 'temp' como 3

	continue: 

	out PORTD, temp         ; Define o PORTD com o valor de 'temp', que é o valor que será mostrado no display
	ret


set_display_zero:
	ldi temp, display_zero  ; Define 'temp' como 0
	ret

set_display_um:
	ldi temp, display_um    ; Define 'temp' como 1
	ret

set_display_dois:
	ldi temp, display_dois  ; Define 'temp' como 2
	ret

set_display_tres:
	ldi temp, display_tres  ; Define 'temp' como 3
	ret
