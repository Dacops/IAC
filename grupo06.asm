; ***********************************************************************
; * Projeto Intermédio IAC 2021/22										*
; * Grupo 06															*
; * Elementos:															*
; * 	-> David Pires, nº 103458										*
; *		-> Diogo Miranda, nº 102536										*
; *		-> Mafalda Fernandes, nº 102702									*
; *																		*
; * Modulo:		grupo06.asm												*
; * Descrição: 	Código assembly relativo ao Projeto Intermédio de IAC 	*
; *				2021/22, pronto a ser carregado no simulador.			*
; ***********************************************************************


; ***********************************************************************
; * Endereços de Periféricos											*
; ***********************************************************************
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)


; ***********************************************************************
; * Código																*
; ***********************************************************************
PLACE      0100H

SP_inicial:				
	PLACE	0			; o código tem de começar em 0000H
inicio:
	MOV  SP, SP_inicial		; inicialização de SP

; corpo principal do programa
ciclo:
	CALL teclado
	JMP ciclo

; obtém tecla premida
teclado:
	; constantes
	LINHA      EQU 8		; linha a testar (4ª linha, 1000b)
	MASCARA    EQU 0FH		; para isolar os 4 bits de menor peso

	; inicializações
	MOV 	R1, LINHA		; linha inicial (4ª linha = 1000b)
	MOV		R2, 0			; output do teclado (colunas)
    MOV		R3, TEC_LIN   	; endereço do periférico das linhas
    MOV  	R4, TEC_COL   	; endereço do periférico das colunas
    MOV  	R5, DISPLAYS  	; endereço do periférico dos displays
    MOV  	R6, MASCARA   	; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  	R7, 4         	; número de linhas

	; lê as 4 linhas do teclado
	le_linhas:
		MOVB	[R3], R1	; escrever no periférico de saída (linhas)
		MOVB	R2, [R4]    ; ler do periférico de entrada (colunas)
		AND 	R2, R6      ; elimina bits para além dos bits 0-3
		CMP  	R2, 0       ; há tecla premida?
		JNZ		log_lin		; transfoma coluna/linha em m/n em vez de 2^m/n
		CMP		R1, 0		; já chegou à linha 0?
		JZ		return		; volta ao loop inicial
		SHR		R1, 1		; se nenhuma tecla premida, repete (muda de linha)
		JMP		le_linhas	; verifica próxima linha
		
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
		
	; transforma input do periférico em valor hexadecimal
	cria_hex:
		MUL 	R1, R7		; fórmula para obter valor hexadecimal a partir do output
		ADD 	R1, R2		; dos periféricos: coluna + linha * 4
		MOV		R0, R1		; output da rotina em R0
	
	; volta ao loop inicial
	return:
		RET