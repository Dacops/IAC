; *********************************************************************************
; * IST-UL
; * Modulo:    lab4-boneco.asm
; * Descrição: Este programa ilustra o desenho de um boneco do ecrã, em que os pixels
; *            são definidos por uma tabela.
; *			A zona de dados coloca-se tipicamente primeiro, para ser mais visível,
; *			mas o código tem de começar no endereço 0000H. As diretivas PLACE
; *			permitem esta inversão da ordem de dados e código no programa face aos endereços
; *********************************************************************************

; *********************************************************************************
; * Constantes
; *********************************************************************************
DEFINE_LINHA    		EQU 600AH      ; endereço do comando para definir a linha
DEFINE_COLUNA   		EQU 600CH      ; endereço do comando para definir a coluna
DEFINE_PIXEL    		EQU 6012H      ; endereço do comando para escrever um pixel
APAGA_AVISO     		EQU 6040H      ; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRÃ	 		EQU 6002H      ; endereço do comando para apagar todos os pixels já desenhados
SELECIONA_CENARIO_FUNDO  EQU 6042H      ; endereço do comando para selecionar uma imagem de fundo

LINHA       EQU  16        ; linha do boneco (a meio do ecrã))
COLUNA	    EQU  30        ; coluna do boneco (a meio do ecrã)

LARGURA		EQU	5			; largura do boneco
ALTURA		EQU	4H           ; altura do boneco
COR_PIXEL1  EQU	0FF6FH		; cor do pixel: vermelho em ARGB (opaco e vermelho no máximo, verde e azul a 0)
COR_PIXEL2  EQU  0FF3FH
COR_PIXEL3  EQU 0FC3FH
COR_PIXEL4  EQU 0F93FH

MIN_COLUNA		EQU  0		; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63        ; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	400H		; atraso para limitar a velocidade de movimento do boneco


; #######################################################################
; * ZONA DE DADOS 
; #######################################################################
PLACE		0100H				

DEF_BONECO:					; tabela que define o boneco (cor, largura, pixels)
	WORD		LARGURA
	WORD		ALTURA
	WORD		0, 0, COR_PIXEL1, 0, 0		; # # #   as cores podem ser diferentes
	WORD		COR_PIXEL2, 0, COR_PIXEL2, 0, COR_PIXEL2
    WORD        COR_PIXEL3, COR_PIXEL3, COR_PIXEL3, COR_PIXEL3, COR_PIXEL3
    WORD        0, COR_PIXEL4, 0, COR_PIXEL4, 0


; *********************************************************************************
; * Código
; *********************************************************************************
	PLACE   0				; o código tem de começar em 0000H
inicio:
    MOV  [APAGA_AVISO], R1	; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
    MOV  [APAGA_ECRÃ], R1	; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV	 R1, 1			    ; cenário de fundo número 0
    MOV  [SELECIONA_CENARIO_FUNDO], R1	; seleciona o cenário de fundo
    MOV  R10, 1              ; valor a somar à coluna do boneco para o movimentar
     
posição_boneco:
     MOV  R1, LINHA			; linha do boneco
     MOV  R2, COLUNA		; coluna do boneco
     MOV [2002H], R1        ; guardar a linha na memória
     MOV [2004H], R2        ; guardar a coluna na memoria

desenha_boneco:       		; desenha o boneco a partir da tabela
	MOV	R4, DEF_BONECO		; endereço da tabela que define o boneco
	MOV	R5, [R4]			; obtém a largura do boneco
    ADD R4, 2
    MOV	R7, [R4]            ; obtém a altura do boneco
	ADD	R4, 2			    ; endereço da cor do 1º pixel (2 porque a largura é uma word)

desenha_pixels:       		; desenha os pixels do boneco a partir da tabela
	MOV	 R3, [R4]			; obtém a cor do próximo pixel do boneco
	MOV  [DEFINE_LINHA], R1	; seleciona a linha
	MOV  [DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
	ADD	 R4, 2			; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
    ADD  R2, 1               ; próxima coluna
    SUB  R5, 1			; menos uma coluna para tratar
    JNZ  desenha_pixels      ; continua até percorrer toda a largura do objeto
    MOV  R5, LARGURA
    MOV  R2, [2004H]
    ADD  R1, 1
    SUB  R7, 1
    JNZ  desenha_pixels

    MOV	R11, ATRASO		; atraso para limitar a velocidade de movimento do boneco


ciclo_atraso:
	SUB	R11, 1
	JNZ	ciclo_atraso
    MOV R1, [2002H]
    MOV R7, ALTURA
    MOV R5, LARGURA
	
apaga_boneco:       		; desenha o boneco a partir da tabela
    MOV R5, LARGURA
	MOV	R6, [2004H]			; cópia da coluna do boneco

apaga_pixels:       	; desenha os pixels do boneco a partir da tabela
	MOV	 R3, 0			; para apagar, a cor do pixel é sempre 0
	MOV  [DEFINE_LINHA], R1	; seleciona a linha
	MOV  [DEFINE_COLUNA], R6	; seleciona a coluna
	MOV  [DEFINE_PIXEL], R3	; altera a cor do pixel na linha e coluna selecionadas
    ADD  R6, 1               ; próxima coluna
    SUB  R5, 1			    ; menos uma coluna para tratar
    JNZ  apaga_pixels   	; continua até percorrer toda a largura do objeto
    ADD  R1, 1              ; proxima linha
    SUB  R7, 1              ; menos uma linha para apagar
    JNZ  apaga_boneco
    MOV  R2, [2004H]
    MOV  R1, [2002H]

testa_limite_esquerdo:		; vê se o boneco chegou ao limite esquerdo
	MOV	R5, MIN_COLUNA
	CMP	R2, R5
	JLE	inverte_para_direita

testa_limite_direito:		; vê se o boneco chegou ao limite direito
	MOV	R6, [DEF_BONECO]	; obtém a largura do boneco (primeira WORD da tabela)
	ADD	R6, R2			    ; posição a seguir ao extremo direito do boneco
	MOV	R5, MAX_COLUNA
	CMP	R6, R5
	JGT	inverte_para_esquerda
	JMP	coluna_seguinte	; entre limites. Mnatém o valor do R7

inverte_para_direita:
	MOV	R10, 1			; passa a deslocar-se para a direita
	JMP	coluna_seguinte

inverte_para_esquerda:
	MOV	R10, -1			; passa a deslocar-se para a esquerda
	
coluna_seguinte:
	ADD	R2, R10			; para desenhar objeto na coluna seguinte (direita ou esquerda)
    MOV [2004H], R2     ; atualiza numero da coluna na memória

	JMP	desenha_boneco		; vai desenhar o boneco de novo





fim:
     JMP  fim                 ; termina programa