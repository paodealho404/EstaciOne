setup:
	.def temp = r16 ;Define o nome 'temp' para o registrador r16
	ldi temp, 0b00000000 ;Carrega em temp 00000000
	out DDRB, temp ;Configura PORTB4 e PORTB3 como saída. Usadas pelo Led e Buzzer

	ldi temp, 0b1111100 ;Carrega em temp 11111100
	out DDRD, temp ;Configura PORTD7 e PORTD6 como saída usadas pelo led e buzzer. 
	;Configura PORTD5, PORTD4, PORTD3 e PORTD2 como saída usadas pelo CI

	ldi temp, 0b00000000 ;Carrega em temp 00000000
	out DDRC, temp ;Na porta C terá apenas botões


	ldi temp, 0b00100111;Carrega 00100111 em temp
	out PORTB, temp ;inicializa as portas PB4 (Buzzer) e PB3 (Led) em LOW, e habilita pull-up em PB5, PB2, PB1 e PB0

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
loop:
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
	rjmp led_on ;Não, desvia para ligar LED
	jmp loop
case_abrir:
	
	jmp loop
case_buzzerLigado:

	jmp loop
case_atualizaFila:

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
	ldi temp, display_dois
	ldi r18, (1 << led)
	or temp, r18
	out PORTD, temp
	;sbi PORTD, led ;Liga LED ;sbi set bit in I/O register
	;sbi PORTD, buzzer ;Liga LED ;sbi set bit in I/O register
	rjmp loop