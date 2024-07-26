; ************************************************
; PROJETO DE IAC (Versão Intermédia)
; Grupo 21
; Realizado por:
; - Fábio Neto,     104126
; - Pedro Almeida,  104168
; - Henrique Silva, 103606
; ************************************************

; ************************************************
; Funcionamento das teclas:
; Tecla 0: movimenta o rover para a esquerda (continuamente caso a tecla não deixe de ser permitida;
; Tecla 1: dispara o míssil;
; Tecla 2: movimenta o rover para a direita (continuamente caso a tecla não deixe de ser permitida;
; Tecla C: começa/recomeça o jogo;
; Tecla D: pausa/retoma o jogo;
; Tecla E: termina o jogo.
; ************************************************
; Resumo do jogo:
; O jogo chuva de meteoros basia-se num rover controlado pelo jogador que se mode, possui energia
; e tem capacidade de disparar um missil que destroi os meteoros
; O objetivo do jogo é destruir os meteoros maus, absorver a energia dos meteoros bons e por sua vez
; não deixar que a energia do rover chegue a zero. Há duas maneiras de ganhar energia sendo elas 
; absorver energia dos meteoros bons colidindo com eles e acertar com o missil nos meteoros maus, apesar
; de o disparo do missil causar a perda de energia.
; O jogo acaba quando a energia chega a zero ou o rover colide com um meteoro mau.
; ************************************************

;  ******************
; **** CONSTANTES ****
;  ******************

; endereços de memória do media center
APAGA_ECRAS				EQU 6002H	; apaga todos os pixels já desenhados
SELECIONA_ECRA			EQU 6004H	; seleciona um ecrã
SELECIONA_LINHA			EQU 600AH	; definir a linha
SELECIONA_COLUNA		EQU 600CH	; definir a coluna
SELECIONA_PIXEL			EQU 6012H	; escrever um pixel
APAGA_PIXEL				EQU 6018H	; apaga um pixel
REMOVE_BG				EQU 6040H	; apagar o aviso de nenhum cenário selecionado
REMOVE_FG				EQU 6044H	; remove a imagem do cenário frontal
SELECIONA_BG			EQU 6042H	; seleciona uma imagem para o cenário de fundo
SELECIONA_FG 			EQU 6046H	; seleciona uma imagem para o cenário frontal
REPRODUZ_MIDIA			EQU 605AH	; reproduz um som/vídeo
REPRODUZ_MIDIA_LOOP		EQU 605CH	; reproduz um som/vídeo em loop até ser parado
PAUSA_MIDIAS			EQU 6062H	; pausa um som/vídeo
RETOMA_MIDIAS			EQU 6064H	; retoma um som/vídeo
TERMINA_MIDIAS			EQU 6068H	; termina a reprodução de todos os sons/vídeos em loop
; outros endereços de memória
DISPLAY					EQU 0A000H	; periférico POUT-1 ligado a 3 displays
TEC_LIN					EQU 0C000H	; periférico POUT-2 que liga às linhas do teclado
TEC_COL					EQU 0E000H	; periférico PIN que liga às colunas do teclado

; backgrounds
IMG_INICIO				EQU 0		; imagem de início
IMG_GAMEPLAY			EQU 1		; imagem de gameplay
IMG_PAUSA				EQU 2		; imagem de pausa
IMG_PARADO				EQU 3		; imagem de jogo parado
IMG_ROVER_SEM_ENERGIA	EQU 4		; imagem para quando o rover fica sem energia
IMG_ROVER_EXPLODIU		EQU 5		; imagem para quando o rover explode

; sons
SOM_ROVER_DISPARO		EQU 0		; disparo do rover
SOM_METEORO_EXPLOSAO	EQU 1		; explosão do meteoro
SOM_ABSORCAO_ENERGIA	EQU 2		; colisão do rover com o meteoro bom
SOM_ROVER_SEM_ENERGIA	EQU 3		; rover sem energia
MUSICA_DE_FUNDO			EQU 4		; música de fundo
SOM_ROVER_DESTRUIDO		EQU 5		; rover destruído pela nave inimiga

; teclas
TECLA_0					EQU 00H		; tecla 0
TECLA_1					EQU 01H		; tecla 1
TECLA_2					EQU 02H		; tecla 2
TECLA_C					EQU 0CH		; tecla C
TECLA_D					EQU 0DH		; tecla D
TECLA_E					EQU 0EH		; tecla E

; limites do ecrã
N_COLUNAS				EQU 64		; número de colunas do ecrã
N_LINHAS				EQU 32		; número de linhas do ecrã

; modos do jogo
JOGO_ATIVO				EQU 0		; estado_do_jogo de jogo ativo
JOGO_EM_PAUSA			EQU 1		; estado_do_jogo de jogo em pausa
JOGO_PARADO				EQU 2		; estado_do_jogo de jogo parado

; explosão
TAMANHO_EXPLOSAO		EQU 5		; tamanho da explosão

; rover
LARGURA_ROVER			EQU 5		; largura do rover
ALTURA_ROVER			EQU 3		; altura do rover
LINHA_ROVER				EQU 29		; linha de referência do rover
ATRASO_ROVER			EQU 09000H	; atraso aplicado à movimentação do rover

; meteoros
N_METEOROS				EQU 5		; número de meteoros
TAMANHO_MET_1			EQU 1       ; tamanho inicial dos meteoros em cinzento
TAMANHO_MET_2			EQU 2       ; tamanho final dos meteoros em cinzento
TAMANHO_MET_3			EQU 3       ; tamanho inicial dos meteoros (com cor)
TAMANHO_MET_4			EQU 4       ; tamanho intermédio dos meteoros (com cor)
TAMANHO_MET_5			EQU 5       ; tamanho final dos meteoros (com cor)
COR_MET_NEUTRO			EQU 0FBBBH  ; cor meteoro comeco (cinzento)
COR_MET_BOM				EQU 0F0E2H  ; cor do meteoro bom (verde)
COR_MET_MAU				EQU 0FF11H  ; cor do meteoro mau (vermelho)
ATRASO_EVOLUCAO			EQU 3		; número de movimentos até o meteoro evoluir
ATRASO_METEOROS			EQU 4		; número de movimentos até nascer outro meteoro
MET_NIVEL_MAX			EQU 5		; nível máximo que o meteoro pode alcançar
METEORO_BOM				EQU 0		; indica que o meteoro é bom
METEORO_MAU				EQU 1		; indica que o meteoro é mau

; míssil
ALCANCE_MISSIL			EQU 15		; número de movimentos que o míssil pode fazer até extinguir
TAMANHO_MISSIL			EQU 1		; tamanho do míssil

; cores
COR_EXPLOSAO            EQU 0F2FFH	; cor da explosão
COR_ROVER				EQU 0EFE4H	; cor do rover RGB
COR_MISSIL				EQU 0ED12H	; cor do míssil
SEM_COR					EQU 00000H	; cor usada para desativar pixeis

; energia
ENERGIA_DISPARO			EQU -5		; custo em energia de cada disparo
ENERGIA_FUNCIONAMENTO	EQU -5		; custo em energia do funcionamento do rover
ENERGIA_NAVE_DESTRUIDA	EQU 5		; energia ganha ao destruir uma nave inimiga
ENERGIA_METEORO_BOM		EQU 10		; energia ganha pela colisão com um meteoro bom
MAX_ENERGIA				EQU 100		; máximo de energia que o rover pode armazenar

; colisões
COLISAO_MET_BOM_ROVER	EQU -1		; identitificador de colisão meteoro bom/rover
COLISAO_MET_MAU_ROVER	EQU -2		; identitificador de colisão meteoro mau/rover
COLISAO_MET_BOM_MISSIL	EQU -3		; identitificador de colisão meteoro bom/míssil
COLISAO_MET_MAU_MISSIL	EQU -4		; identitificador de colisão meteoro mau/míssil

; outros
MASCARA					EQU 000FH	; máscara 0-3 bits
FATOR     				EQU	1000	; fator inicial
DIVISOR_10				EQU 10		; divisor do fator
INDEFINIDO				EQU -1		; valor indefinido
FALSO					EQU 0		; valor falso
VERDADEIRO				EQU 1		; valor verdadeiro


;  *********************
; **** DADOS MEMÓRIA ****
;  *********************

PLACE 1000H
; pilhas dos processos
    STACK 100H
pilha_principal:
	STACK 100H
pilha_teclado:
	STACK 100H
pilha_rover:
	STACK 100H
pilha_energia:
	STACK 100H
pilha_missil:
	STACK 100H
pilha_meteoro_0:
	STACK 100H
pilha_meteoro_1:
	STACK 100H
pilha_meteoro_2:
	STACK 100H
pilha_meteoro_3:
	STACK 100H
pilha_meteoro_4:

pilhas_meteoro:
	WORD pilha_meteoro_0, pilha_meteoro_1, pilha_meteoro_2, pilha_meteoro_3, pilha_meteoro_4

tab:
	WORD rot_int_meteoro	; rotina de interrupção do evento de meteoro
	WORD rot_int_missil		; rotina de interrupção do evento de míssil
	WORD rot_int_energia	; rotina de interrupção do evento de energia
evento_meteoro:
	LOCK 0					; evento de interrupção, controla o avanço dos meteoros
evento_missil:
	LOCK 0					; evento de interrupção, controla o avanço do míssil
evento_energia:
	LOCK 0					; evento de interrupção, controla a diminuição de energia do rover
evento_comecar:
	LOCK 0					; evento chamado quando o jogo muda para o estado ativo
evento_tecla_premida:
	LOCK 0					; evento chamado pelo processo teclado quando uma tecla é premida
evento_tecla_solta:
	LOCK 0					; evento chamado pelo processo teclado quando uma tecla é solta, depois de premida
estado_do_jogo:
	WORD JOGO_PARADO		; estado em que o jogo se encontra (0 = ativo, 1 = em pausa, 2 = parado)
energia_rover:
	WORD INDEFINIDO			; energia do rover
coluna_rover:
	WORD INDEFINIDO			; coluna de referência do rover
linha_missil:
	WORD INDEFINIDO			; linha de referência do míssil
coluna_missil:
	WORD INDEFINIDO			; coluna de referência do míssil
colisao_missil:
	WORD FALSO				; indica se o míssil colidiu com algum meteoro (valor booleano)

; tabelas usadas para desenhar/apagar bonecos
explosao:
	WORD TAMANHO_EXPLOSAO, TAMANHO_EXPLOSAO
	WORD SEM_COR,		COR_EXPLOSAO,	SEM_COR,		COR_EXPLOSAO,	SEM_COR
	WORD COR_EXPLOSAO,	SEM_COR,		COR_EXPLOSAO,	SEM_COR,		COR_EXPLOSAO
	WORD SEM_COR,		COR_EXPLOSAO,	SEM_COR,		COR_EXPLOSAO,	SEM_COR
	WORD COR_EXPLOSAO,	SEM_COR,		COR_EXPLOSAO,	SEM_COR,		COR_EXPLOSAO
	WORD SEM_COR,		COR_EXPLOSAO,	SEM_COR,		COR_EXPLOSAO,	SEM_COR
missil:
	WORD TAMANHO_MISSIL, TAMANHO_MISSIL, COR_MISSIL
rover:
    WORD LARGURA_ROVER, ALTURA_ROVER
	WORD SEM_COR,	SEM_COR,	COR_ROVER, SEM_COR,		SEM_COR
	WORD COR_ROVER,	SEM_COR,	COR_ROVER, SEM_COR,		COR_ROVER
    WORD SEM_COR,	COR_ROVER,	COR_ROVER, COR_ROVER,	SEM_COR
meteoro_nivel_1:
    WORD TAMANHO_MET_1, TAMANHO_MET_1
    WORD COR_MET_NEUTRO
meteoros_nivel_2:
    WORD TAMANHO_MET_2, TAMANHO_MET_2
    WORD COR_MET_NEUTRO, COR_MET_NEUTRO
    WORD COR_MET_NEUTRO, COR_MET_NEUTRO
meteoro_bom_nivel_3:
    WORD TAMANHO_MET_3, TAMANHO_MET_3
    WORD SEM_COR,		COR_MET_BOM, SEM_COR
    WORD COR_MET_BOM,	COR_MET_BOM, COR_MET_BOM
    WORD SEM_COR,		COR_MET_BOM, SEM_COR
meteoro_bom_nivel_4:
    WORD TAMANHO_MET_4, TAMANHO_MET_4
    WORD SEM_COR,		COR_MET_BOM, COR_MET_BOM, SEM_COR
    WORD COR_MET_BOM,	COR_MET_BOM, COR_MET_BOM, COR_MET_BOM
    WORD COR_MET_BOM,	COR_MET_BOM, COR_MET_BOM, COR_MET_BOM
    WORD SEM_COR,		COR_MET_BOM, COR_MET_BOM, SEM_COR
meteoro_bom_nivel_5:
    WORD TAMANHO_MET_5, TAMANHO_MET_5
    WORD SEM_COR,		COR_MET_BOM, COR_MET_BOM, COR_MET_BOM, SEM_COR
    WORD COR_MET_BOM,	COR_MET_BOM, COR_MET_BOM, COR_MET_BOM, COR_MET_BOM
    WORD COR_MET_BOM,	COR_MET_BOM, COR_MET_BOM, COR_MET_BOM, COR_MET_BOM
    WORD COR_MET_BOM,	COR_MET_BOM, COR_MET_BOM, COR_MET_BOM, COR_MET_BOM
    WORD SEM_COR,		COR_MET_BOM, COR_MET_BOM, COR_MET_BOM, SEM_COR
meteoro_mau_nivel_3:
    WORD TAMANHO_MET_3, TAMANHO_MET_3
    WORD COR_MET_MAU,	SEM_COR,		COR_MET_MAU
    WORD SEM_COR,		COR_MET_MAU,	SEM_COR
    WORD COR_MET_MAU,	SEM_COR,		COR_MET_MAU
meteoro_mau_nivel_4:
    WORD TAMANHO_MET_4, TAMANHO_MET_4
    WORD COR_MET_MAU,	SEM_COR,		SEM_COR,		COR_MET_MAU
    WORD COR_MET_MAU,	SEM_COR,		SEM_COR,		COR_MET_MAU
    WORD SEM_COR,		COR_MET_MAU,	COR_MET_MAU,	SEM_COR
    WORD COR_MET_MAU,	SEM_COR,		SEM_COR,		COR_MET_MAU
meteoro_mau_nivel_5:
    WORD TAMANHO_MET_5,	TAMANHO_MET_5
    WORD COR_MET_MAU,	SEM_COR,		SEM_COR,		SEM_COR,		COR_MET_MAU
    WORD COR_MET_MAU,	SEM_COR,		COR_MET_MAU,	SEM_COR,		COR_MET_MAU
    WORD SEM_COR,		COR_MET_MAU,	COR_MET_MAU,	COR_MET_MAU,	SEM_COR
    WORD COR_MET_MAU,	SEM_COR,		COR_MET_MAU,	SEM_COR,		COR_MET_MAU
    WORD COR_MET_MAU,	SEM_COR,		SEM_COR,		SEM_COR,		COR_MET_MAU
; evoluções dos meteoros
evolucoes_meteoro_bom:
	WORD meteoro_nivel_1, meteoros_nivel_2
	WORD meteoro_bom_nivel_3, meteoro_bom_nivel_4, meteoro_bom_nivel_5
evolucoes_meteoro_mau:
	WORD meteoro_nivel_1, meteoros_nivel_2
	WORD meteoro_mau_nivel_3, meteoro_mau_nivel_4, meteoro_mau_nivel_5

;  **************
; **** CÓDIGO ****
;  **************
PLACE 0
    MOV SP, pilha_principal				; inicializa SP para a palavra a seguir à última da pilha
	MOV BTE, tab
	EI0
	EI1
	EI2
	EI

	CALL processo_teclado
	CALL processo_movimento_rover
	CALL processo_energia_rover
	CALL processo_missil
	
	MOV R0, N_METEOROS				; número de processos a criar
cria_processos_meteoro:
	SUB R0, 1						; menos um processo a criar
	CALL processo_meteoro			; cria uma nova instância do processo
	CMP R0, 0						; verifica se todos os meteoros já foram criados
	JNZ cria_processos_meteoro		; se não, cria mais um

;  *****************
; **** PROCESSOS ****
;  *****************

; **************************************************************************************
; PROCESSO CONTROLO - Controla o estado do jogo através das teclas 'C', 'D' e 'E'
; Registos reservados: R11 - energia inicial do rover
;                      R10 - tecla solta
;                      R9 - estado do jogo
;                      R7 - imagem de jogo parado
;                      R6 - imagem de jogo em pausa
;                      R5 - imagem de início
;                      R4 - vídeo de fundo
;                      R3 - música de fundo
;                      R2 - tecla 'E'
;                      R1 - tecla 'D'
;                      R0 - tecla 'C'
; **************************************************************************************
processo_controlo:
	MOV R0, TECLA_C						; tecla 'C'
	MOV R1, TECLA_D						; tecla 'D'
	MOV R2, TECLA_E						; tecla 'E'
	MOV R3, MUSICA_DE_FUNDO				; música de fundo
	MOV R4, IMG_GAMEPLAY				; imagem de fundo
	MOV R5, IMG_INICIO					; imagem de início
	MOV R6, IMG_PAUSA					; imagem de pausa
	MOV R7, IMG_PARADO					; imagem de paragem
	MOV R11, MAX_ENERGIA				; energia inicial do rover
	MOV [APAGA_ECRAS], R8				; apaga os pixels do ecrã
	MOV [REMOVE_BG], R8					; apaga o aviso de nenhum cenário selecionado
	MOV [REMOVE_FG], R8					; remove a imagem do foreground
	MOV [SELECIONA_BG], R5				; seleciona a imagem de início no cenário de fundo
	MOV [TERMINA_MIDIAS], R10			; termina a reprodução do som/vídeo
controlo_teclado:
	MOV R10, [evento_tecla_solta]		; aguarda que o evento tecla solta seja chamado
	MOV R9, [estado_do_jogo]			; obtém o estado do jogo
	CMP R10, R1							; verifica se a tecla premida foi 'D'
	JZ controlo_tecla_pausar			; se for, tenta pausa o jogo
	CMP R9, JOGO_EM_PAUSA				; verifica se o jogo está em pausa
	JZ controlo_teclado					; se estiver, ignora as restantes teclas
	CMP R10, R0							; verifica se a tecla premida foi 'C'
	JZ controlo_tecla_comecar			; se for, tenta inicializar o jogo
	CMP R10, R2							; verifica se a tecla premida foi 'E'
	JZ controlo_tecla_parar				; se for, tenta parar o jogo
	JMP controlo_teclado
controlo_tecla_comecar:
	CMP R9, JOGO_ATIVO					; verifica se o jogo está ativo
	JZ controlo_teclado					; se estiver, não faz nada
	MOV R9, JOGO_ATIVO
	MOV [estado_do_jogo], R9			; define o estado do jogo como ativo
	MOV [SELECIONA_BG], R4				; seleciona o cenário de fundo
	MOV [REPRODUZ_MIDIA_LOOP], R3		; inicia a reprodução da música de fundo em loop
	MOV [REMOVE_FG], R8					; remove o cenário frontal
	MOV [evento_comecar], R6			; chama o evento começar (desbloqueia os respetivos processos)
	CALL atualiza_energia				; atualiza o valor da energia na memória e no display
	JMP controlo_teclado				; reinicia
controlo_tecla_pausar:
	CMP R9, JOGO_PARADO					; verifica se o jogo está parado
	JZ controlo_teclado					; se estiver, não faz nada
	CMP R9, JOGO_EM_PAUSA				; verifica se o jogo está em pausa
	JZ controlo_resumir					; se estiver, recomeça o jogo
	MOV R9, JOGO_EM_PAUSA
	MOV [estado_do_jogo], R9			; define o estado do jogo como em pausa
	MOV [SELECIONA_FG], R6				; seleciona a imagem de pausa no foreground
	MOV [PAUSA_MIDIAS], R8				; pausa todos os sons/vídeos em reprodução
	JMP controlo_teclado
controlo_resumir:
	MOV R9, JOGO_ATIVO
	MOV [estado_do_jogo], R9			; define o estado do jogo como ativo
	MOV [RETOMA_MIDIAS], R8				; retoma todos os sons/vídeos em pausa
	MOV [REMOVE_FG], R8					; remove a imagem do foreground
	MOV [evento_comecar], R6			; ativa o jogo (desbloqueia os respetivos processos)
	JMP controlo_teclado				; reinicia
controlo_tecla_parar:
	CMP R9, JOGO_ATIVO					; verifica se o jogo já está ativo
	JNZ controlo_teclado				; se não estiver, não faz nada
	MOV R9, JOGO_PARADO
	MOV [estado_do_jogo], R9			; define o estado do jogo como parado
	MOV [APAGA_ECRAS], R8				; apaga todos os pixels já desenhados (o valor de R0 não é relevante)
	MOV [REMOVE_FG], R8					; remove a imagem do cenário de fundo
	MOV [TERMINA_MIDIAS], R8			; pára a reprodução de todos os sons/vídeos
	MOV [SELECIONA_BG], R7				; seleciona a imagem do cenário de fundo
	JMP controlo_teclado				; reinicia

; **************************************************************************************
; PROCESSO TECLADO - Recebe inputs do teclado e chama eventos relacionados
; Registos reservados: R11 - linha da tecla premida
;                      R10 - coluna da tecla premida
;                      R9 - tecla premida
; **************************************************************************************
PROCESS pilha_teclado
processo_teclado:
	YIELD
	CALL testa_linhas				; testa todas as linhas do teclado
    CMP R11, 0						; verifica se alguma tecla foi premida
    JZ processo_teclado				; se nenhuma foi premida, repete
	CALL obter_tecla				; obtém o valor da tecla premida
teclado_ciclo:
	MOV [evento_tecla_premida], R9	; chama o evento tecla premida, escrevendo o valor da tecla
	YIELD
	MOV R8, R10						; cópia da coluna da tecla premida
	CALL testa_linha				; testa a linha da tecla premida
	CMP R10, R8						; se a tecla ainda estiver a ser premida
	JZ teclado_ciclo				; repete
	MOV [evento_tecla_solta], R9	; chama o evento tecla solta, escrevendo o valor da tecla
	JMP processo_teclado

; ***************************************************************************************
; TECLA - Obtém o valor da tecla na linha e coluna indicadas.
; Argumentos: R11 - linha
;             R10 - coluna
; Retorna:    R9 - valor da tecla
; ***************************************************************************************
obter_tecla:
	PUSH R10
	PUSH R11
	MOV R9, 0					; inicializa o valor a 0
tecla_linha_ciclo:
	SHR R11, 1					; avança a linha
	JZ tecla_coluna_ciclo		; se não houver mais linhas, pula para as colunas
	ADD R9, 4					; adiciona 4 ao valor
	JMP tecla_linha_ciclo		; repete até acabarem as linhas
tecla_coluna_ciclo:
	SHR R10, 1					; avança a coluna
	JZ tecla_fim				; se não houver mais colunas, termina
	ADD R9, 1					; adiciona 1 ao valor da tecla premida
	JMP tecla_coluna_ciclo		; repete até acabarem as colunas
tecla_fim:
	POP R11
	POP R10
	RET

; ***************************************************************************************
; TESTA_LINHAS - Faz uma leitura às linhas e retorna a linha e a coluna da tecla premida
; Retorna: R11 - linha da tecla premida (1, 2, 4 ou 8), ou 0
;          R10 - coluna da tecla premida (1, 2, 4 ou 8), ou 0
; ***************************************************************************************
testa_linhas:
    MOV R11, 8				; testa quarta linha
testa_linhas_ciclo:
    CALL testa_linha		; testa a linha (R11) e obtém a coluna (R10)
    CMP R10, 0				; se alguma tecla foi premida (R10 != 0)
    JNZ testa_linhas_fim	; termina
    SHR R11, 1				; linha seguinte
    CMP R11, 0				; se houver mais linhas para testar (R11 != 0)
    JNZ testa_linhas_ciclo	; testa a linha
testa_linhas_fim:
    RET

; ***************************************************************************************
; TESTA_LINHA - Faz uma leitura a uma linha do teclado e retorna a coluna da tecla premida
; Argumentos: R11 - linha a testar (1, 2, 4 ou 8)
; Retorna: 	  R10 - coluna da tecla premida (1, 2, 4, ou 8), ou 0
; ***************************************************************************************
testa_linha:
	PUSH R0
	PUSH R1
	PUSH R2
	MOV R0, TEC_LIN				; endereço do periférico das linhas
	MOV R1, TEC_COL				; endereço do periférico das colunas
	MOV R2, MASCARA				; para isolar os 4 bits de menor peso, ao ler as colunas do teclado
	MOVB [R0], R11				; escrever no periférico de saída (linhas)
	MOVB R10, [R1]				; ler do periférico de entrada (colunas)
	AND R10, R2					; elimina bits para além dos bits 0-3
	POP	R2
	POP	R1
	POP	R0
	RET

; **************************************************************************************
; PROCESSO ROVER - Controla a movimentação do rover através das teclas '0' e '2'
; Registos reservados: R11 - linha de referência do rover
;                      R10 - coluna de referência do rover
;                      R8 - tabela que define o rover
; **************************************************************************************
PROCESS pilha_rover
processo_movimento_rover:
	MOV R0, [evento_comecar]		; bloqueia até o jogo ser inicializado
	MOV R8, rover					; tabela que define o rover
	MOV R10, N_COLUNAS				; número de colunas do ecrã
	SHR R10, 1						; coluna central
	MOV R7, [R8]					; largura do rover
	SHR R7, 1						; metade da largura do rover
	SUB R10, R7						; (coluna de referência do rover) = (coluna do meio) - (metade da largura do rover)
	MOV R7, ATRASO_ROVER			; atraso na movimentação do rover
	MOV R11, LINHA_ROVER			; linha de referência do rover
    CALL desenha_boneco				; desenha o rover
movimento_rover_ciclo:
	MOV [coluna_rover], R10			; atualiza a coluna de referência do rover na memória
	MOV R0, [evento_tecla_premida]	; aguarda que o evento tecla premida seja chamado
	MOV R1, [estado_do_jogo]		; obtém o estado do jogo
	CMP R1, JOGO_EM_PAUSA			; verifica se o jogo está em pausa
	JZ  movimento_rover_pausa		; pausa o processo
	CMP R1, JOGO_PARADO				; verifica se o jogo está parado
	JZ processo_movimento_rover		; reinicia e bloqueia o processo
	CMP R0, TECLA_0					; se a tecla premida for 0
	JZ movimento_rover_esquerda		; move o rover para a esquerda
	CMP R0, TECLA_2					; se a tecla premida for 2
	JZ movimento_rover_direita		; move o rover para a direita
	JMP movimento_rover_ciclo
movimento_rover_esquerda:
	MOV R7, -1						; distância a percorrer (negativa = para a esquerda)
	JMP movimento_rover_fim
movimento_rover_direita:
	MOV R7, 1						; distância a percorrer (positiva = para a direita)
movimento_rover_fim:
	CALL move_rover					; move o rover
	MOV R9, ATRASO_ROVER
	CALL atraso						; aplica o atraso
    JMP movimento_rover_ciclo
movimento_rover_pausa:
	MOV R7, [evento_comecar]		; bloqueia até o jogo ser recomeçado
	JMP movimento_rover_ciclo

; ************************************************************************
; MOVE_ROVER - Move o rover (horizontalmente)
; Argumentos: R11 - linha de referência do rover
;             R10 - coluna de referência do rover
;             R8 - tabela que define o rover
;             R7 - distância a percorrer
; Retorna:    R10 - coluna atualizada
;             R7 - distância percorrida, ou 0 se chegou a um dos limites do ecrã
; ************************************************************************
move_rover:
	CALL testa_limites_horizontal			; testa os limites do rover (define R7 a 0 se o rover chegou ao limite)
	CMP R7, 0								; verifica se a distância a percorrer é nula
	JZ move_rover_fim						; se for, termina a rotina
	CALL move_horizontal					; move o rover
move_rover_fim:
	RET


; **************************************************************************************
; PROCESSO ENERGIA - Controla a diminuição de energia causada pelo funcionamento do rover
; Registos reservados: R11 - energia do rover
;                      R9 - custo em energia do funcionamento do rover
; **************************************************************************************
PROCESS pilha_energia
processo_energia_rover:
	MOV R9, ENERGIA_FUNCIONAMENTO	; custo em energia do funcionamento do rover
energia_rover_inicio:
	MOV R0, [evento_comecar]		; bloqueia o processo até o jogo ser inicializado
	MOV R11, MAX_ENERGIA			; energia do rover
energia_rover_ciclo:
	MOV R0, [evento_energia]		; bloqueia o processo até o evento energia ser chamado
	MOV R0, [estado_do_jogo]		; estado_do_jogo de jogo
	CMP R0, JOGO_EM_PAUSA			; verifica se o jogo está em pausa
	JZ energia_rover_pausa			; pausa o processo
	CMP R0, JOGO_PARADO			; verifica se o jogo está parado
	JZ energia_rover_inicio			; reinicia e bloqueia o processo
	CALL adiciona_energia			; atualiza a energia do rover
	JMP energia_rover_ciclo			; repete
energia_rover_pausa:
	MOV R0, [evento_comecar]		; bloqueia o processo até o jogo ser recomeçado
	JMP energia_rover_ciclo

; **************************************************************************************
; PROCESSO MÍSSIL - Controla a criação do míssil através da tecla '1',
;                assim como o seu progresso no espaço
; Registos reservados: R11 - linha de referência do míssil
;                      R10 - coluna de referência do míssil
;                      R9 - movimentos restantes do míssil até se desintegrar
;                      R8 - tabela que define o míssil
; **************************************************************************************
PROCESS pilha_missil
processo_missil:
	MOV R0, [evento_comecar]		; bloqueia o processo até o jogo ser inicializado/recomeçado
missil_espera:
	MOV R8, [evento_tecla_solta]	; aguarda que o evento tecla solta seja chamado
	MOV R0, [estado_do_jogo]		; obtém o estado do jogo
	CMP R0, JOGO_ATIVO				; verifica se o jogo está ativo
	JNZ processo_missil				; se não estiver, reinicia e bloqueia o processo
	CMP R8, TECLA_1					; verifica se a tecla premida foi a tecla de disparo (1)
	JNZ missil_espera				; se não for, bloqueia outra vez
	CALL cria_missil				; cria o míssil
missil_ciclo:
	MOV R0, [evento_missil]			; aguarda que o evento míssil seja chamado
	MOV R0, [estado_do_jogo]		; obtém o estado do jogo
	CMP R0, JOGO_EM_PAUSA			; verifica se o jogo está em pausa
	JZ missil_pausa					; se estiver, pausa o processo
	CMP R0, JOGO_PARADO				; verifica se o jogo está parado
	JZ processo_missil				; se estiver, reinicia e bloqueia o processo
	CALL avanca_missil				; avança o míssil
	CMP R9, 0						; verifica se o míssil tem movimentos restantes
	JZ missil_espera				; se não tiver, poderá ser criado um novo
	JMP missil_ciclo				; repete
missil_pausa:
	MOV R0, [evento_comecar]		; bloqueia até o jogo ser recomeçado
	JMP missil_ciclo

; ***************************************************************************************
; AVANCA_MISSIL - Avança o míssil, ou elimina-o se caso haja colisão ou este
;              chegue ao seu limite de movimentos
; Argumentos: R11 - linha do míssil
;             R10 - coluna do míssil
;             R9 - movimentos restantes do míssil até se desintegrar
;             R8 - tabela que define o míssil
; Retorna:    R11 - linha do míssil atualizada
;             R9 - movimentos restantes até desaparecer
; ***************************************************************************************
avanca_missil:
	PUSH R0
	CALL apaga_boneco			; apaga o míssil
	MOV R0, [colisao_missil]	; obtém o valor booleano da colisão do míssil
	CMP R0, VERDADEIRO			; verifica se míssil colidiu com algum meteoro
	JZ avanca_missil_colisao
	SUB R11, 1					; avança 1 linha
	SUB R9, 1					; menos 1 movimento até desaparecer
	JZ elimina_missil			; se o míssil não tiver mais movimentos para fazer, termina a rotina
	CALL desenha_boneco			; desenha o míssil
	MOV [linha_missil], R11		; atualiza a linha de referência do míssil na memória
	JMP avanca_missil_fim		; termina a rotina
avanca_missil_colisao:
	MOV R0, FALSO
	MOV R9, 0					; o número de movimentos restantes é agora 0 (o míssil deve desintegrar-se)
	MOV [colisao_missil], R0	; redefine o valor da colisão como falso
elimina_missil:
	MOV R0, INDEFINIDO
	MOV [linha_missil], R0		; atualiza a linha do míssil na memória
	MOV [coluna_missil], R0		; atualiza a coluna do míssil na memória
avanca_missil_fim:
	POP R0
	RET

; ***************************************************************************************
; CRIA_MISSIL - Cria um novo míssil no topo do rover
; Retorna: R11 - linha de referência do míssil
;          R10 - coluna de referência do míssil
;          R9 - movimentos restantes até desaparecer
;          R8 - tabela que define o míssil
; ***************************************************************************************
cria_missil:
	MOV R11, LINHA_ROVER			; linha de referência do rover
	SUB R11, 1						; linha de referência do míssil (linha do rover - 1)
	MOV R10, [coluna_rover]			; obtém a coluna de referência do rover
	MOV R9, [rover]					; largura do rover
	SHR R9, 1						; metade da largura do rover
	ADD R10, R9						; coluna de referência do míssil (linha do rover + metade da largura do rover)
	MOV R8, missil					; obtém a tabela que define o míssil
	CALL desenha_boneco				; desenha o míssil
	MOV R9, ENERGIA_DISPARO			; custo em energia por cada disparo (-5)
	CALL adiciona_energia			; atualiza a energia do rover
	MOV R9, SOM_ROVER_DISPARO
	MOV [REPRODUZ_MIDIA], R9		; reproduz o som de disparo do rover
	MOV R9, ALCANCE_MISSIL			; número de movimentos do rover até desaparecer
	MOV [linha_missil], R11			; atualiza a linha de referência do míssil na memória
	MOV [coluna_missil], R10		; atualiza a coluna de referência do míssil na memória
	RET

; **************************************************************************************
; PROCESSO METEORO - Controla a criação e progressão do meteoro no espaço, e
;                 testa possíveis colisões entre este e o rover/míssil
; Registos reservados: R11 - linha do meteoro (também usado para o atraso)
;                      R10 - coluna do meteoro
;                      R9 - tabela com as evoluções do meteoro
;                      R8 - tabela que define o meteoro
;                      R7 - nível do meteoro
;                      R6 - movimentos restantes até a próxima evolução
;                      R5 - indica se o meteoro é bom ou mau (0 = bom, 1 = mau)
;                      R4 - ecrã onde o meteoro deve ser escrito
;                      R1 - número do processo * 2 (usado como índice nas tabelas)
;                      R0 - número do processo
; ***************************************************************************************
PROCESS pilhas_meteoro
processo_meteoro:
	MOV R1, R0						; cópia do número do processo
	SHL R1, 1						; número do processo * 2 (usado como índice nas tabelas)
	MOV R2, pilhas_meteoro			; tabela com as pilhas para cada instância do processo
	MOV SP, [R2+R1]					; atualiza o stack pointer da instância do processo
	MOV R4, R0						; cópia do número do processo
	ADD R4, 1						; número do ecrã
meteoro_atraso_inicio:
	MOV R3, [evento_comecar]		; bloqueia o processo até o jogo ser inicializado
	MOV R11, ATRASO_METEOROS		; número de movimentos necessários até que cada meteoro nasca
	MUL R11, R0						; multiplica pelo número do processo
meteoro_atraso:
	MOV R3, [evento_meteoro]		; aguarda que o evento meteoro seja chamado
	MOV R3, [estado_do_jogo]		; obtém o estado do jogo
	CMP R3, JOGO_PARADO				; verifica se o jogo está parado
	JZ meteoro_atraso_inicio		; se estiver, reinicia e bloqueia o processo
	CMP R3, JOGO_EM_PAUSA			; verifica se o jogo está em pausa
	JZ meteoro_atraso_pausa			; se estiver, pausa o processo
	SUB R11, 1						; menos um movimento até o meteoro ser criado
	JGT meteoro_atraso				; se ainda houver movimentos restantes, repete
	CALL cria_meteoro				; cria o meteoro
meteoro_ciclo:
	MOV R3, [evento_meteoro]		; aguarda que o evento do meteoro seja chamado
	MOV R3, [estado_do_jogo]		; obtém o estado do jogo
	CMP R3, JOGO_PARADO				; verifica se o jogo está parado
	JZ meteoro_atraso_inicio		; se estiver, reinicia e bloqueia o processo
	CMP R3, JOGO_EM_PAUSA			; verifica se o jogo está em pausa
	JZ meteoro_pausa				; se estiver, pausa o processo
	CALL atualiza_meteoro			; atualiza o meteoro
	JMP meteoro_ciclo
meteoro_atraso_pausa:
	MOV R3, [evento_comecar]		; bloqueia o processo até o jogo ser recomeçado
	JMP meteoro_atraso
meteoro_pausa:
	MOV R3, [evento_comecar]		; bloqueia o processo até o jogo ser recomeçado
	JMP meteoro_ciclo

; ***************************************************************************************
; ATUALIZA_METEORO - Avança o meteoro
; Argumentos: R11 - linha de referência do meteoro
;             R10 - coluna de referência do meteoro
;             R9 - tabela com as evoluções do meteoro
;             R8 - tabela que define o meteoro
;             R7 - nível do meteoro
;             R6 - movimentos restantes até à próxima evolução
;             R5 - tipo do meteoro é bom ou mau
;             R4 - número do ecrã em que o meteoro deve ser desenhado
; Retorna:    R11 - linha atualizada
;             R8 - tabela que define o meteoro
;             R7 - nível do meteoro, ou:
;                  -1, caso haja colisão meteoro bom/rover
;                  -2, caso haja colisão meteoro mau/rover
;                  -3, caso haja colisão meteoro bom/míssil
;                  -4, caso haja colisão meteoro mau/míssil
;             R6 - movimentos restantes até à próxima evolução
; ***************************************************************************************
atualiza_meteoro:
	PUSH R0
	CALL apaga_boneco_ecra			; apaga o meteoro na posição antiga
	CALL testa_colisao_meteoro		; testa colisões com o rover e o míssil
	CMP R7, -1						; verifica se o meteoro bom colidiu com o rover
	JZ colisao_met_bom_rover
	CMP R7, -2						; verifica se o meteoro mau colidiu com o rover
	JZ colisao_met_mau_rover
	CMP R7, -3						; verifica se o meteoro bom colidiu com o míssil
	JZ colisao_met_bom_missil
	CMP R7, -4						; verifica se o meteoro mau colidiu com o míssil
	JZ colisao_met_mau_missil
	ADD R11, 1						; atualiza a linha de referência do meteoro
	MOV R0, N_LINHAS				; número de linhas do ecrã
	CMP R11, R0						; verifica se o meteoro ultrapassou o limite do ecrã na sua totalidade
	JGE reinicia_meteoro			; se ultrapassou, cria um novo
	MOV R0, MET_NIVEL_MAX			; nível máximo que o meteoro pode alcançar
	CMP R7, R0						; verifica se o meteoro já alcançou o nível máximo (5)
	JZ avanca_meteoro_2				; se já tiver alcançado o nível 5, não pode evoluir mais
	SUB R6, 1						; menos um movimento até à próxima evolução
	JNZ avanca_meteoro_2			; se ainda houver movimentos restantes, não evolui
	ADD R7, 1						; aumenta o nível do meteoro em 1
	MOV R6, ATRASO_EVOLUCAO			; reinicia os movimentos restantes até à próxima evolução
	ADD R9, 2						; seleciona a tabela da próxima evolução do meteoro
	MOV R8, [R9]					; atualiza a tabela que define o meteoro
	JMP avanca_meteoro_2
colisao_met_bom_rover:
	MOV R0, SOM_ABSORCAO_ENERGIA	; número do som de colisão do rover com o meteoro bom
	MOV R9, ENERGIA_METEORO_BOM		; ganho de energia por colidir com um meteoro bom
	MOV [REPRODUZ_MIDIA], R0		; toca o som
	CALL adiciona_energia			; atualiza a energia do rover
	JMP reinicia_meteoro			; cria um novo meteoro e termina a rotina
colisao_met_mau_rover:
	MOV R0, SOM_ROVER_DESTRUIDO
	MOV R1, IMG_ROVER_EXPLODIU
	MOV R2, JOGO_PARADO
	MOV [TERMINA_MIDIAS], R0		; pára a reprodução de todos os sons/vídeos
	MOV [REPRODUZ_MIDIA], R0		; reproduz o som de explosão do meteoro
	MOV [SELECIONA_BG], R1			; seleciona a imagem de jogo terminado devido a colisão com o rover
	MOV [estado_do_jogo], R2		; define o estado do jogo como parado
	MOV [APAGA_ECRAS], R0			; apaga os pixels de todos os ecrãs
	JMP meteoro_atraso_inicio
colisao_met_mau_missil:
	MOV R9, ENERGIA_NAVE_DESTRUIDA	; ganho de energia por destruir uma nave inimiga
	CALL adiciona_energia			; atualiza a energia do rover
colisao_met_bom_missil:
	MOV R0, SOM_METEORO_EXPLOSAO
	MOV R8, explosao				; tabela que define a explosão
	MOV [REPRODUZ_MIDIA], R0		; reproduz o som
	CALL desenha_boneco_ecra		; desenha a explosão
	MOV R3, [evento_meteoro]		; aguarda que o evento meteoro seja chamado
	CALL apaga_boneco_ecra			; apaga a explosão
reinicia_meteoro:
	CALL cria_meteoro				; cria um novo meteoro
	JMP avanca_meteoro_fim			; termina a rotina
avanca_meteoro_2:
	CALL desenha_boneco_ecra		; redesenha o meteoro na posição atualizada
avanca_meteoro_fim:
	POP R0
	RET

; ***************************************************************************************
; CRIA_METEORO - Cria um novo meteoro mau ou bom, nível 1, na primeira linha e numa coluna aleatória.
; Retorna: R11 - linha do meteoro
;          R10 - coluna do meteoro
;          R9 - tabela com as evoluções do meteoro
;          R8 - tabela que define o meteoro
;          R7 - nível do meteoro
;          R6 - movimentos restantes até à próxima evolução
;          R5 - indica se o meteoro é bom ou mau
;          R4 - número do ecrã em que o meteoro deve ser desenhado
; ***************************************************************************************
cria_meteoro:
	MOV R6, ATRASO_EVOLUCAO				; movimentos restantes até à próxima evolução
	MOV R7, 1							; nível inicial do meteoro
	MOV R11, 0							; linha inicial de referência do meteoro
	CALL gera_num_aleatorio				; gera um número aleatório
	SHL R9, 3							; multiplica por 8
	MOV R10, R9							; coluna de referência do meteoro
	CALL gera_num_aleatorio				; gera outro número aleatório
	CMP R9, 1							; verifica se o número é superior a 1
	JLE cria_meteoro_bom				; se for superior, o meteoro é mau, se não for, é bom
cria_meteoro_mau:
	MOV R9, evolucoes_meteoro_mau		; obtém a tabela de evoluções do meteoro mau
	MOV R5, METEORO_MAU					; indicador de meteoro mau
	JMP cria_meteoro_fim
cria_meteoro_bom:
	MOV R9, evolucoes_meteoro_bom		; obtém a tabela de evoluções do meteoro mau
	MOV R5, METEORO_BOM					; indicador de meteoro bom
cria_meteoro_fim:
	MOV R8, [R9]						; obtém a tabela da evolução atual
	CALL desenha_boneco_ecra			; desenha o meteoro
	RET

; ***************************************************************************************
; TESTA_COLISAO_METEORO - Testa colisão do meteoro
; Argumentos: R11 - linha de referência do meteoro
;             R10 - coluna de referência do meteoro
;             R9 - tabela com as evoluções do meteoro
;             R8 - tabela que define o meteoro
;             R7 - nível do meteoro
;             R5 - tipo do meteoro é bom ou mau
; Retorna:    R8 - tabela que define o meteoro
;             R7 - nível do meteoro (inalterado), ou:
;                  -1, caso haja colisão meteoro bom/rover
;                  -2, caso haja colisão meteoro mau/rover
;                  -3, caso haja colisão meteoro bom/míssil
;                  -4, caso haja colisão meteoro mau/míssil
; ***************************************************************************************
testa_colisao_meteoro:
	PUSH R0
	PUSH R1
	PUSH R9
	PUSH R11
	MOV R0, [R8]						; obtém a largura do meteoro
	MOV R9, R10							; cópia do limite esquerdo do meteoro
	ADD R9, R0							; calcula o limite direito do meteoro
	SUB R9, 1							; calcula o limite direito do meteoro
	MOV R0, [R8+2]						; obtém a altura do meteoro
	ADD R11, R0							; calcula o limite inferio do meteoro
	SUB R11, 1							; calcula o limite inferio do meteoro
testa_colisao_meteoro_rover:
	MOV R0, LINHA_ROVER					; limite superior do rover
	CMP R11, R0							; compara o limite inferior do meteoro com o limite superior do rover
	JLT testa_colisao_meteoro_missil	; se o meteoro se encontrar acima do rover, não há colisão
	MOV R0, [coluna_rover]				; limite esquerdo do rover
	CMP R9, R0							; compara o limite direito do meteoro com o limite esquerdo do rover
	JLT testa_colisao_meteoro_missil	; se o meteoro se encontrar à esquerda do rover, não há colisão
	MOV R1, [rover]						; largura do rover
	ADD R0, R1							; calcula o limite direito do rover
	SUB R0, 1							; calcula o limite direito do rover
	CMP R10, R0							; compara o limite esquerdo do meteoro com o limite direito do rover
	JGT testa_colisao_meteoro_missil	; se o meteoro se encontrar à direita do rover, não há colisão
	MOV R7, COLISAO_MET_BOM_ROVER		; identificador da colisão
	SUB R7, R5							; identificador da colisão
	JMP testa_colisao_meteoro_fim		; termina a rotina
testa_colisao_meteoro_missil:
	MOV R0, [colisao_missil]			; obtém o valor booleano que indica se o míssil colidiu com algum meteoro
	CMP R0, VERDADEIRO					; verifica se o míssil já colidiu com algum meteoro
	JZ testa_colisao_meteoro_fim		; se já colidiu, termina a rotina
	MOV R0, [linha_missil]				; linha do míssil
	CMP R11, R0							; compara o limite inferior do meteoro com a linha do míssil
	JLT testa_colisao_meteoro_fim		; se o meteoro se encontrar acima do míssil, não há colisão
	MOV R0, [coluna_missil]				; coluna do míssil
	CMP R10, R0							; compara o limite esquerdo do meteoro com a coluna do míssil
	JGT testa_colisao_meteoro_fim		; se o meteoro se encontrar à direita do míssil, não há colisão
	CMP R9, R0							; compara o limite direito do meteoro com a coluna do míssil
	JLT testa_colisao_meteoro_fim		; se o meteoro se encontrar à esquerda do míssil, não há colisão
	MOV R0, VERDADEIRO
	MOV [colisao_missil], R0			; indica ao processo míssil que houve colisão com um meteoro
	MOV R7, COLISAO_MET_BOM_MISSIL		; identificador da colisão
	SUB R7, R5							; identificador da colisão
testa_colisao_meteoro_fim:
	POP R11
	POP R9
	POP R1
	POP R0
	RET

;  **********************
; **** ROTINAS GERAIS ****
;  **********************

; ***************************************************************************************
; GERA_NUM_ALEATORIO - Gera um número aleatório entre 0 e 7
; Retorna: R9 - Número gerado
; ***************************************************************************************
gera_num_aleatorio:
    PUSH R0
    PUSH R1
    MOV R0, MASCARA		; máscara 0-3 bits
	SHL R0, 4			; máscara 4-7 bits
    MOV R1, TEC_COL		; endereço do periférico que liga às colunas do teclado
    MOV R9, [R1]		; ler do periférico de entrada (PIN)
    AND R9, R0			; elimina bits para além dos bits 4-7
    SHR R9, 5			; R9 é agora um número aleatório entre 0 e 7
    POP R1
    POP R0
    RET

; ***************************************************************************************
; ADICIONA_ENERGIA - Adiciona energia ao rover (atualiza na memória e no display)
; Argumentos: R9 - valor a adicionar (ou subtrair, se for negativo)
; ***************************************************************************************
adiciona_energia:
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R11
	MOV R0, MAX_ENERGIA						; máximo de energia que o rover pode armazenar
	MOV R11, [energia_rover]				; energia do rover
	ADD R11, R9								; energia do rover após a atualização
	CMP R11, R0								; verifica se a energia do rover ultrapassou o limite superior
	JGT adiciona_energia_max				; se sim, corrige o valor (não deixa que o limite seja ultrapassado)
	CMP R11, 0								; verifica se a energia do rover chegou a 0
	JLE adiciona_energia_min				; se sim, pára o jogo
	JMP adiciona_energia_fim
adiciona_energia_max:
	MOV R11, R0								; define o valor da energia como o máximo possível
	JMP adiciona_energia_fim
adiciona_energia_min:
	MOV R0, JOGO_PARADO
	MOV R1, IMG_ROVER_SEM_ENERGIA
	MOV R2, SOM_ROVER_SEM_ENERGIA
	MOV [estado_do_jogo], R0				; define o estado do jogo como parado
	MOV [SELECIONA_BG], R1					; seleciona o cenário de fundo
	MOV [TERMINA_MIDIAS], R2				; termina todos os sons/vídeos
	MOV [REPRODUZ_MIDIA], R2				; reproduz o som
	MOV [APAGA_ECRAS], R2					; apaga os pixels em todos os ecrãs
	MOV R11, 0								; o valor da energia do rover em hexadecimal deverá ser 0
adiciona_energia_fim:
	CALL atualiza_energia					; atualiza a energia
	POP R11
	POP R2
	POP R1
	POP R0
	RET

; ***************************************************************************************
; ATUALIZA_ENERGIA - Define o valor da energia na memória e no display
; Argumentos: R11 - valor a definir, em hexadecimal
; ***************************************************************************************
atualiza_energia:
	PUSH R10
	CALL converte_decimal			; converte o valor para decimal
	MOV [DISPLAY], R10				; atualiza o valor da energia no display
	MOV [energia_rover], R11		; atualiza o valor da energia na memória
	POP R10
	RET

; ***************************************************************************************
; CONVERTE_DECIMAL - Converte hex em decimal
; Argumentos: R11 - numero (em hexadecimal)
; Retorna:    R10 - numero atualizado (em decimal)
; ***************************************************************************************
converte_decimal:
    PUSH R1
    PUSH R2
    PUSH R3
    PUSH R11
    MOV R10, R11				; cópia do número em hexadecimal (onde será guardado o resultado)
    MOV R1, FATOR				; fator (1000 em decimal)
    MOV R2, DIVISOR_10			; divisor (10 em decimal, divide o fator)
converte_ciclo:
    MOD R11, R1					; R4 contém o número a converter
    DIV R1, R2					; atualiza o fator de divisão
    MOV R3, R11					; guarda o resto da divisão
    DIV R3, R1					; mais um digito do valor decimal
    SHL R10, 4					; desloca para dar espaço ao novo dígito
    OR R10, R3					; vai compondo o resultado
    CMP R1, R2					; ver se o número já está convertido (fator = 1)
    JGE converte_ciclo			; se ainda não estiver, repete
converte_decimal_fim:
    POP R11
    POP R3
    POP R2
    POP R1
    RET

; ***************************************************************************************
; TESTA_LIMITES_HORIZONTAL - Testa se o boneco chegou aos limites do ecrã na sua largura
;                           e nesse caso impede o movimento (força R7 a 0)
; Argumentos:	R10 - coluna em que o boneco está
;			    R7 - sentido de movimento do boneco
;                 (negativo = esquerda, positivo = direita)
;               R6 - largura do boneco
; Retorna: 	    R7 - 0 se já tiver chegado ao limite, inalterado caso contrário
; ***************************************************************************************
testa_limites_horizontal:
	PUSH R0
	PUSH R6
	CMP R7, 0					; se o movimento for para a direita (R7 > 0)
	JGE testa_limite_direito	; testa para a direita (caso contrário testa para a esquerda)
testa_limite_esquerdo:
	CMP R10, 0					; se o pixel de referência do boneco não estiver na coluna mínima
	JNZ testa_limites_fim		; não impede o movimento
	JMP impede_movimento		; caso contrário, impede o movimento
testa_limite_direito:
	MOV R0, N_COLUNAS			; número de colunas do ecrã
	ADD R6, R10					; calcula o pixel mais à direita do boneco
	SUB R6, 1					; calcula o pixel mais à direita do boneco
	CMP R6, R0					; se o pixel mais à direita do boneco não estiver na coluna máxima
	JNZ testa_limites_fim		; não impede o movimento (caso contrário, impede o movimento)
impede_movimento:
	MOV R7, 0					; impede o movimento forçando R7 a 0
testa_limites_fim:
	POP R6
	POP R0
	RET

; ***************************************************************************************
; MOVE_VERTICAL - Simula movimento vertical
; Argumentos: R11 - linha de referência do boneco
;             R10 - coluna de referência do boneco
;             R8 - tabela que define o boneco
;             R7 - distância a percorrer (negativa para cima, positiva para baixo)
; Retorna:    R10 - linha de referência do boneco atualizada
; ***************************************************************************************
move_vertical:
	CALL apaga_boneco			; apaga o boneco
	ADD R11, R7					; atualiza coluna
	CALL desenha_boneco			; desenha o boneco na nova posição
	RET

; ***************************************************************************************
; MOVE_HORIZONTAL - Simula movimento horizontal
; Argumentos: R11 - linha de referência do boneco
;             R10 - coluna de referência do boneco
;             R8 - tabela que define o boneco
;             R7 - distância a percorrer (negativa para a esquerda, positiva para a direita)
; Retorna:    R10 - coluna de referência do boneco atualizada
; ***************************************************************************************
move_horizontal:
	CALL apaga_boneco			; apaga o boneco
	ADD R10, R7					; atualiza coluna
	CALL desenha_boneco			; desenha o boneco na nova posição
	RET

; ***************************************************************************************
; DESENHA_BONECO_ECRA - Desenha um boneco na linha, coluna e ecrã indicados
;			         com a forma e cor definidas na tabela indicada.
; Argumentos:   R11 - linha de referência do boneco
;               R10 - coluna de referência do boneco
;               R8 - tabela que define o boneco
;               R4 - ecrã
; ***************************************************************************************
desenha_boneco_ecra:
	PUSH R0
	MOV R0, [SELECIONA_ECRA]	; obtém o ecrã selecionado
	MOV [SELECIONA_ECRA], R4	; seleciona o ecrã indicado
	CALL desenha_boneco			; desenha o boneco no ecrã indicado
	MOV [SELECIONA_ECRA], R0	; seleciona o ecrã previamente selecionado
	POP R0
	RET

; ***************************************************************************************
; APAGA_BONECO_ECRA - Apaga um boneco na linha, coluna e ecrã indicados
;			       com a forma definida na tabela indicada.
; Argumentos:   R11 - linha de referência do boneco
;               R10 - coluna de referência do boneco
;               R8 - tabela que define o boneco
;               R4 - ecrã
; ***************************************************************************************
apaga_boneco_ecra:
	PUSH R0
	MOV R0, [SELECIONA_ECRA]	; obtém o ecrã selecionado
	MOV [SELECIONA_ECRA], R4	; seleciona o ecrã indicado
	CALL apaga_boneco			; apaga o boneco no ecrã indicado
	MOV [SELECIONA_ECRA], R0	; seleciona o ecrã previamente selecionado
	POP R0
	RET

; ***************************************************************************************
; DESENHA_BONECO - Desenha um boneco na linha e coluna indicadas
;			    com a forma e cor definidas na tabela indicada.
; Argumentos:   R11 - linha de referência do boneco
;               R10 - coluna de referência do boneco
;               R8 - tabela que define o boneco
; ***************************************************************************************
desenha_boneco:
	PUSH R11
	PUSH R10
	PUSH R9
    PUSH R8
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R0, [R8]			; obtém a largura
	ADD R8, 2				; próximo dado na tabela
	MOV R1, [R8]			; obtém a altura
	MOV R2, R10     	    ; define a coluna inicial
	MOV R3, R0				; define a largura inicial
desenha_pixels:
	ADD R8, 2	    		; próximo dado na tabela
	MOV	R9, [R8]			; obtém a cor do pixel
	CALL escreve_pixel		; escreve um pixel na linha R11 e coluna R10 usando a cor R9
    ADD R10, 1				; próxima coluna
    SUB R0, 1				; menos uma coluna para tratar
    JNZ desenha_pixels		; continua até percorrer toda a largura do boneco
	MOV R10, R2				; redefinir a coluna
	MOV R0, R3				; redefinir a largura
	ADD R11, 1				; próxima linha
	MOV R9, N_LINHAS		; número de linhas
	CMP R11, R9				; verifica se a linha está fora dos limites do ecrã
	JGE desenha_boneco_fim	; se estiver, pára de desenhar o boneco
	SUB R1, 1				; menos uma linha para tratar
	JNZ desenha_pixels		; continua até percorrer toda a altura do boneco
desenha_boneco_fim:
	POP R3
	POP R2
	POP R1
	POP	R0
	POP	R8
    POP R9
	POP	R10
	POP R11
	RET

; ***************************************************************************************
; APAGA_BONECO - Apaga um boneco na linha e coluna indicadas
;			  com a forma definida na tabela indicada.
; Argumentos:   R11 - linha de referência do boneco
;               R10 - coluna de referência do boneco
;               R8 - tabela que define o boneco
; ***************************************************************************************
apaga_boneco:
	PUSH R11
	PUSH R10
	PUSH R8
	PUSH R0
	PUSH R1
	PUSH R2
	PUSH R3
	MOV R0, [R8]			; obtém a largura
	ADD R8, 2				; próximo dado na tabela
	MOV R1, [R8]			; obtém a altura
	MOV R2, R10				; define a coluna inicial
	MOV R3, R0				; define a largura inicial
apaga_pixels:
	ADD	R8, 2				; próximo dado da tabela
	CALL apaga_pixel		; apaga o pixel na linha R11 e coluna R10
    ADD R10, 1				; próxima coluna
    SUB R0, 1				; menos uma coluna para tratar
    JNZ  apaga_pixels		; continua até percorrer toda a largura do boneco
	MOV R10, R2				; redefine a coluna
	MOV R0, R3				; redefine a largura
	ADD R11, 1				; próxima linha
	SUB R1, 1				; menos uma linha para tratar
	JNZ  apaga_pixels		; continua até percorrer toda a altura do boneco
	POP R3
	POP R2
	POP R1
	POP	R0
	POP	R8
	POP	R10
	POP R11
	RET

; ***************************************************************************************
; ESCREVE_PIXEL - Escreve um pixel na linha e coluna indicadas.
; Argumentos:   R11 - linha
;               R10 - coluna
;               R9 - cor do pixel (em formato ARGB de 16 bits)
; ***************************************************************************************
escreve_pixel:
	MOV [SELECIONA_LINHA], R11		; seleciona a linha
	MOV [SELECIONA_COLUNA], R10		; seleciona a coluna
	MOV [SELECIONA_PIXEL], R9		; altera a cor do pixel na linha e coluna já selecionadas
	RET

; ***************************************************************************************
; APAGA_PIXEL - Apaga um pixel na linha e coluna indicadas
; Argumentos: R11 - linha
;             R10 - coluna
; ***************************************************************************************
apaga_pixel:
	MOV [SELECIONA_LINHA], R11		; seleciona a linha
	MOV [SELECIONA_COLUNA], R10		; seleciona a coluna
	MOV [APAGA_PIXEL], R9			; apaga o pixel (o valor do registo é irrelevante)
	RET

; ***************************************************************************************
; ATRASO - Executa um ciclo para implementar um atraso.
; Argumentos: R9 - valor que define o atraso
; ***************************************************************************************
atraso:
	PUSH R9
atraso_ciclo:
	SUB	R9, 1						; menos uma repetição
	JNZ	atraso_ciclo				; se ainda houver repetições para fazer, repete
	POP	R9
	RET

;  ********************
; **** INTERRUPÇÕES ****
;  ********************

; *********************************************************
; ROT_INT_METEORO - Rotina de atendimento da interrupção 0
; *********************************************************
rot_int_meteoro:
	MOV [evento_meteoro], R1	; chama o evento meteoro (desbloqueia o processo meteoro)
	RFE

; *********************************************************
; ROT_INT_MISSIL - Rotina de atendimento da interrupção 1
; *********************************************************
rot_int_missil:
	MOV [evento_missil], R1		; chama o evento míssil (desbloqueia o processo míssil)
	RFE

; *********************************************************
; ROT_INT_ENERGIA - Rotina de atendimento da interrupção 2
; *********************************************************
rot_int_energia:
	MOV	[evento_energia], R1	; chama o evento energia (desbloqueia o processo energia)
	RFE