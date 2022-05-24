; ***********************************************************************
; * Projeto Interm�dio IAC 2021/22										*
; * Grupo 06															*
; * Elementos:															*
; * 	-> David Pires, n� 103458										*
; *		-> Diogo Miranda, n� 102536										*
; *		-> Mafalda Fernandes, n� 102702									*
; *																		*
; * Modulo:		grupo06.asm												*
; * Descri��o: 	C�digo assembly relativo ao Projeto Interm�dio de IAC 	*
; *				2021/22, pronto a ser carregado no simulador.			*
; ***********************************************************************


; ***********************************************************************
; * Endere�os de Perif�ricos											*
; ***********************************************************************
DISPLAYS   EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)


; ***********************************************************************
; * C�digo																*
; ***********************************************************************
PLACE      0100H

SP_inicial:				
	PLACE	0			; o c�digo tem de come�ar em 0000H
inicio:
	MOV  SP, SP_inicial		; inicializa��o de SP

; corpo principal do programa
ciclo:
	CALL teclado
	JMP ciclo

; obt�m tecla premida
teclado:
	; constantes
	LINHA      EQU 8		; linha a testar (4� linha, 1000b)
	MASCARA    EQU 0FH		; para isolar os 4 bits de menor peso

	; inicializa��es
	MOV 	R1, LINHA		; linha inicial (4� linha = 1000b)
	MOV		R2, 0			; output do teclado (colunas)
    MOV		R3, TEC_LIN   	; endere�o do perif�rico das linhas
    MOV  	R4, TEC_COL   	; endere�o do perif�rico das colunas
    MOV  	R5, DISPLAYS  	; endere�o do perif�rico dos displays
    MOV  	R6, MASCARA   	; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  	R7, 4         	; n�mero de linhas

	; l� as 4 linhas do teclado
	le_linhas:
		MOVB	[R3], R1	; escrever no perif�rico de sa�da (linhas)
		MOVB	R2, [R4]    ; ler do perif�rico de entrada (colunas)
		AND 	R2, R6      ; elimina bits para al�m dos bits 0-3
		CMP  	R2, 0       ; h� tecla premida?
		JNZ		log_lin		; transfoma coluna/linha em m/n em vez de 2^m/n
		CMP		R1, 0		; j� chegou � linha 0?
		JZ		return		; volta ao loop inicial
		SHR		R1, 1		; se nenhuma tecla premida, repete (muda de linha)
		JMP		le_linhas	; verifica pr�xima linha
		
	; transfoma linha em n em vez de 2^n
	log_lin:
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
		
	; transforma input do perif�rico em valor hexadecimal
	cria_hex:
		MUL 	R1, R7		; f�rmula para obter valor hexadecimal a partir do output
		ADD 	R1, R2		; dos perif�ricos: coluna + linha * 4
		MOV		R0, R1		; output da rotina em R0
	
	; volta ao loop inicial
	return:
		RET