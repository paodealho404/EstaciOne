.cseg 
jmp setup
.org OC1Aaddr
jmp timer_1_sec_interrupt

setup:
	.def temp = r16 ;Define o nome 'temp' para o registrador r16
	ldi temp, 0b00000000 ;Carrega em temp 00000000
	out DDRB, temp ; Configura a porta B como entrada (botões)

	ldi temp, 0b11111100 ;Carrega em temp 11111100
	out DDRD, temp ;Configura PORTD7 e PORTD6 como saída usadas pelo led e buzzer. 
	;Configura PORTD5, PORTD4, PORTD3 e PORTD2 como saída usadas pelo CI

	ldi temp, 0b00000000 ;Carrega em temp 00000000
	out DDRC, temp ; Configura a porta C como entrada (botões)

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

	; Fila: 0bTeTi1e1i2e2i3e3i
	.equ filaTerreoExterno   = 7
	.equ filaTerreoInterno   = 6
	.equ filaPrimeiroExterno = 5
	.equ filaPrimeiroInterno = 4
	.equ filaSegundoExterno  = 3
	.equ filaSegundoInterno  = 2
	.equ filaTerceiroExterno = 1
	.equ filaTerceiroInterno = 0

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
	.equ subindo  = 0b0001

	.def state = r17 ;Define o nome 'state' para o registrador r17
	ldi state, inicio ;Define o estado para 'inicio'

	.def andarAtual = r18 ;Define o nome 'andarAtual' para o registrador r18
	ldi andarAtual, terreo ;Define o andar atual para 0

	.def andarDestino = r19 ;Define o nome 'andarDestino' para o registrador r19
	.def tipoChamado = r20 ;Define o nome 'tipoChamado' para o registrador r20, 1 para interno e 2 para externo
	.def tempoAguardando = r21 ;Define o nome 'tempoAguardando' para o registrador r21
	.def sentido = r22 ;Define o nome 'sentido' para o registrador r22, 1 para cima e 0 para baixo
	.def estaParado = r23 ;Define o nome 'estaParado' para o registrador r23
	.def var_chegou = r24 ;Define o nome 'var_chegou' para o registrador r24, 1 para chegou e 0 para não 
	.def regFila = r25 ;Define o nome 'regFila' para o registrador r25 (regFila = 0bTeTi1e1i2e2i3e3i)

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
	
	cpi state, parado				;Compara o estado com o estado parado
	breq timer_1_sec_interrupt_end  ;Se state == parado, não incrementa o tempoAguardando e pula para o final da interrupção
	inc tempoAguardando             ;Se state != parado, incrementa o tempoAguardando
	 

	timer_1_sec_interrupt_end:	
		pop r16
		out SREG, r16
		pop r16
	
	sei ; Seta a flag global de interrupção
	reti ; Retorna da interrupção

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
	sei ; Seta a flag global de interrupções
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

	rjmp maquina_estados ; Pula para 'maquina de estados'

	botao_interno_terreo_pressed:
		rcall debounce ;Aguarda 20ms
		ldi tipoChamado, botaoInterno ;Define o local pressionado como interno
		sbr regFila, 1 << filaTerreoInterno ; Seta o bit relacionado a filaTerreoInterno (6), como 1 (regFila = 0bx1xxxxxx)
		rjmp maquina_estados

	botao_interno_andar1_pressed:
		rcall debounce ;Aguarda 20ms
		ldi tipoChamado, botaoInterno ;Define o local pressionado como interno
		sbr regFila, 1 << filaPrimeiroInterno ; Seta o bit relacionado a filaPrimeiroInterno (4) como 1 (regFila = 0bxxx1xxxx)
		rjmp maquina_estados

	botao_interno_andar2_pressed:
		rcall debounce ;Aguarda 20ms
		ldi tipoChamado, botaoInterno ;Define o local pressionado como interno
		sbr regFila, 1 << filaSegundoInterno ; Seta o bit relacionado a filaSegundoInterno (2) como 1 (regFila = 0bxxxxx1xx)
		rjmp maquina_estados

	botao_interno_andar3_pressed:
		rcall debounce ;Aguarda 20ms
		ldi tipoChamado, botaoInterno ;Define o local pressionado como interno
		sbr regFila, 1 << filaTerceiroInterno ; Seta o bit relacionado a filaTerceiroInterno (0) como 1 (regFila = 0bxxxxxxx1)
		rjmp maquina_estados

	botao_externo_terreo_pressed:
		rcall debounce ;Aguarda 20ms
		ldi tipoChamado, botaoExterno ;Define o local pressionado como externo
		sbr regFila, 1 << filaTerreoExterno ; Seta o bit relacionado a filaTerreoExterno (7) como 1 (regFila = 0b1xxxxxxx)
		rjmp maquina_estados

	botao_externo_andar1_pressed:
		rcall debounce ;Aguarda 20ms
		ldi tipoChamado, botaoExterno ;Define o local pressionado como externo
		sbr regFila, 1 << filaPrimeiroExterno ; Seta o bit relacionado a filaPrimeiroExterno (5) como 1 (regFila = 0bxx1xxxxx)
		rjmp maquina_estados
	
	botao_externo_andar2_pressed:
		rcall debounce ;Aguarda 20ms
		ldi tipoChamado, botaoExterno ;Define o local pressionado como externo
		sbr regFila, 1 << filaSegundoExterno ; Seta o bit relacionado a filaSegundoExterno (3) como 1 (regFila = 0bxxxxx1xx)
		rjmp maquina_estados
	
	botao_externo_andar3_pressed0,,,,,,,,,,,,,,,,,,:
		rcall debounce ;Aguarda 20ms
		ldi tipoChamado, botaoExterno ;Define o local pressionado como externo
		sbr regFila, 1 << filaTerceiroExterno ; Seta o bit relacionado a filaTerceiroExterno (1) como 1 (regFila = 0bxxxxxx1x)
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
	ldi tipoChamado, naoPressionado ; tipoChamado = naoPressionado
	clr regFila             ; Inicia a fila vazia
	ret

exec_parado:
	ldi estaParado, 1      ; estaParado = 1
	clr tempoAguardando    ; O contador de tempoAguardando é zerado
	cbi PORTD, led         ; Desliga o LED
	cbi PORTD, buzzer      ; Desliga o Buzzer

	sbic PINC, botao_abrir  ; Verifica se o botao de abrir está pressionado
	rjmp abrir_porta_inicio		 ; Se pressionado pula para abrir_porta_inicio

	cpi var_chegou, 1 ;Verifica se chegou no andar
	brne nao_chegou ; Se chegou != 1, desvia para nao_chegou
	ldi state, abrir ;Se chegou == 1, muda o estado para abrir
	rjmp fim_parado

	nao_chegou:

	cpi regFila, 0  				 ;Verifica se a fila esta vazia
	breq fim_parado                  ;Se fila == 0, está vazia, desvia para fim_parado
	ldi state, atualizaFila          ;Se fila != 0, state = atualizaFila Se tipoChamado != 0, define o estado como atualizaFila
	rjmp fim_parado                  ;Após setar o state vai para o final

	abrir_porta_inicio:						
		call botao_abrir_pressed  ; chama a função de abrir a porta se o botão abrir for pressionado

	fim_parado:

	clr tempoAguardando		; O contador de tempoAguardando é zerado
	ret

exec_abrir:
	sbi PORTD, led 				; Liga Led 
	ldi var_chegou, 0 			; Define var_chegou como 0

	sbic PINC, botao_fechar	; Verifica se o botao de fechar está pressionado
	rjmp t_fechar_porta     ; Se sim, pula para t_fechar_porta
	
	cpi tempoAguardando, 5   ; Compara tempoAguardando com 5
	brlt t_final_abrir       ; Se tempoAguardando < 5, desvia para t_final_abrir
	ldi state, buzzerLigado  ; Se TempoAguardando >= 5, seta o estado para buzzerLigado
	rjmp t_final_abrir       ; Desvia para t_final_abrir
	
	t_fechar_porta:
		call botao_fechar_pressed ;chama a função de fechar a porta se o botão fechar for pressionado

	t_final_abrir:
	ret

exec_buzzerLigado:
	sbi PORTD, buzzer 		 ; Liga Buzzer 
	
	sbic PINC, botao_abrir  ; Verifica se o botao de abrir está pressionado
	rjmp fim_b_ligado		 ; Se pressionado pula para o fim
	
	sbic PINC, botao_fechar ; Verifica se o botao de fechar está pressionado
	rjmp t_fechar_porta2      ; pula para t_fechar_porta2

	cpi tempoAguardando, 10  ; Compara tempoAguardando com 10
	brge t_acabou_tempo		 ; Se tempoAguardando >= 10, desvia para t_acabou_tempo
	rjmp fim_b_ligado 		 	 ; Se tempoAguardando < 10, desvia para fim_b_ligado

	t_fechar_porta2:
		call botao_fechar_pressed ;chama a função de fechar a porta se o botão fechar for pressionado
	t_acabou_tempo:
		ldi state, parado    ; Vai para o estado de parado
	fim_b_ligado:
	ret

exec_atualizaFila:
	cpi estaParado, 1 ; Verifica se o elevador está parado
	breq atualiza_fila_parado ;Se estaParado == 1, desvia para atualiza_fila_parado
	rjmp atualiza_fila_nao_parado ;Se estaParado != 1, desvia para atualiza_fila_nao_parado
	atualiza_fila_parado:
		; Operações para fila parado
		testa_terreo_parado:
			cpi andarAtual, terreo  ; Verifica andarAtual com terreo (0)
			brne testa_primeiro_parado ; Se andarAtual != 0, pula para testa_primeiro_parado
			atual_terreo_parado:       ; Se andarAtual == 0, executa atual_terreo_parado
			; se andarAtual = terreo
				sbrc regFila, filaTerceiroExterno ; Verifica o bit 1 (filaTerceiroExterno), se regFila[1] == 0, pula a próxima instrução
				ldi andarDestino, terceiro ; Se regFila[1] == 1, terceiro andar é o novo destino
				sbrc regFila, filaSegundoExterno ; Verifica o bit 3 (filaSegundoExterno), se regFila[3] == 0, pula a próxima instrução
				ldi andarDestino, segundo ; Se regFila[3] == 1, segunda andar é o novo destino
				sbrc regFila, filaPrimeiroExterno ; Verifica o bit 5 (filaPrimeiroExterno), se regFila[5] == 0, pula a próxima instrução
				ldi andarDestino, primeiro ; Se regFila[5] == 1, primeiro andar é o novo destino
				sbrc regFila, filaTerreoExterno ; erifica o bit 7 (filaTerreoExterno), se regFila[7] == 0, pula a próxima instrução
				ldi andarDestino, terreo ; Se regFila[5] == 1, terreo é o novo destino

				sbrc regFila, filaTerceiroInterno ; Verifica o bit 0 (filaTerceiroInterno), se regFila[0] == 0, pula a próxima instrução
				ldi andarDestino, terceiro ; Se regFila[0] == 1, terceiro andar é o novo destino
				sbrc regFila, filaSegundoInterno ; Verifica o bit 2 (filaSegundoInterno), se regFila[2] == 0, pula a próxima instrução
				ldi andarDestino, segundo ; Se regFila[2] == 1, segunda andar é o novo destino
				sbrc regFila, filaPrimeiroInterno ; Verifica o bit 4 (filaPrimeiroInterno), se regFila[4] == 0, pula a próxima instrução
				ldi andarDestino, primeiro ; Se regFila[4] == 1, primeiro andar é o novo destino
				sbrc regFila, filaTerreoInterno ; Verifica o bit 6 (filaPrimeiroInterno), se regFila[6] == 0, pula a próxima instrução
				ldi andarDestino, terreo ; Se regFila[6] == 1, terreo é o novo destino

				rjmp verifica_fila ; pula para verifica_fila

		testa_primeiro_parado:
			cpi andarAtual, primeiro ; Verifica andarAtual com primeiro (1)
			brne testa_segundo_parado ; se andarAndarAtual != 1, pula para testa_segundo_parado
			atual_primeiro_parado:    ; Se andarAtual == 1, executa atual_primeiro_parado
			; se andarAtual = 1
				sbrc regFila, filaTerreoExterno ; Verifica se andar terreo externo foi pressionado, se não, pula
				ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino
				sbrc regFila, filaSegundoExterno ; Verifica se segundo andar externo foi pressionado, se não, pula
				ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino
				sbrc regFila, filaTerceiroExterno ; Verifica se terceiro andar externo foi pressionado, se não, pula
				ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino
				sbrc regFila, filaPrimeiroExterno ; Verifica se primeiro andar externo foi pressionado, se não, pula
				ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino

				sbrc regFila, filaTerceiroInterno ; Verifica se terceiro andar interno foi pressionado, se não, pula
				ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino
				sbrc regFila, filaSegundoInterno ; Verifica se segundo andar interno foi pressionado, se não, pula
				ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino
				sbrc regFila, filaTerreoInterno ; Verifica se andar terreo interno foi pressionado, se não, pula
				ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino
				sbrc regFila, filaPrimeiroInterno ; Verifica se primeiro andar interno foi pressionado, se não, pula
				ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino

				rjmp verifica_fila ; pula para verifica_fila

		testa_segundo_parado:
			cpi andarAtual, segundo ; Verifica andarAtual com segundo (2)
			brne atual_terceiro_parado ; Se andarAtual != 2, pula para atual_terceiro_parado
			atual_segundo_parado:      ; Se andarAtual == 2, executa atual_segundo_parado
			; se andarAtual = 2
				sbrc regFila, filaTerreoExterno ; Verifica se andar terreo externo foi pressionado, se não, pula
				ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino
				sbrc regFila, filaTerceiroExterno ; Verifica se terceiro andar externo foi pressionado, se não, pula
				ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino
				sbrc regFila, filaPrimeiroExterno ; Verifica se primeiro andar externo foi pressionado, se não, pula
				ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino
				sbrc regFila, filaSegundoExterno ; Verifica se segundo andar externo foi pressionado, se não, pula
				ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino

				sbrc regFila, filaTerceiroInterno ; Verifica se terceiro andar interno foi pressionado, se não, pula
				ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino
				sbrc regFila, filaPrimeiroInterno ; Verifica se primeiro andar interno foi pressionado, se não, pula
				ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino
				sbrc regFila, filaTerreoInterno ; Verifica se andar terreo interno foi pressionado, se não, pula
				ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino
				sbrc regFila, filaSegundoInterno ; Verifica se segundo andar interno foi pressionado, se não, pula
				ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino

				rjmp verifica_fila ; pula para verifica_fila

		; Se andarAtual == 3, executa atual_terceiro_par
		atual_terceiro_parado:
			sbrc regFila, filaTerreoExterno ; Verifica se andar terreo externo foi pressionado, se não, pula
			ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino
			sbrc regFila, filaPrimeiroExterno ; Verifica se primeiro andar externo foi pressionado, se não, pula
			ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino
			sbrc regFila, filaSegundoExterno ; Verifica se segundo andar externo foi pressionado, se não, pula
			ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino
			sbrc regFila, filaTerceiroExterno ; Verifica se terceiro andar externo foi pressionado, se não, pula
			ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino

			sbrc regFila, filaTerreoInterno ; Verifica se andar terreo interno foi pressionado, se não, pula
			ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino
			sbrc regFila, filaPrimeiroInterno ; Verifica se primeiro andar interno foi pressionado, se não, pula
			ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino
			sbrc regFila, filaSegundoInterno ; Verifica se segundo andar interno foi pressionado, se não, pula
			ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino
			sbrc regFila, filaTerceiroInterno ; Verifica se terceiro andar interno foi pressionado, se não, pula
			ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino

			rjmp verifica_fila ; pula para verifica_fila

	atualiza_fila_nao_parado: ; Caso o elevador esteja em movimento e ocorreu uma nova chamada
		cpi sentido, subindo ; Verifica se o sentido é subindo
		brne atualiza_fila_descendo ; Se sentido != 1 (subindo), pula para atualiza_fila_descendo
		atualiza_fila_subindo:      ; Se sentido == 1 (subindo), executa atualiza_fila_subindo
			; Operações para fila subindo
			testa_terreo_subindo:
			cpi andarAtual, terreo ; Verifica andarAtual com terreo (0)
			brne testa_primeiro_subindo ; Se andarAtual != 0, pula para testa_primeiro_subindo
				atual_terreo_subindo:     ; Se andarAtual == 0, executa atual_terreo_subindo
				; se andarAtual = terreo
					sbrc regFila, filaPrimeiroExterno ; Verifica se primeiro andar externo foi pressionado, se não, pula
					ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino
					sbrc regFila, filaSegundoExterno ; Verifica se segundo andar externo foi pressionado, se não, pula
					ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino
					sbrc regFila, filaTerceiroExterno ; Verifica se terceiro andar externo foi pressionado, se não, pula
					ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino

					sbrc regFila, filaTerceiroInterno ; Verifica se terceiro andar interno foi pressionado, se não, pula
					ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino
					sbrc regFila, filaSegundoInterno ; Verifica se segundo andar interno foi pressionado, se não, pula
					ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino
					sbrc regFila, filaPrimeiroInterno ; Verifica se primeiro andar interno foi pressionado, se não, pula
					ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino

					rjmp verifica_fila ; pula para verifica_fila

			testa_primeiro_subindo:
				cpi andarAtual, primeiro ; Verifica andar atual com primeiro (1)
				brne testa_segundo_subindo ; Se andarAtual != 1, pula para testa_segundo_subindo
				atual_primeiro_subindo:		 ; Se andarAtual == 1, executa atual_primeiro_subindo
				; se andarAtual = 1
					sbrc regFila, filaSegundoExterno ; Verifica se segundo andar externo foi pressionado, se não, pula
					ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino
					sbrc regFila, filaTerceiroExterno ; Verifica se terceiro andar externo foi pressionado, se não, pula
					ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino

					sbrc regFila, filaTerceiroInterno ; Verifica se terceiro andar interno foi pressionado, se não, pula
					ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino
					sbrc regFila, filaSegundoInterno ; Verifica se segundo andar interno foi pressionado, se não, pula
					ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino

					rjmp verifica_fila ; pula para verifica_fila

			testa_segundo_subindo:
				cpi andarAtual, segundo ; Verifica andarAtual cundo (2)o
				brne atual_terceiro_subindo ; Se andarAtual != 2, pula para atual_terceiro 
				atual_segundo_subindo:      ; Se andarAtual == 2, executa atual_segundo_subindo
				; se andarAtual = 2
					sbrc regFila, filaTerceiroExterno ; Verifica se terceiro andar externo foi pressionado, se não, pula
					ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino

					sbrc regFila, filaTerceiroInterno ; Verifica se terceiro andar interno foi pressionado, se não, pula
					ldi andarDestino, terceiro ; Se foi pressionado, terceiro andar é o novo destino

					rjmp verifica_fila ; pula para verifica_fila

			; Se andarAtual == 3
			atual_terceiro_subindo:
				rjmp verifica_fila ; pula para verifica_fila

		atualiza_fila_descendo: 
			; Operações para fila descendo
			testa_terreo_descendo:
				cpi andarAtual, terreo ; Verifica andarAtual com terreo
				brne testa_primeiro_descendo ; Se andarAtual != 0, pula para testa_primeiro_descendo
				atual_terreo_descendo:       ; Se andarAtual == 0, executa atual_terreo_descendo
				; Se andarAtual == terreo
					rjmp verifica_fila ; pula para verifica_fila

			testa_primeiro_descendo:
				cpi andarAtual, primeiro  ; Verifica andarAtual com primeiro (1)
				brne testa_segundo_descendo ; Se andarAtual != 1, pula para testa_segundo_descendo
				atual_primeiro_descendo:    ; Se andarAtual == 1, executa atual_primeiro_descendo
				; se andarAtual = 1
					sbrc regFila, filaTerreoExterno ; Verifica se andar terreo externo foi pressionado, se não, pula
					ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino

					sbrc regFila, filaTerreoInterno ; Verifica se andar terreo interno foi pressionado, se não, pula
					ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino

					rjmp verifica_fila ; pula para verifica_fila

			testa_segundo_descendo:
				cpi andarAtual, segundo
				brne atual_terceiro_descendo
				atual_segundo_descendo:
				; se andarAtual == 2
					sbrc regFila, filaTerreoExterno ; Verifica se andar terreo externo foi pressionado, se não, pula
					ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino

					sbrc regFila, filaTerreoInterno ; Verifica se andar terreo interno foi pressionado, se não, pula
					ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino

					sbrc regFila, filaPrimeiroExterno ; Verifica se primeiro andar externo foi pressionado, se não, pula
					ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino

					sbrc regFila, filaPrimeiroInterno ; Verifica se primeiro andar interno foi pressionado, se não, pula
					ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino

					rjmp verifica_fila ; pula para verifica_fila

			atual_terceiro_descendo:
				; se andarAtual == 3
				sbrc regFila, filaTerreoExterno ; Verifica se andar terreo externo foi pressionado, se não, pula
				ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino

				sbrc regFila, filaTerreoInterno ; Verifica se andar terreo interno foi pressionado, se não, pula
				ldi andarDestino, terreo ; Se foi pressionado, andar terreo é o novo destino

				sbrc regFila, filaPrimeiroExterno ; Verifica se primeiro andar externo foi pressionado, se não, pula
				ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino

				sbrc regFila, filaPrimeiroInterno ; Verifica se primeiro andar interno foi pressionado, se não, pula
				ldi andarDestino, primeiro ; Se foi pressionado, primeiro andar é o novo destino

				sbrc regFila, filaSegundoExterno ; Verifica se segundo andar externo foi pressionado, se não, pula
				ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino

				sbrc regFila, filaSegundoInterno ; Verifica se segundo andar interno foi pressionado, se não, pula
				ldi andarDestino, segundo ; Se foi pressionado, segundo andar é o novo destino

				rjmp verifica_fila ; pula para verifica_fila

	verifica_fila:
		ldi tipoChamado, naoPressionado ; tipoChamado = naoPressionado

	cpi var_chegou, 1
	brne fila_nao_chegou   ; Se var_chegou != 1, pula para fila_nao_chegou
	ldi state, parado
	rjmp desvio_final
	
	fila_nao_chegou:

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
		ldi state, chegou       ;Define o estado como chegou

	desvio_final:
	ret


exec_movendoCima:
	ldi estaParado, 0      ;Define estaParado como 0
	ldi var_chegou, 0      ;Define var_chegou como 0
	ldi sentido, subindo         ;Define sentido como 1 (Subindo)
	
	cpi tipoChamado, naoPressionado ; Compara tipoChamado com 0
	brne movendo_cima_chamada		; Se tipoChamado != 0, pula para movendo_cima_chamada

	cpi tempoAguardando, 3 ; Compara tempoAguardando com 3
	brlt desvio_final_movendo_cima         ; Se tempoAguardando < 3 desvia para desvio_final_movendo_cima
	ldi state, trocaAndar  ; Se tempoAguardando >= 3 define o estado como trocaAndar
	rjmp desvio_final_movendo_cima

	movendo_cima_chamada:
		ldi state, atualizaFila

	desvio_final_movendo_cima:
	
	ret

exec_movendoBaixo:
	ldi estaParado, 0      ;Define estaParado como 0
	ldi var_chegou, 0      ;Define var_chegou como 0
	ldi sentido, descendo         ;Define sentido como Descendo

	cpi tipoChamado, naoPressionado ; Compara tipoChamado com 0
	brne movendo_baixo_chamada						; Se tipoChamado != 0, pula para movendo_baixo_chamada

	cpi tempoAguardando, 3 ; Compara tempoAguardando com 3
	brlt desvio_final_movendo_baixo        ; Se tempoAguardando < 3 desvia para desvio_final_movendo_baixo
	ldi state, trocaAndar  ; Se tempoAguardando >= 3 define o estado como trocaAndar
	rjmp desvio_final_movendo_baixo		   ; 
	
	movendo_baixo_chamada:
		ldi state, atualizaFila

	desvio_final_movendo_baixo:

	ret

exec_trocaAndar:
	clr tempoAguardando  		    ; Zera o tempoAguardando
	
	cpi sentido, subindo 		  ; Verifica se o sentido é subindo
	brne subtrai_andar 			  ; se sentido != 1 desvia para subtrai_andar
	subi andarAtual, -1   		  ; Se sentido == 1 soma 1 ao andarAtual
	rjmp t_decisao_andar          ; Se o andarAtual já foi alterado pula para t_decisao_andar

	subtrai_andar: 
	subi andarAtual, 1          ; Se sentido != 1 subtrai 1 do andarAtual

	t_decisao_andar:
	cp andarAtual, andarDestino ; Compara andarAtual com andarDestino
	brne t_nao_chegou           ; Se andarAtual != andarDestino desvia para t_nao_chegou
	ldi state, chegou           ; Se andarAtual == andarDestino define o estado como chegou
	rjmp t_fim_troca_andar     ; Se o elevador já chegou no andar destino pula para t_fim_troca_andar

	t_nao_chegou:
	cpi sentido, subindo 		; Verifica se o sentido é subindo
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
	testa_terreo_chegou:
		cpi andarDestino, terreo
		brne testa_primeiro_chegou
		cbr regFila, 1 << filaTerreoExterno ; Limpa bit do terreo externo
		cbr regFila, 1 << filaTerreoInterno ; Limpa bit do terreo interno
		rjmp chegou_final
	testa_primeiro_chegou:
		cpi andarDestino, primeiro
		brne testa_segundo_chegou
		cbr regFila, 1 << filaPrimeiroExterno ; Limpa bit do primeiro andar externo
		cbr regFila, 1 << filaPrimeiroInterno ; Limpa bit do primeiro andar interno
		rjmp chegou_final
	testa_segundo_chegou:
		cpi andarDestino, segundo
		brne testa_terceiro_chegou
		cbr regFila, 1 << filaSegundoExterno ; Limpa bit do segundo andar externo
		cbr regFila, 1 << filaSegundoInterno ; Limpa bit do segundo andar interno
		rjmp chegou_final
	testa_terceiro_chegou:
		cpi andarDestino, terceiro
		brne chegou_final
		cbr regFila, 1 << filaTerceiroExterno ; Limpa bit do terceiro andar externo
		cbr regFila, 1 << filaTerceiroInterno ; Limpa bit do terceiro andar interno
	
	chegou_final:
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