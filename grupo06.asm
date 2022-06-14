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
DISPLAYS		EQU 0A000H  	; endereço dos displays de 7 segmentos (periférico POUT-1)
TEC_LIN    		EQU 0C000H  	; endereço das linhas do teclado (periférico POUT-2)
TEC_COL    		EQU 0E000H  	; endereço das colunas do teclado (periférico PIN)

LINHA      		EQU 8			; linha a testar (4ª linha, 1000b)
MASCARA1   		EQU 000FH		; para isolar os 4 bits de menor peso

DEFINE_LINHA    EQU 600AH      	; endereço do comando para definir a linha
DEFINE_COLUNA   EQU 600CH      	; endereço do comando para definir a coluna
DEFINE_PIXEL    EQU 6012H      	; endereço do comando para escrever um pixel
APAGA_AVISO     EQU 6040H     	; endereço do comando para apagar o aviso de nenhum cenário selecionado
APAGA_ECRA	 	EQU 6002H      	; endereço do comando para apagar todos os pixels já desenhados
VIDEO			EQU 605CH      	; endereço do comando para selecionar o vídeo de fundo em loop
PARA_VIDEO		EQU 6066H		; endereço do comando para remover o vídeo de fundo
IMAGEM			EQU 6042H		; endereço do comando para selecionar o imagem de fundo
SOM				EQU 605AH      	; endereço do comando para selecionar efeitos sonoros


LARGURA_NAVE			EQU	5		; largura da nave
ALTURA_NAVE				EQU	4		; altura da nave
LINHA_INICIAL_NAVE		EQU 28
COLUNA_INICIAL_NAVE		EQU 30

LARGURA_INIMIGO 		EQU 5    	; largura do inimigo
ALTURA_INIMIGO  		EQU 5		; altura do inimigo
LINHA_INICIAL_INIM		EQU 0
COLUNA_INICIAL_INIM		EQU 40


LARGURA_OVNI1			EQU 1
ALTURA_OVNI1			EQU 1
LARGURA_OVNI2			EQU 2
ALTURA_OVNI2			EQU 2

LARGURA_INIMIGO_PEQ		EQU 4
ALTURA_INIMIGO_PEQ		EQU 3

LARGURA_INIMIGO_MEDIO	EQU 5
ALTURA_INIMIGO_MEDIO	EQU 3

LARGURA_INIMIGO_GRANDE	EQU 5
ALTURA_INIMIGO_GRANDE	EQU 5

LARGURA_ENERGIA_PEQ		EQU 3
ALTURA_ENERGIA_PEQ		EQU 3

LARGURA_ENERGIA_MEDIO	EQU 5
ALTURA_ENERGIA_MEDIO	EQU 3

LARGURA_ENERGIA_GRANDE	EQU 5
ALTURA_ENERGIA_GRANDE	EQU 4

LARGURA_ENERGIA_ENORME	EQU 5
ALTURA_ENERGIA_ENORME	EQU 5

LARGURA_EXPLOSAO		EQU 5
ALTURA_EXPLOSAO			EQU 5

LARGURA_TIRO			EQU 1
ALTURA_TIRO				EQU 1


COR_BRANCO 		EQU 0FEEEH
COR_AZUL		EQU 0F09FH
COR_VERDE  		EQU 0F2D3H
COR_PRETO  		EQU 0F000H
COR_CINZENTO	EQU 0FCCCH		
COR_VERMELHO	EQU 0FF31H
COR_AMARELO		EQU 0FFF6H
COR_ROSA		EQU 0FF7FH
COR_ROXO		EQU 0FB6FH
COR_LARANJA		EQU 0FFA2H

MIN_COLUNA		EQU 0			; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU 63			; número da coluna mais à direita que o objeto pode ocupar

ATRASO			EQU	2000H		; atraso para limitar a velocidade de movimento da nave
DISPLAY_INICIAL EQU 0


; ***********************************************************************
; * Variáveis Globais						  							*
; ***********************************************************************
PLACE 			2000H

NAVE_COLUNA:  	WORD COLUNA_INICIAL_NAVE		; coluna atual da nave
NAVE_LINHA:		WORD LINHA_INICIAL_NAVE 		; linha atual da nave
INIM_COLUNA:	WORD COLUNA_INICIAL_INIM 		; linha atual do inimigo
INIM_LINHA: 	WORD LINHA_INICIAL_INIM  		; coluna atual do inimigo
DISPLAY:		WORD DISPLAY_INICIAL			; valor atual no display



; ***********************************************************************
; * Dados																*
; ***********************************************************************
PLACE       1000H
pilha:
	STACK 	100H; espaço reservado para a pilha 
				; (200H bytes, pois são 100H words)
SP_inicial:		; este é o endereço (1200H) com que o SP deve ser 
				; inicializado. O 1.º end. de retorno será 
				; armazenado em 11FEH (1200H-2)

tab:			; Tabela das rotinas de interrupção
	WORD int_inimigo
	WORD int_missil
	WORD int_energia

evento_int_inimigo:
	WORD 0				; se 1, indica que a interrupção 0 ocorreu

evento_int_missil:
	WORD 0

evento_int_energia:
	WORD 0


						
DEF_NAVE:		; tabela que define o nave (cor,largura, pos inicial, pixels)
	WORD		LARGURA_NAVE
	WORD		ALTURA_NAVE
	WORD		0, 0, COR_CINZENTO, 0, 0
	WORD		0, COR_BRANCO, COR_AZUL, COR_BRANCO, 0
    WORD        COR_BRANCO, COR_BRANCO, COR_CINZENTO, COR_BRANCO, COR_BRANCO
    WORD        COR_VERDE, 0, 0, 0, COR_VERMELHO

DEF_OVNI1:
	WORD		LARGURA_OVNI1
	WORD		ALTURA_OVNI1
	WORD		COR_CINZENTO

DEF_OVNI2:
	WORD		LARGURA_OVNI2
	WORD		ALTURA_OVNI2
	WORD		COR_CINZENTO, COR_CINZENTO
	WORD		COR_CINZENTO, COR_CINZENTO

DEF_INIMIGO_PEQ:
	WORD		LARGURA_INIMIGO_PEQ
	WORD		ALTURA_INIMIGO_PEQ
	WORD		0, COR_VERDE, COR_VERDE, 0
	WORD		COR_VERDE, 0, 0, COR_VERDE
	WORD		COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE

DEF_INIMIGO_MEDIO:
	WORD		LARGURA_INIMIGO_MEDIO
	WORD		ALTURA_INIMIGO_MEDIO
	WORD		0, COR_VERDE, COR_VERDE, 0
	WORD		COR_VERDE, COR_PRETO, COR_VERDE, COR_PRETO, COR_VERDE
	WORD		COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE

DEF_INIMIGO_GRANDE:
	WORD		LARGURA_INIMIGO_GRANDE
	WORD		ALTURA_INIMIGO_GRANDE
	WORD		COR_VERDE, 0, 0, 0, COR_VERDE
	WORD 		0, COR_VERDE, COR_VERDE, COR_VERDE, 0
	WORD		COR_VERDE, COR_PRETO, COR_VERDE, COR_PRETO, COR_VERDE
	WORD		COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE, COR_VERDE
	WORD		0, COR_VERDE, 0, COR_VERDE, 0

DEF_ENERGIA_PEQ:
	WORD 		LARGURA_ENERGIA_PEQ
	WORD		ALTURA_ENERGIA_PEQ
	WORD		COR_VERMELHO, 0, COR_VERMELHO
	WORD		COR_VERMELHO, COR_VERMELHO, COR_VERMELHO
	WORD		0, COR_VERMELHO, 0

DEF_ENERGIA_MEDIO:
	WORD		LARGURA_ENERGIA_MEDIO
	WORD		ALTURA_ENERGIA_MEDIO
	WORD		COR_VERMELHO, COR_VERMELHO, 0, COR_VERMELHO, COR_VERMELHO
	WORD		0, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, 0
	WORD		0, 0, COR_VERMELHO, 0, 0

DEF_ENERGIA_GRANDE:
	WORD		LARGURA_ENERGIA_GRANDE
	WORD		ALTURA_ENERGIA_GRANDE
	WORD		COR_VERMELHO, COR_VERMELHO, 0, COR_VERMELHO, COR_VERMELHO
	WORD		COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO
	WORD		0, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, 0
	WORD		0, 0, COR_VERMELHO, 0, 0

DEF_ENERGIA_ENORME:
	WORD		LARGURA_ENERGIA_ENORME
	WORD		ALTURA_ENERGIA_ENORME
	WORD		COR_VERMELHO, COR_VERMELHO, 0, COR_VERMELHO, COR_VERMELHO
	WORD		COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO
	WORD		COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO
	WORD		0, COR_VERMELHO, COR_VERMELHO, COR_VERMELHO, 0
	WORD		0, 0, COR_VERMELHO, 0, 0

DEF_EXPLOSAO:
	WORD		LARGURA_EXPLOSAO
	WORD		ALTURA_EXPLOSAO
	WORD		0, COR_AZUL, 0, COR_VERDE, 0
	WORD		COR_ROXO, 0, COR_ROSA, 0, COR_LARANJA
	WORD		0, COR_VERDE, 0, COR_ROSA, 0
	WORD		COR_LARANJA, 0, COR_AZUL, 0, COR_ROXO
	WORD		0, COR_ROSA, 0, COR_VERDE, 0

DEF_TIRO:
	WORD		LARGURA_TIRO
	WORD		ALTURA_TIRO
	WORD		COR_AMARELO



	
VAL_DISPLAY:	; tabela que guarda múltiplos de 5 para usar no display
	WORD		0H, 5H, 10H, 15H, 20H, 25H, 30H, 35H, 40H, 45H, 50H
	WORD		55H, 60H, 65H, 70H, 75H, 80H, 85H, 90H, 95H, 100H
	WORD		105H, 110H, 115H, 120H, 125H, 130H, 135H, 140H
	
TECLAS:			; tabela que define a relação tecla:função
	WORD		return, move_esquerda, move_direita, return
	WORD		inimigo, return, return, return
	WORD		return, return, return, return
	WORD		return, pause, game_over, return



; ***********************************************************************
; * Código																*
; ***********************************************************************
; inicialização de periféricos					
PLACE	0								; o código tem de começar em 0000H
MOV  	SP, SP_inicial					; inicialização de SP
MOV  	BTE, tab						; inicializa BTE (registo de Base da Tabela de Exceções)
EI0										; permite interrupções 0
EI1										; permite interrupções 1
EI2										; permite interrupções 2
EI										; permite interrupções gerais

prepara_ecra:
	MOV		R1, 0
	MOV  	[APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  	[APAGA_ECRA], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV		[IMAGEM], R1					; imagem de início de jogo
	JMP		inicio_jogo


; pausa o jogo
pause:
	MOV		R1, 2
	MOV  	[APAGA_AVISO], R1			; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  	[APAGA_ECRA], R1			; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV		[IMAGEM], R1				; imagem de início de jogo
	MOV		R1, 0
	MOV		[PARA_VIDEO], R1			; remove o vídeo de fundo
	CALL	premida
	
pause_loop:
	CALL	teclado
	MOV		R2, 0CH
	CMP 	R0, R2
	JNZ		pause_loop
	CALL	premida
	
	; valores anteriores
	MOV		R2, [DISPLAY]				; endereço do último valor no display
	MOV		R3, [R2]					; último valor no display
	MOV  	R1, DISPLAYS  				; endereço do periférico dos displays
	MOV 	[R1], R3      				; inicializa display a 100
	
	MOV	 	R1, 0			    		; cenário de fundo número 0
	MOV  	[VIDEO], R1					; cenário de fundo em loop
	
	MOV 	R1, [NAVE_LINHA]			; linha atual da nave
	MOV 	R2, [NAVE_COLUNA]			; coluna atual da nave
	MOV 	R3, DEF_NAVE				; endereço da tabela que define a nave
	CALL 	desenha_objecto				; desenha a nave

	MOV 	R1, [INIM_LINHA]			; linha atual do inimigo
	MOV 	R2, [INIM_COLUNA]			; coluna atual do inimigo
	MOV 	R3, DEF_INIMIGO_GRANDE		; endereço da tabela que define o inimigo
	CALL 	desenha_objecto				; faz um desenho inicial do inimigo
	
	JMP		ciclo



; espera pelo início do jogo, tecla C
inicio_jogo:							
	CALL	teclado
	MOV		R2, 0CH
	CMP 	R0, R2					
	JNZ		inicio_jogo
	
; inicializações de periféricos para o jogo
MOV  	R1, DISPLAYS  					; endereço do periférico dos displays
MOV		R2, VAL_DISPLAY+40				
MOV		[DISPLAY], R2					; valor 100 da tabela de valores possíveis no display
MOV		R11, [R2]
MOV 	[R1], R11      					; inicializa display a 100
MOV	 	R1, 0			    			; cenário de fundo número 0
MOV  	[VIDEO], R1						; cenário de fundo em loop

; desenha a nave no ecrã no inicio do jogo
desenha_nave_inicial:					; desenha a nave a partir da tabela
	MOV 	R1, [NAVE_LINHA]
	MOV 	[NAVE_LINHA], R1			; inicializa a linha da nave
	MOV 	R2, [NAVE_COLUNA]
	MOV 	[NAVE_COLUNA], R2			; inicializa a coluna da nave
	MOV 	R3, DEF_NAVE				; endereço da tabela que define a nave
	CALL 	desenha_objecto				; faz um desenho inicial da nave

; desenha o inimigo no ecrã no inicio do jogo
desenha_inimigo_inicial:				; desenha o inimigo a partir da tablea
	MOV 	R1, [INIM_LINHA]
	MOV 	[INIM_LINHA], R1			; inicializa a linha do inimigo
	MOV 	R2, [INIM_COLUNA]
	MOV 	[INIM_COLUNA], R2			; inicializa a coluna do inimigo
	MOV 	R3, DEF_INIMIGO_GRANDE		; endereço da tabela que define o inimigo
	CALL 	desenha_objecto				; faz um desenho inicial do inimigo


; corpo principal do programa
ciclo:
	MOV		R0, 0			; coloca sempre a tecla premida com um valor default
	CALL 	teclado
	CALL	display
	SHL		R0, 1
	MOV		R1, TECLAS
	ADD		R1, R0
	MOV		R2, [R1]
	
	CALL	R2
	JMP		ciclo
	


; jogo terminado -----------------------------------------------------------------------------
game_over:
	MOV		R1, 1
	MOV  	[APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
	MOV  	[APAGA_ECRA], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
	MOV		[IMAGEM], R1					; imagem de início de jogo
	MOV		R1, 0
	MOV		[PARA_VIDEO], R1				; remove o vídeo de fundo
	CALL 	reinicia_valores
	
end_loop:
	CALL 	teclado
	MOV		R2, 0CH
	CMP		R0, R2
	CALL	premida
	JZ		prepara_ecra
	JMP		end_loop

reinicia_valores:
	PUSH	R1
	MOV		R1, LINHA_INICIAL_NAVE
	MOV		[NAVE_LINHA], R1
	MOV		R1, COLUNA_INICIAL_NAVE
	MOV		[NAVE_COLUNA], R1
	MOV 	R1, DISPLAY_INICIAL
	MOV		[DISPLAY], R1
	POP 	R1
	RET

;-------------------------------------------------------------------------------------


; ***********************************************************************
; * Descrição:			Obtém tecla premida								*
; * Argumentos:			R1 - Argumento dado ao teclado					*
; * 					R2 - Argumento recebido do teclado				*
; * Saídas:				R0 - Tecla premida em hexadecimal				*
; ***********************************************************************
teclado:
	; inicializações
	MOV		R0, 0			; valor de saída default
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
	
	RET
	
; indica quando a tecla deixar de ser premida
premida:
	MOV		R6, R7		; linha onde tecla foi premida
	MOVB 	[R3], R6    ; escrever no periférico de saída (linhas)
	MOVB 	R2, [R4]    ; ler do periférico de entrada (colunas)
	AND  	R2, R5      ; elimina bits para além dos bits 0-3
	CMP  	R2, 0       ; há tecla premida?
	JNZ  	premida   	; se ainda houver uma tecla premida, espera até não haver
	RET



		
		
; ***********************************************************************
; * Descrição:			Incrementa/decrementa o display (Teclas 3/7)	*
; * Argumentos:			R0 - Tecla premida (em hexadecimal)				*
; *						200AH - Valor atual no display					*
; * Saídas:				200AH - Novo valor no display					*
; ***********************************************************************
display:
	PUSH R1
	PUSH R2
	PUSH R3
	PUSH R4
	PUSH R5
	PUSH R6		

	MOV  R5, evento_int_energia
	MOV  R2, [R5]					; valor da variável que diz se houve uma interrupção 
	CMP  R2, 0
	JZ   sai_display				; se não houve interrupção, sai
	MOV  R2, 0
	MOV  [R5], R2					; coloca a zero o valor da variável que diz se houve uma interrupção (consome evento)
		
	; inicializações
	MOV		R1, [DISPLAY]			; endereço do valor atual na tabela de valores possíveis no display
	
	; decrementa o valor no display
	decrementa_valor:
		SUB		R1, 2				; vai buscar a anterior word na tabela de valores (-5)
		MOV		[DISPLAY], R1		; novo valor de energia
		
	; escreve valor no display
	escreve_display:
		MOV		R1, [DISPLAY]		; obtém atual endereço na tabela de valores de display
		MOV		R2, [R1]			; obtém valor através do endereço acima
		MOV 	[DISPLAYS], R2    	; muda valor no display
		
	MOV		R2, VAL_DISPLAY
	CMP		R1, R2				; chega ao início da tabela, energia = 0
	JZ		game_over			; energia a 0, perde o jogo
	
	sai_display:
	POP  R6
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	RET
	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	int_inimigo:					; Assinala o evento na componente 0 da variável evento_int
		PUSH R0
		PUSH R1
		MOV  R0, evento_int_inimigo
		MOV  R1, 1					; assinala que houve uma interrupção 0
		MOV  [R0], R1				; na componente 0 da variável evento_int
		POP  R1
		POP  R0
		RFE


	int_missil:					; Assinala o evento na componente 0 da variável evento_int
		PUSH R0
		PUSH R1
		MOV  R0, evento_int_missil
		MOV  R1, 1					; assinala que houve uma interrupção 0
		MOV  [R0], R1				; na componente 0 da variável evento_int
		POP  R1
		POP  R0
		RFE


	int_energia:					; Assinala o evento na componente 0 da variável evento_int
		PUSH R0
		PUSH R1
		MOV  R0, evento_int_energia
		MOV  R1, 1					; assinala que houve uma interrupção 0
		MOV  [R0], R1				; na componente 0 da variável evento_int
		POP  R1
		POP  R0
		RFE


; rotinas + ou - a meio do programa para evitar calls a uma distância maior de 100H, dá erro 

; rotina return, volta ao corpo principal do programa
return:
	RET




	
; ***********************************************************************
; * Descrição:			Movimenta a nave de forma contínua (Teclas 1/2)	*
; * Argumentos:			R0 - Tecla premida (em hexadecimal)				*
; *						2004H - Coluna Atual do Boneco					*
; * Saídas:				2004H - Nova coluna Atual do Boneco				*
; ***********************************************************************		
move_direita:			; testa limites antes de mexer o boneco
	MOV		R6, [DEF_NAVE]		; obtém a largura do boneco (primeira WORD da tabela)
	MOV  	R2, [NAVE_COLUNA]	; posição atual da nave
	ADD		R6, R2			    ; posição a seguir ao extremo direito do boneco
	SUB		R6, 1
	MOV		R5, MAX_COLUNA		; limite direito do ecrã
	CMP		R6, R5
	JZ		return
	MOV		R10, 1				; passa a deslocar-se para a direita
	JMP		info_nave

move_esquerda:			; testa limites antes de mexer o boneco
	MOV		R5, MIN_COLUNA		; limite esquerdo do ecrã
	MOV  	R2, [NAVE_COLUNA]	; posição atual da nave
	CMP		R2, R5
	JZ		return
	MOV		R10, -1				; passa a deslocar-se para a esquerda

info_nave:						; vai buscar as informações da nave
	MOV R1, [NAVE_LINHA]		; lê a linha atual da nave
	MOV R2, [NAVE_COLUNA]		; lê a coluna atual da nave
	MOV R3, DEF_NAVE			; enderaço da tabela que define a nave

apaga_nave:       				; apaga a nave da posição onde estiver
	CALL apaga_objeto

desenha_coluna_seguinte:
	ADD	R2, R10					; para desenhar objeto na coluna seguinte (direita ou esquerda)
    MOV [NAVE_COLUNA], R2     	; atualiza numero da coluna na memória
	CALL desenha_objecto


MOV	R8, ATRASO					; atraso para limitar a velocidade de movimento da nave
ciclo_atraso:
	SUB		R8, 1				; subtrai 1 do valor de atraso
	JNZ		ciclo_atraso		; sai do ciclo quando o valor de atraso chegar a 0
	
RET



; ***********************************************************************
; * Descrição:			Movimenta o inimigo pixel a pixel (Tecla 4)		*
; * Argumentos:			R0 - Tecla premida (em hexadecimal)				*
; *						2006H - linha atual do inimigo					*
; * Saídas:				2006H - nova linha atual do inimigo				*
; ***********************************************************************		
inimigo:
	CALL premida				; verifica quando a tecla deixa de ser premida
	MOV R1, [INIM_LINHA]		; lê a linha atual do inimigo
	MOV R4, 23
	CMP R1, R4					; verificar se já antigiu o limite do ecrã
	JZ 	return
	MOV R2, [INIM_COLUNA]		; lê a coluna atual do inimigo
	MOV R3, DEF_INIMIGO_GRANDE	; endereço da tabela que define o inimigo	


apaga_inimigo:       			; apaga o inimigo da posição onde estiver
	CALL apaga_objeto

PUSH 	R1
MOV	 	R1, 1			    	; efeito sonoro do inimigo
MOV  	[SOM], R1				; efeito sonoro toca
POP 	R1

desenha_linha_seguinte:
	ADD	R1, 1					; para desenhar objeto na linha seguinte
    MOV [INIM_LINHA], R1     	; atualiza numero da coluna na memória
	CALL desenha_objecto
	
RET




; ***********************************************************************
; * Descrição:			Apaga todos os pixels de um objeto				*
; * Argumentos:			R1 - linha					 					*
; *						R2 - coluna 									*
; *						R3 - tabela que define o objeto					*
; * Saídas:				NULL											*
; ***********************************************************************
apaga_objeto:       			; desenha os pixels da nave a partir da tabela
	PUSH 	R1
	PUSH	R2
	PUSH 	R3
	MOV 	R4, [R3]			; lê a largura do objeto da tabela que o define
	ADD 	R3, 2
	MOV 	R5, [R3]			; lê a altura do objeto
	MOV		R8, R4				; cópia da largura do objeto
	MOV 	R9, R2				; cópia da coluna onde o objeto começa
	MOV	 	R6, 0				; para apagar, a cor do pixel é sempre 0

apaga_pixels:
	CALL 	escreve_pixel
	ADD  	R2, 1              	; próxima coluna
	SUB  	R8, 1			    ; menos uma coluna para tratar
	JNZ  	apaga_pixels   		; continua até percorrer toda a largura do objeto
	MOV 	R2, R9				; reset da coluna onde o objeto começa
	MOV 	R8, R4				; reset da largura do objeto
	ADD  	R1, 1              	; proxima linha
	SUB  	R5, 1               ; menos uma linha para apagar
	JNZ  	apaga_pixels		; continua até percorrer toda a altura do objeto
	POP 	R3
	POP 	R2
	POP 	R1
	RET


; ***********************************************************************
; * DESENHA_OBJETO - Desenha um boneco na linha e coluna indicadas	   	*
; *			    	com a forma e cor definidas na tabela indicada.		*	
; * Argumentos:  	R1 - linha											*
; *              	R2 - coluna											*
; *              	R3 - tabela que define o objeto						*
; *	Saídas:			NULL												*
; ***********************************************************************
desenha_objecto:       			; desenha os pixels do objetoe a partir da tabela
	PUSH 	R1
	PUSH	R2
	PUSH	R3
	MOV		R4, [R3]			; lê a largura do objeto
	ADD 	R3, 2
	MOV     R5, [R3]			; lê a altura do objeto
	ADD		R3, 2
	MOV		R8, R4				; cópia da largura do objeto
	MOV 	R9, R2				; cópia da coluna onde o objeto começa

desenha_pixels:
	MOV	 	R6, [R3]			; obtém a cor do próximo pixel do objeto
	CALL 	escreve_pixel
	ADD	 	R3, 2				; endereço da cor do próximo pixel (2 porque cada cor de pixel é uma word)
	ADD  	R2, 1              	; próxima coluna
	SUB  	R8, 1				; menos uma coluna para tratar
	JNZ  	desenha_pixels     ; continua até percorrer toda a largura do objeto
	MOV 	R2, R9				; reset da coluna onde o objeto começa
	MOV 	R8, R4				; reset da largura do objeto
	ADD  	R1, 1              	; proxima linha
	SUB  	R5, 1               ; menos uma linha para tratar
	JNZ  	desenha_pixels		; continua até percurrer a altura total do objeto
	POP 	R3
	POP 	R2
	POP 	R1
	RET


; ***********************************************************************
; * ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.		*
; * Argumentos:		R1 - linha											*
; *              	R2 - coluna											*
; *              	R6 - cor do pixel (em formato ARGB de 16 bits)		*
; * Saídas:			NULL												*
; ***********************************************************************
escreve_pixel:
	MOV  	[DEFINE_LINHA], R1	; seleciona a linha
	MOV  	[DEFINE_COLUNA], R2	; seleciona a coluna
	MOV  	[DEFINE_PIXEL], R6	; altera a cor do pixel na linha e coluna selecionadas
	RET
