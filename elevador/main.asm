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

	.def state = r17 ;Define o nome 'state' para o registrador r17
	ldi state, inicio ;Define o estado para 'inicio'
	.def andarAtual = r18 ;Define o nome 'andarAtual' para o registrador r18
	ldi andarAtual, terreo ;Define o andar atual para 0
	.def andarDestino = r20 ;Define o nome 'andarDestino' para o registrador r20
	.def andarPressionado = r21 ;Define o nome 'andarPressionado' para o registrador r21
	.def localPressionado = r22 ;Define o nome 'localPressionado' para o registrador r22, 0 para interno e 1 para externo

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

	;sbic PINC, botao_abrir ;Se o botão de abrir for pressionado
	;rjmp button_pressed_open

	;sbic PINC, botao_fechar ;Se o botão de fechar for pressionado
	;rjmp button_pressed_close

	rjmp maquina_estados

	botao_interno_terreo_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_interno_terreo ;Define o andar pressionado como 0
		ldi localPressionado, botaoInterno ;Define o local pressionado como interno
		ldi state, atualizaFila ; Define o estado para 'atualizaFila'
		rjmp maquina_estados

	botao_interno_andar1_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_interno_andar1 ;Define o andar pressionado como 1
		ldi localPressionado, botaoInterno ;Define o local pressionado como interno
		ldi state, atualizaFila ; Define o estado para 'atualizaFila'
		rjmp maquina_estados

	botao_interno_andar2_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_interno_andar2 ;Define o andar pressionado como 2
		ldi localPressionado, botaoInterno ;Define o local pressionado como interno
		ldi state, atualizaFila ; Define o estado para 'atualizaFila'
		rjmp maquina_estados

	botao_interno_andar3_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_interno_andar3 ;Define o andar pressionado como 3
		ldi localPressionado, botaoInterno ;Define o local pressionado como interno
		ldi state, atualizaFila ; Define o estado para 'atualizaFila'
		rjmp maquina_estados

	botao_externo_terreo_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_externo_terreo ;Define o andar pressionado como 0
		ldi localPressionado, botaoExterno ;Define o local pressionado como externo
		ldi state, atualizaFila ; Define o estado para 'atualizaFila'
		rjmp maquina_estados

	botao_externo_andar1_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_externo_andar1 ;Define o andar pressionado como 1
		ldi localPressionado, botaoExterno ;Define o local pressionado como externo
		ldi state, atualizaFila ; Define o estado para 'atualizaFila'
		rjmp maquina_estados
	
	botao_externo_andar2_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_externo_andar2 ;Define o andar pressionado como 2
		ldi localPressionado, botaoExterno ;Define o local pressionado como externo
		ldi state, atualizaFila ; Define o estado para 'atualizaFila'
		rjmp maquina_estados
	
	botao_externo_andar3_pressed:
		rcall delay20ms ;Aguarda 20ms
		ldi andarPressionado, botao_externo_andar3 ;Define o andar pressionado como 3
		ldi localPressionado, botaoExterno ;Define o local pressionado como externo
		ldi state, atualizaFila ; Define o estado para 'atualizaFila'
		rjmp maquina_estados

	;button_pressed_open:
	;	rcall delay20ms ;Aguarda 20ms
	;	ldi state, abrir

	;button_pressed_close:
	;	rcall delay20ms ;Aguarda 20ms
	;	ldi state, parado
		

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
	ldi state, parado
	jmp loop
case_parado:
	
	jmp loop
case_abrir:
	
	jmp loop
case_buzzerLigado:

	jmp loop
case_atualizaFila:
	rjmp led_on 
	jmp loop
case_movendoCima:

	jmp loop
case_movendoBaixo:

	jmp loop
case_trocaAndar:

	jmp loop
case_chegou:

	jmp loop

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
	;sbi PORTD, buzzer ;Liga LED ;sbi set bit in I/O register
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
