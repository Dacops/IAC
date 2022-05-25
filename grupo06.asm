; ***********************************************************************
; * Projeto Intermédio IAC 2021/22										*
; * Grupo 06															*
; * Elementos:															*
; * 	-> David Pires, nº 103458										*
; *	-> Diogo Miranda, nº 102536											*
; *	-> Mafalda Fernandes, nº 102702										*
; *																		*
; * Modulo:	grupo06.asm													*
; * Descrição: 	Código assembly relativo ao Projeto Intermédio de IAC 	*
; *		2021/22, pronto a ser carregado no simulador.					*
; ***********************************************************************


; ***********************************************************************
; * Endereços de Periféricos e Constantes								*
; ***********************************************************************
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)

LINHA      EQU 8		; linha a testar (4ª linha, 1000b)
MASCARA1   EQU 00FH		; para isolar os 4 bits de menor peso
MASCARA2   EQU 0F0H		; para isolar os 4 bits de maior peso


; ***********************************************************************
; * Código																*
; ***********************************************************************

; inicializações
PLACE	1000H				; este é o endereço (1000H) com que o SP deve ser inicializado
							; O 1.º end. de retorno será armazenado em 0FFEH (1000H-2)
SP_inicial:					;
PLACE	0					; o código tem de começar em 0000H
MOV  	SP, SP_inicial		; inicialização de SP
MOV  	R1, DISPLAYS  		; endereço do periférico dos displays
MOV		R11, 0				; inicialização do display
MOV 	[R1], R11      		; inicializa display a 0

; corpo principal do programa
ciclo:
	MOV		R0, 5			; coloca sempre a tecla premida com um valor default
	CALL 	teclado
	CMP		R0, 5			; tecla não foi premida
	JZ		ciclo			; 
	CALL 	display
	JMP 	ciclo
	
; rotina return, volta ao corpo principal do programa
return:
	RET
	

; ***********************************************************************
; * Descrição:			Obtém tecla premida								*
; * Argumentos:			R1 - Argumento dado ao teclado					*
; * 					R2 - Argumento recebido do teclado				*
; * Saídas:				R0 - Tecla premida em hexadecimal				*
; * Registos Usados:	R0, R1, R2, R3, R4, R5, R6, R7					*
; ***********************************************************************
teclado:
	; inicializações
	MOV 	R1, LINHA		; linha inicial (4ª linha = 1000b)
	MOV		R2, 0			; output do teclado (colunas)
    MOV		R3, TEC_LIN   	; endereço do periférico das linhas
    MOV  	R4, TEC_COL   	; endereço do periférico das colunas
   	MOV  	R5, MASCARA1   	; para isolar os 4 bits de menor peso
	MOV  	R6, 4         	; número de linhas

	; lê as 4 linhas do teclado
	le_linhas:
		MOVB	[R3], R1	; escrever no periférico de saída (linhas)
		MOVB	R2, [R4]	; ler do periférico de entrada (colunas)
		AND 	R2, R5 		; elimina bits para além dos bits 0-3
		CMP  	R2, 0		; há tecla premida?
		JNZ		log_lin		; transfoma coluna/linha em m/n em vez de 2^m/n
		CMP		R1, 0		; já chegou à linha 0?
		JZ		return		; volta ao loop inicial
		SHR		R1, 1		; se nenhuma tecla premida, repete (muda de linha)
		JMP		le_linhas	; verifica próxima linha
		
	; transfoma linha em n em vez de 2^n
	log_lin:
		MOV 	R7, R1		; guarda linha atual
		SHR 	R1, 1		; funciona no caso de n = {0,1,2}
		CMP 	R1, 4		; caso particular, n = 4, deveria ser 3
		JNZ		log_col		;
		SUB		R1, 1		; subtrai 1 a 4 para obter 3
	
	; transfoma coluna em m em vez de 2^m
	log_col:
		SHR 	R2, 1		; funciona no caso de m = {0,1,2}
		CMP 	R2, 4		; caso particular, m = 4, deveria ser 3
		JNZ		cria_hex	;
		SUB		R2, 1		; subtrai 1 a 4 para obter 3
		
	; transforma input do periférico em valor hexadecimal
	cria_hex:
		MUL 	R1, R6		; fórmula para obter valor hexadecimal a partir do output
		ADD 	R1, R2		; dos periféricos: coluna + linha * 4
		MOV		R0, R1		; output da rotina em R0
	
	; espera até que a tecla deixe de ser premida
	premida:
		MOV		R6, R7		; linha onde tecla foi premida
		MOVB 	[R3], R6    ; escrever no periférico de saída (linhas)
		MOVB 	R2, [R4]    ; ler do periférico de entrada (colunas)
		AND  	R2, R5      ; elimina bits para além dos bits 0-3
		CMP  	R2, 0       ; há tecla premida?
		JNZ  	premida   	; se ainda houver uma tecla premida, espera até não haver
		JMP		return
		
		
; ***********************************************************************
; * Descrição:			Incrementa/decrementa o display (Teclas 3/7)	*
; * Argumentos:			R0 - Tecla premida (em hexadecimal)				*
; *						R11 - Valor atual no display					*
; * Saídas:				R11 - Novo valor no display						*			
; * Registos Usados:	R0, R1, R5, R6, R9, R10, R11					*
; ***********************************************************************
display:
	; inicializações
	MOV  	R1, DISPLAYS  		; endereço do periférico dos displays
	MOV  	R5, MASCARA1   		; para isolar os 4 bits de menor peso
	MOV  	R6, MASCARA2   		; para isolar os 4 bits de maior peso
	
	CMP 	R0, 3				; verifica se a tecla '3' foi premida
    JZ 		incrementa_valor	; incrementa o valor no display
    CMP 	R0, 7				; verifica se a tecla '7' foi premida
    JZ 		decrementa_valor	; decrementa o valor no display
	JMP		return				; impede que o programa continue 
	
	
	; incrementa o valor no display
	incrementa_valor:
		; verifica antes se se trata de um caso particular
		; limite máximo (=100)
		MOV 	R10, 0100H		; inicia R10 a 100
		CMP 	R11, R10		; R11 é igual a 100?
		JZ 		escreve_display 
		
		; R11 = 99
		MOV		R10, 0099H		; inicia R10 a 99
		CMP		R11, R10		; R11 é igual a R10?
		JZ		inc99		
		JNZ		inc00
		
		; R11 é igual a 99
		inc99:
			MOV		R11, 0100H		; R11 passa a 100
			JMP 	escreve_display 
		
		; R11 acaba em 9 (passaria para xxA em hexadecimal)
		inc00:
			MOV 	R10, 0009H		; inicia R10 a 9
			MOV		R9, R11			; copia o registo R11
			AND		R9, R5			; elimina bits para além dos bits 0-3
			CMP		R10, R9			; R11 acaba em 9?
			JZ		inc_par			
			JNZ		inc_com
		
		; procedimento particular
		inc_par:
			MOV		R10, 0010H		; inicia R10 a 10
			AND		R11, R6			; elimina bits para além dos bits 4-8
			ADD		R11, R10
			JMP 	escreve_display
		
		; procedimento comum
		inc_com:
			ADD		R11, 1			; incrementa R11, o valor do display
			JMP 	escreve_display
		
		
	; decrementa o valor no display
	decrementa_valor:
		; verifica antes se se trata de um caso particular
		; limite mínimo (=0)
		MOV 	R10, 0000H		; inicia R10 a 0
		CMP 	R11, R10		; R11 é igual a 0?
		JZ 		escreve_display 
		
		; R11 = 100
		MOV		R10, 0100H		; inicia R10 a 100
		CMP		R11, R10		; R11 é igual a R10?
		JZ		dec99		
		JNZ		dec00
		
		; R11 é igual a 100
		dec99:
			MOV		R11, 0099H		; R11 passa a 99
			JMP 	escreve_display 
		
		; R11 acaba em 0 (passaria para xxF em hexadecimal)
		dec00:
			MOV 	R10, 0000H		; inicia R10 a 0
			MOV		R9, R11			; copia o registo R11
			AND		R9, R5			; elimina bits para além dos bits 0-3
			CMP		R10, R9			; R11 acaba em 0?
			JZ		dec_par			
			JNZ		dec_com
		
		; procedimento particular
		dec_par:
			MOV		R10, 0007H		; inicia R10 a 7
			AND		R11, R6			; elimina bits para além dos bits 4-8
			SUB		R11, R10		; x0 - 7 = (x-1)9 (em hexadecimal)
			JMP 	escreve_display
		
		; procedimento comum
		dec_com:
			SUB		R11, 1			; decrementa R11, o valor do display
			JMP 	escreve_display
	
	
	; escreve valor no display
	escreve_display:
		MOV 	[R1], R11      	; muda valor no display
		JMP		return
