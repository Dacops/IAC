; *********************************************************************
; * IST-UL
; * Modulo:    lab3.asm
; * Descri��o: Exemplifica o acesso a um teclado.
; *            L� uma linha do teclado, verificando se h� alguma tecla
; *            premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos perif�ricos de 8 bits
; *       atrav�s da instru��o MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATEN��O: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto n�o altera o valor de 16 bits e permite distinguir n�meros de identificadores
DISPLAYS   EQU 0A000H  ; endere�o dos displays de 7 segmentos (perif�rico POUT-1)
TEC_LIN    EQU 0C000H  ; endere�o das linhas do teclado (perif�rico POUT-2)
TEC_COL    EQU 0E000H  ; endere�o das colunas do teclado (perif�rico PIN)
LINHA      EQU 16      ; linha a testar (4� linha, 1000b), 10000b usado pois � shifted inicialmente para 1000b
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; **********************************************************************
; * C�digo
; **********************************************************************
PLACE      0
inicio:		
; inicializa��es
    MOV  R2, TEC_LIN   ; endere�o do perif�rico das linhas
    MOV  R3, TEC_COL   ; endere�o do perif�rico das colunas
    MOV  R4, DISPLAYS  ; endere�o do perif�rico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  R7, 4         ; n�mero de linhas

; corpo principal do programa
ciclo:
    MOV  R1, 0 
    MOVB [R4], R1      ; escreve linha e coluna a zero nos displays
    MOV R10, 0
default_value:
	MOV R1, LINHA      ; linha default: 10000b shifted para 1000b
	MOV  R6, 0         ; usada para c�lculo do valor no input
	
shift:
	SHR R1, 1

espera_tecla:          ; neste ciclo espera-se at� uma tecla ser premida
	CMP  R1, 0         ; verificar se linha chegou a 0, voltar a 8
	JZ  default_value  ; volta � linha inicial, 8
    MOVB [R2], R1      ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas)
    AND  R0, R5        ; elimina bits para al�m dos bits 0-3
    CMP  R0, 0         ; h� tecla premida?
    JZ   shift         ; se nenhuma tecla premida, repete (muda de linha)
	MOV R8, R0         ; guarda coluna atual
	MOV R9, R1         ; guarda linha atual
	
log_col:               ; transfoma coluna em m em vez de 2^m
	ADD R6, 1
	SHR R0, 1
	CMP R0, 0
	JNZ log_col
	MOV R0, R6
	SUB R0, 1
	MOV R6, 0

log_lin:               ; transfoma linha em n em vez de 2^n
	ADD R6, 1
	SHR R1, 1
	CMP R1, 0
	JNZ log_lin
	MOV R1, R6
	SUB R1, 1
	MOV R6, 0

cria_valor:            ; cria valor da tecla e escreve-o
	MOV R6, R1
	MUL R6, R7
	ADD R6, R0
    CMP R6, 3
    JZ aumenta_valor
    CMP R6, 7
    JZ decrementa_valor

aumenta_valor: ; aumenta valor
    ADD R10, 1
    MOVB [R4], R10
    jmp ha_tecla

decrementa_valor: ; aumenta valor
    SUB R10, 1
    MOVB [R4], R10
	
ha_tecla:              ; neste ciclo espera-se at� NENHUMA tecla estar premida
    MOV  R1, R9     ; testar a linha 4  (R1 tinha sido alterado)
    MOVB [R2], R1      ; escrever no perif�rico de sa�da (linhas)
    MOVB R0, [R3]      ; ler do perif�rico de entrada (colunas)
    AND  R0, R5        ; elimina bits para al�m dos bits 0-3
    CMP  R0, 0         ; h� tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera at� n�o haver
    JZ espera_tecla