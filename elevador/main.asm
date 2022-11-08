setup:
	.def temp = r16 ;Define o nome 'temp' para o registrador r16
	ldi temp, 0b00011000 ;Carrega em temp 00011000
	out DDRB, temp ;Configura PORTB4 e PORTB3 como saída. Usadas pelo Led e Buzzer

	ldi temp, 0b00111100 ;Carrega em temp 00111100
	out DDRD, temp ;Configura PORTD5, PORTD4, PORTD3 e PORTD2 como saída. Usadas pelo CI

	ldi temp, 0b00000000 ;Carrega em temp 00000000
	out DDRC, temp ;Na porta C terá apenas botões


	ldi temp, 0b00100111;Carrega 00100111 em temp
	out PORTB, temp ;inicializa as portas PB4 (Buzzer) e PB3 (Led) em LOW, e habilita pull-up em PB5, PB2, PB1 e PB0

	ldi temp, 0b00111111 ;Carrega 00111111 em temp
	out PORTC, temp ;Habilita pull-up em PC5, PC4, PC3, PC2, PC1 e PC0
	
	;         0b00DCBA00
	ldi temp, 0b00000000 ;Carrega 00000000 em temp
	out PORTD, temp ;inicializa as portas PD5, PD4, PD3 e PD2 (CI) em LOW, mostrando um 0 no display de 7 segmentos


loop:
	sbic PINC, PC1 ;botão solto? ;sbic = skip if bit in I/O register cleared
	rjmp led_on ;Não, desvia para ligar LED
	cbi PORTB, PB3 ;Sim ,desliga LED ;cbi = clear bit in I/O register
	rjmp loop ;Volta ao começo do loop

led_on:
	sbi PORTB, PB3 ;Liga LED ;sbi set bit in I/O register
	rjmp loop
