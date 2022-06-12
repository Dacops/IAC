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
SOM				EQU 605AH      	; endereço do comando para selecionar efeitos sonoros




LARGURA_NAVE			EQU	5		; largura da nave
ALTURA_NAVE				EQU	4		; altura da nave
POS_INICIAL_NAVE_X		EQU 30		; coluna inicial da nave
POS_INICIAL_NAVE_Y		EQU 28		; linha inicial da nave

LARGURA_INIMIGO 		EQU 5    	; largura do inimigo
ALTURA_INIMIGO  		EQU 5		; altura do inimigo
POS_INICIAL_INIMIGO_X	EQU 40		; coluna inicial do inimigo
POS_INICIAL_INIMIGO_Y	EQU 0		; linha inicial do inimigo


COR_PIXEL1  	EQU	0FF6FH		; cores da nave
COR_PIXEL2  	EQU 0FF3FH
COR_PIXEL3  	EQU 0FC3FH
COR_PIXEL4  	EQU 0F93FH
COR_PIXEL5  	EQU 0F2D3H		; cores do inimigo
COR_PIXEL6  	EQU 0F000H

MIN_COLUNA		EQU  0			; número da coluna mais à esquerda que o objeto pode ocupar
MAX_COLUNA		EQU  63			; número da coluna mais à direita que o objeto pode ocupar
ATRASO			EQU	2000H		; atraso para limitar a velocidade de movimento da nave
NAVE_COLUNA		EQU 2002H		; coluna atual da nave
NAVE_LINHA		EQU 2004H		; linha atual da nave
INIM_LINHA		EQU 2006H		; linha atual do inimigo
INIM_COLUNA 	EQU 2008H		; coluna atual do inimigo
DISPLAY			EQU 200AH		; valor atual no display



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
	WORD int_inimigo	; rotina de atendimento da interrupção 0

evento_int:
	WORD 0				; se 1, indica que a interrupção 0 ocorreu
						
DEF_NAVE:		; tabela que define o nave (cor,largura, pos inicial, pixels)
	WORD		LARGURA_NAVE
	WORD		ALTURA_NAVE
	WORD		0, 0, COR_PIXEL1, 0, 0
	WORD		COR_PIXEL2, 0, COR_PIXEL2, 0, COR_PIXEL2
    WORD        COR_PIXEL3, COR_PIXEL3, COR_PIXEL3, COR_PIXEL3, COR_PIXEL3
    WORD        0, COR_PIXEL4, 0, COR_PIXEL4, 0

DEF_INIMIGO:    ; tabela que define o inimigo (cor, largura,pos inicial,pixels)
    WORD		LARGURA_INIMIGO
    WORD		ALTURA_INIMIGO
    WORD		COR_PIXEL5, 0, 0, 0, COR_PIXEL5
    WORD        0, COR_PIXEL5, COR_PIXEL5, COR_PIXEL5, 0
    WORD        COR_PIXEL5, COR_PIXEL6, COR_PIXEL5, COR_PIXEL6, COR_PIXEL5
	WORD		COR_PIXEL5, COR_PIXEL5, COR_PIXEL5, COR_PIXEL5, COR_PIXEL5
    WORD        0, COR_PIXEL5, 0, COR_PIXEL5, 0
	
VAL_DISPLAY:	; tabela que guarda múltiplos de 5 para usar no display
	WORD		0H, 5H, 10H, 15H, 20H, 25H, 30H, 35H, 40H, 45H, 50H
	WORD		55H, 60H, 65H, 70H, 75H, 80H, 85H, 90H, 95H, 100H
	WORD		105H, 110H, 115H, 120H, 125H, 130H, 135H, 140H


; ***********************************************************************
; * Código																*
; ***********************************************************************
; inicialização de periféricos					
PLACE	0								; o código tem de começar em 0000H
MOV  	SP, SP_inicial					; inicialização de SP
MOV  	R1, DISPLAYS  					; endereço do periférico dos displays
MOV		R2, VAL_DISPLAY+40
MOV		[DISPLAY], R2					; valor 100 da tabela de valores possíveis no display
MOV		R11, [R2]
MOV 	[R1], R11      					; inicializa display a 100
MOV  	[APAGA_AVISO], R1				; apaga o aviso de nenhum cenário selecionado (o valor de R1 não é relevante)
MOV  	[APAGA_ECRA], R1				; apaga todos os pixels já desenhados (o valor de R1 não é relevante)
MOV	 	R1, 0			    			; cenário de fundo número 0
MOV  	[VIDEO], R1						; cenário de fundo em loop
MOV  	BTE, tab						; inicializa BTE (registo de Base da Tabela de Exceções)
EI0										; permite interrupções 0
EI										; permite interrupções (geral)


; desenha a nave no ecrã no inicio do jogo
desenha_nave_inicial:					; desenha a nave a partir da tabela
	MOV 	R1, POS_INICIAL_NAVE_Y
	MOV 	[NAVE_LINHA], R1			; inicializa a linha da nave
	MOV 	R2, POS_INICIAL_NAVE_X
	MOV 	[NAVE_COLUNA], R2			; inicializa a coluna da nave
	MOV 	R3, DEF_NAVE				; endereço da tabela que define a nave
	CALL 	desenha_objecto				; faz um desenho inicial da nave

; desenha o inimigo no ecrã no inicio do jogo
desenha_inimigo_inicial:				; desenha o inimigo a partir da tablea
	MOV 	R1, POS_INICIAL_INIMIGO_Y
	MOV 	[INIM_LINHA], R1			; inicializa a linha do inimigo
	MOV 	R2, POS_INICIAL_INIMIGO_X
	MOV 	[INIM_COLUNA], R2			; inicializa a coluna do inimigo
	MOV 	R3, DEF_INIMIGO				; endereço da tabela que define o inimigo
	CALL 	desenha_objecto				; faz um desenho inicial do inimigo


; corpo principal do programa
ciclo:
	MOV		R0, 5			; coloca sempre a tecla premida com um valor default
	CALL 	teclado
	CALL	display
	CMP 	R0, 0			; tecla da nave
	JZ		mexe_nave
	CMP 	R0, 1			; tecla da nave
	JZ		mexe_nave
	CMP		R0, 4			; tecla do inimigo
	JZ		mexe_inimigo
	JMP 	ciclo

	mexe_nave:
		CALL	nave			; move nave para a esquerda/direita
		JMP ciclo

	mexe_inimigo:
		CALL	inimigo			; move inimigo para baixo
		JMP ciclo
	


; rotina return, volta ao corpo principal do programa
return:
	RET
	

; ***********************************************************************
; * Descrição:			Obtém tecla premida								*
; * Argumentos:			R1 - Argumento dado ao teclado					*
; * 					R2 - Argumento recebido do teclado				*
; * Saídas:				R0 - Tecla premida em hexadecimal				*
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

	MOV  R5, evento_int
	MOV  R2, [R5]					; valor da variável que diz se houve uma interrupção 
	CMP  R2, 0
	JZ   sai_display				; se não houve interrupção, sai
	MOV  R2, 0
	MOV  [R5], R2					; coloca a zero o valor da variável que diz se houve uma interrupção (consome evento)
		
	; inicializações
	MOV		R1, [DISPLAY]			; endereço do valor atual na tabela de valores possíveis no display
	
	; decrementa o valor no display
	decrementa_valor:
		MOV		R2, VAL_DISPLAY		; obtém limite inferior do display, 1ª posição
		CMP		R1, R2				; da tabela (=0)
		JZ		return				; ------------ ACABA O JOGO -------------- 
		SUB		R1, 2				; vai buscar a anterior word na tabela de valores 
		MOV		[DISPLAY], R1		; possíveis no display (-5)
		
	; escreve valor no display
	escreve_display:
		MOV		R1, [DISPLAY]		; obtém atual endereço na tabela de valores de display
		MOV		R2, [R1]			; obtém valor através do endereço acima
		MOV 	[DISPLAYS], R2    	; muda valor no display
	
	sai_display:
	POP  R6
	POP  R5
	POP  R4
	POP  R3
	POP  R2
	POP  R1
	RET
	
	int_inimigo:					; Assinala o evento na componente 0 da variável evento_int
		PUSH R0
		PUSH R1
		MOV  R0, evento_int
		MOV  R1, 1					; assinala que houve uma interrupção 0
		MOV  [R0], R1				; na componente 0 da variável evento_int
		POP  R1
		POP  R0
		RFE

		
; ***********************************************************************
; * Descrição:			Movimenta a nave de forma contínua (Teclas 0/1)	*
; * Argumentos:			R0 - Tecla premida (em hexadecimal)				*
; *						2004H - Coluna Atual do Boneco					*
; * Saídas:				2004H - Nova coluna Atual do Boneco				*
; ***********************************************************************		
nave:
	CMP 	R0, 0					; verifica se a tecla '0' foi premida
    JZ 		inverte_para_esquerda	; move para a esquerda
    CMP 	R0, 1					; verifica se a tecla '2' foi premida
    JZ 		inverte_para_direita	; move para a direita

inverte_para_direita:			; testa limites antes de mexer o boneco
	MOV		R6, [DEF_NAVE]		; obtém a largura do boneco (primeira WORD da tabela)
	MOV  	R2, [NAVE_COLUNA]	; posição atual da nave
	ADD		R6, R2			    ; posição a seguir ao extremo direito do boneco
	SUB		R6, 1
	MOV		R5, MAX_COLUNA		; limite direito do ecrã
	CMP		R6, R5
	JZ		return
	MOV		R10, 1				; passa a deslocar-se para a direita
	JMP		info_nave

inverte_para_esquerda:			; testa limites antes de mexer o boneco
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
	MOV R3, DEF_INIMIGO			; endereço da tabela que define o inimigo	


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
