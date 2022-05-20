; *********************************************************************
; * IST-UL
; * Modulo:    lab3.asm
; * Descrição: Exemplifica o acesso a um teclado.
; *            Lê uma linha do teclado, verificando se há alguma tecla
; *            premida nessa linha.
; *
; * Nota: Observe a forma como se acede aos periféricos de 8 bits
; *       através da instrução MOVB
; *********************************************************************

; **********************************************************************
; * Constantes
; **********************************************************************
; ATENÇÃO: constantes hexadecimais que comecem por uma letra devem ter 0 antes.
;          Isto não altera o valor de 16 bits e permite distinguir números de identificadores
DISPLAYS   EQU 0A000H  ; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    EQU 0C000H  ; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    EQU 0E000H  ; endereço das colunas do teclado (periférico PIN)
LINHA      EQU 16      ; linha a testar (4ª linha, 1000b), 10000b usado pois é shifted inicialmente para 1000b
MASCARA    EQU 0FH     ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado

; **********************************************************************
; * Código
; **********************************************************************
PLACE      0
inicio:		
; inicializações
    MOV  R2, TEC_LIN   ; endereço do periférico das linhas
    MOV  R3, TEC_COL   ; endereço do periférico das colunas
    MOV  R4, DISPLAYS  ; endereço do periférico dos displays
    MOV  R5, MASCARA   ; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOV  R7, 4         ; número de linhas

; corpo principal do programa
ciclo:
    MOV  R1, 0 
    MOVB [R4], R1      ; escreve linha e coluna a zero nos displays

default_value:
	MOV R1, LINHA      ; linha default: 10000b shifted para 1000b
	MOV  R6, 0         ; usada para cálculo do valor no input
	
shift:
	SHR R1, 1

espera_tecla:          ; neste ciclo espera-se até uma tecla ser premida
	CMP  R1, 0         ; verificar se linha chegou a 0, voltar a 8
	JZ  default_value  ; volta à linha inicial, 8
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
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
    MOVB [R4], R6      ; escreve linha e coluna nos displays
	
ha_tecla:              ; neste ciclo espera-se até NENHUMA tecla estar premida
    MOV  R1, R9     ; testar a linha 4  (R1 tinha sido alterado)
    MOVB [R2], R1      ; escrever no periférico de saída (linhas)
    MOVB R0, [R3]      ; ler do periférico de entrada (colunas)
    AND  R0, R5        ; elimina bits para além dos bits 0-3
    CMP  R0, 0         ; há tecla premida?
    JNZ  ha_tecla      ; se ainda houver uma tecla premida, espera até não haver
    JMP  ciclo         ; repete ciclo
