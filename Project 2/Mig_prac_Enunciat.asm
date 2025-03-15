.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C


;Subrutines cridades des de C
public C posCurScreen, getMove, moveCursor, moveCursorContinuous, openCard, openCardContinuous, openPair, openPairsContinuous
                         
;Variables utilitzades - declarades en C
extern C row:DWORD, col: BYTE, rowScreen: DWORD, colScreen: DWORD, RowScreenIni: DWORD, ColScreenIni: DWORD 
extern C carac: BYTE, tecla: BYTE, gameCards: DWORD, indexMat: DWORD
extern C Board: BYTE, firstVal: DWORD, firstRow: DWORD, firstCol: BYTE, secondVal: DWORD, secondRow: DWORD, secondCol: BYTE
extern C Player: DWORD, Num_Card: DWORD, HitPair: DWORD


.code   
   
;;Macros que guardan y recuperan de la pila los registros de proposito general de la arquitectura de 32 bits de Intel    
Push_all macro
	
	push eax
   	push ebx
    push ecx
    push edx
    push esi
    push edi
endm


Pop_all macro

	pop edi
   	pop esi
   	pop edx
   	pop ecx
   	pop ebx
   	pop eax
endm
   
   



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Situar el cursor en una fila i una columna de la pantalla
; en funció de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funció gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funció gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els paràmetres s'han de passar per la pila
      
   mov eax, [colScreen]
   push eax
   mov eax, [rowScreen]
   push eax
   call gotoxy_C
   pop eax
   pop eax 
   
   Pop_all

   mov esp, ebp
   pop ebp
   ret
gotoxy endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Mostrar un caràcter, guardat a la variable carac
; en la pantalla en la posició on està  el cursor,  
; cridant a la funció printChar_C.
; 
; Variables utilitzades: 
; carac : variable on està emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqué
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funció  printch_C(char c) des d'assemblador, 
   ; el paràmetre (carac) s'ha de passar per la pila.
 
   xor eax,eax
   mov  al, [carac]
   push eax 
   call printChar_C
 
   pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
printch endp
   
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat   
; cridant a la funció getch_C
; i deixar-lo a la variable tecla.
;
; Variables utilitzades: 
; carac2 : Variable on s'emmagatzema el caracter llegit
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getch proc
   push ebp
   mov  ebp, esp
    
   ;push eax
   Push_all

   call getch_C
   
   mov [tecla],al
   
   ;pop eax
   Pop_all

   mov esp, ebp
   pop ebp
   ret
getch endp




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la pantalla, dins el tauler, en funció de
; les variables row (int) i col (char), a partir dels
; valors de les variables RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 4
; i convertir el char de la columna (A..D) a un número entre 0 i 3.
; Per calcular la posició del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes fórmules:
;            rowScreen=rowScreenIni+(row*2)
;            colScreen=colScreenIni+(col*4)
; Per a posicionar el cursor a la pantalla cridar a la subrutina gotoxy 
; que us donem implementada
;
; Variables utilitzades:	
;	row       : fila per a accedir a la matriu sea
;	col       : columna per a accedir a la matriu sea
;	rowScreen : fila on volem posicionar el cursor a la pantalla.
;	colScreen : columna on volem posicionar el cursor a la pantalla.
;	rowScreenIni : fila de la primera posició de la matriu a la pantalla.
;	colScreenIni : columna de la primera posició de la matriu a la pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
posCurScreen proc
    push ebp
	mov  ebp, esp

	; Restar 1 a row
	mov eax, [row]
    dec eax
	
	; Calcular rowScreen=rowScreenIni+(row*2)
    imul eax, 2
    add eax, [rowScreenIni]
    mov [rowScreen], eax

	; Convertir char a int
	movzx eax, byte ptr [col]
    sub eax, 'A'

	; Calcular colScreen=colScreenIni+(col*4)
    imul eax, 4
    add eax, [colScreenIni]
    mov [colScreen], eax

	; Llamar a la subrutina gotoxy
    call gotoxy

	mov esp, ebp
	pop ebp
	ret

posCurScreen endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Llegir un caràcter de teclat cridant a la subrutina que us donem implementada getch.
; Verificar que el caràcter introduït es troba entre els caràcters ’i’ i ’l’, 
; o bé correspon a les tecles espai ’ ’ o ’s’, i deixar-lo a la variable tecla.
; Si la tecla pitjada no correspon a cap de les tecles permeses, 
; espera que pitgem una de les tecles permeses.
;
; Variables utilitzades:
; tecla : variable on s’emmagatzema el caràcter corresponent a la tecla pitjada
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
getMove proc
   push ebp
   mov ebp, esp

inicio:
   call getch
   
   cmp [tecla], 'i'
   je valid
   cmp [tecla], 'l'
   je valid
   cmp [tecla], 'k'
   je valid
   cmp [tecla], 'j'
   je valid
   cmp [tecla], 's'
   je valid
   cmp [tecla], ' '
   je valid

   jmp inicio

valid:
   mov esp, ebp
   pop ebp
   ret
getMove endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Cridar a la subrutina getMove per a llegir una tecla
; Actualitzar les variables (row) i (col) en funció de
; la tecla pitjada que tenim a la variable (tecla) 
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, 
; (row) i (col) només poden 
; prendre els valors [1..5] i [A..D], respectivament. 
; Si al fer el moviment es surt del tauler, no fer el moviment.
; Posicionar el cursor a la nova posició del tauler cridant a la subrutina posCurScreen
;
; Variables utilitzades:
; tecla : caràcter llegit de teclat
; ’i’: amunt, ’j’:esquerra, ’k’:avall, ’l’:dreta 
; row : fila del cursor a la matriu gameCards.
; col : columna del cursor a la matriu gameCards.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursor proc
   push ebp
   mov  ebp, esp 
   
   call getMove
   
   cmp [tecla], 'i'
   je amunt
   cmp [tecla], 'l'
   je dreta
   cmp [tecla], 'k'
   je avall
   cmp [tecla], 'j'
   je esquerra
   
   jmp fi

amunt:
	cmp [row], 1
	je fi
	dec [row]
	jmp fi
avall:
	cmp [row], 5
	je fi
	inc [row]
	jmp fi
esquerra:
	cmp [col], 'A'
	je fi
	dec [col]
	jmp fi
dreta:
	cmp [col], 'D'
	je fi
	inc [col]
	jmp fi
fi:
	call posCurScreen
   mov esp, ebp
   pop ebp
   ret

moveCursor endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Subrutina que implementa el moviment continu
; del cursor fins que pitgem ‘s’ o ‘ espai ‘ ‘
; S’ha d’anar cridant a la subrutina moveCursor
;
; Variables utilitzades:
; tecla: variable on s’emmagatzema el caràcter llegit
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
moveCursorContinuous proc
	push ebp
	mov  ebp, esp

inici:
	call moveCursor
	cmp [tecla], 's'
	je fi
	cmp [tecla], ' '
	je fi
	jmp inici

fi:
	mov esp, ebp
	pop ebp
	ret

moveCursorContinuous endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina serveix per a poder accedir a les components de la matriu
; i poder obrir les caselles
; Calcular l’índex per a accedir a la matriu gameCards en assemblador.
; gameCards[row][col] en C, ´es [gameCards+indexMat] en assemblador.
; on indexMat = (row*4 + col (convertida a número))*4 .
;
; Variables utilitzades:
; row: fila per a accedir a la matriu gameCards
; col: columna per a accedir a la matriu gameCards
; indexMat: índex per a accedir a la matriu gameCards
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
calcIndex proc
	push ebp
	mov  ebp, esp
	
	Push_all

	mov ebx, 0
	mov eax, [row]
	mov bl, [col]

	dec  eax
	sub  bl, 'A'

	imul eax, 16
	imul ebx, 4
	add eax, ebx
	mov [indexMat], eax
	
	Pop_all
	mov esp, ebp
	pop ebp
	ret

calcIndex endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S’ha de cridar a movCursorContinuous per a triar la casella desitjada.
; Un cop som a la casella desitjada premem al tecla ‘ ‘ (espai per a veure el contingut)
; Calcular la posició de la matriu corresponent a la
; posició que ocupa el cursor a la pantalla, cridant a la subrutina calcIndexP1. 
; Mostrar el contingut de la casella corresponent a la posició del cursor al tauler.
; Considerar que el valor de la matriu és un  int (entre 0 i 9)
; que s’ha de “convertir” al codi ASCII corresponent. 
;
; Variables utilitzades:
; tecla: variable on s’emmagatzema el caràcter llegit
; row : fila per a accedir a la matriu gameCards
; col : columna per a accedir a la matriu gameCards
; indexMat : índex per call moveCursorContinuousa accedir a la matriu gameCards 
; gameCards : matriu 5x4 on tenim els valors de les cartes.
; carac : caràcter per a escriure a pantalla.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCard proc
	push ebp
	mov  ebp, esp

   call moveCursorContinuous
   cmp [tecla], ' '
   jne fi
   call calcIndex
   mov ebx, [indexMat]
   mov eax, [gameCards + ebx]
   add eax, '0'
   mov [carac], al
   call printch

fi:
	mov esp, ebp
	pop ebp
	ret

openCard endp

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; S’ha d'anar cridant a openCard fins que pitgem la tecla 's'
;
; Variables utilitzades:
; tecla: variable on s’emmagatzema el caràcter llegit
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openCardContinuous proc
	push ebp
	mov  ebp, esp

	call posCurScreen
	mov [tecla],0
inici:
	mov al, [tecla]
	cmp al, 's'
	je fi
	call openCard
	jmp inici

fi:

	mov esp, ebp
	pop ebp
	ret

openCardContinuous endp


; Formula posicion 1 byte (row*4 + col (convertida a número))
calcIndex1byte proc
	push ebp
	mov  ebp, esp
	Push_all

	mov eax, [row]
	mov bl, [col]

	dec eax
	sub ebx, 'A'

	imul eax, 4
	add eax, ebx

	mov [indexMat], eax

	Pop_all
	mov esp, ebp
	pop ebp
	ret
calcIndex1byte endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Posicionar el cursor a la posició 3,30 de la pantalla cridant a la subturina gotoxy
; Mostrar el valor de la variable Num_Card (1 o 2)
; Posicionar el cursor a la posició 3,41 de la pantalla cridant a la subrutina gotoxy
; Mostrar el valor de la variable Player (1 o 2)
; Posicionar el cursor al taulell de joc i moure’l de forma continua fins que pitgem ‘s’ o ‘ ‘ 
; Quan pitgem ‘ ‘, obrim la casella (comprovar que no està oberta i marcar-la com oberta)
; Tornar a moure el cursor de forma continua fins que pitgem ‘s’ o ‘ ‘
; Quan pitgem ‘ ‘, obrim la casella (comprovar que no està oberta i marcar-la com oberta)
; Comprovar si els valors de les dues caselles coincideixen. Si coincideixen, posar un 1 a HitPair.
; Si no coincideixen, tancar les dues caselles i desmarcar-les com a obertes.
;
; Variables utilitzades:
; Num_Card: Variable que indica si estem obrint la primera o la segona casella de la parella.
; carac : caràcter a mostrar per pantalla
; row : fila del cursor a la matriu gameCards o Board.
; col : columna del cursor a la matriu gameCards o Board.
; rowScreen: Fila de la pantalla on volem posicionar el cursor.
; colScreen: Columna de la pantalla on volem posicionar el cursor.
; indexMat: Índex per accedir a la posició de la matriu.
; gameCards: Matriu amb els valors de les caselles del tauler.
; Board: Matriu que indica si la casella està oberta o no.
; firstVal, firstRow, firstCol: Dades relatives a la primera casella de la parella.
; secondVal, secondRow, secondCol: Dades relatives a la segona casella de la parella.
; Player: Indica el jugador al que li correspon el torn.
; HitPair: Variable que indica si s’ha fet una parella (0 No parell – 1 Parella)
; tecla: Codi ascii de la tecla pitjada.
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openPair proc
	push ebp
	mov  ebp, esp
	Push_all

	; Inicializar a 1 Num_Card
	mov [Num_Card], 1

AbrirCarta:
    ; Posicionar cursor en la carta
	mov [rowScreen], 3
	mov [colScreen], 30
	call gotoxy

	; Imprimir por pantalla el número de carta (1 o 2)
	mov ecx, [Num_Card]
	add ecx, '0'
	mov [carac], cl
	sub ecx, '0'
	call printch

	; Posicionar cursor en jugador
	mov [rowScreen], 3
	mov [colScreen], 41
	call gotoxy

	; Mostrar número de jugador
	mov eax, [Player]
	add eax, '0'
	mov [carac], al
	call printch

	; Volver al tablero
	call posCurScreen

	call openCard

	cmp [tecla], 's'
	je final

	; Calcular la posición de Board
	call calcIndex1byte
	mov eax, [indexMat]
	mov bl, [Board + eax]

	; Comprueba si la carta esta abierta
	cmp ebx, ' '
	jne AbrirCarta
	mov [Board + eax], 1 ; Mueve un 1 para indicar que esta abierta

	; Es la primera carta?
	cmp ecx, 1
	jne Comparar

	; Sumar 1 a Num_Card
	inc ecx
	mov [Num_Card], ecx

	; Guardar valor de la primera carta
	call calcIndex
	mov eax, [indexMat]

	mov edx, [gameCards + eax]
	mov [firstVal], edx
	mov edx, [row]
	mov [firstRow], edx
	mov dl, [col]
	mov [firstCol], dl

	jmp AbrirCarta

Comparar:
	call calcIndex
	mov eax, [indexMat]

	; Guardar valor de la segunda carta
	mov edx, [gameCards + eax]
	mov [secondVal], edx
	mov edx, [row]
	mov [secondRow], edx
	mov dl, [col]
	mov [secondCol], dl

	; Tiempo de espera para visualizar valor de la segunda carta (Opcional)
	call getch

	; Comparar las dos cartas
	mov edx, [secondVal]
	mov ecx, [firstVal]
	cmp edx, ecx

	; Si son iguales poner 1 en HitPair y acabar, sino reiniciar
	jne Reiniciar
	mov [HitPair], 1
	jmp final

Reiniciar:
    ; Vaciar la segunda casilla
	call gotoxy
	mov [carac], ' '
	call printch

	; Indicar segunda casilla como cerrada
	call calcIndex1byte
	mov eax, [indexMat]
	mov [Board + eax], ' '

	; Vaciar la primera casilla
	mov edx, [firstRow]
	mov [row], edx
	mov dl, [firstCol]
	mov [col], dl
	call posCurScreen
	mov [carac], ' '
	call printch

	; Indicar primera casilla como cerrada
	call calcIndex1byte
	mov eax, [indexMat]
	mov [Board + eax], ' '

final:
	mov [Num_Card], 1

	Pop_all
	mov esp, ebp
	pop ebp
	ret
openPair endp


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Aquesta subrutina ha d’anar cridant a la subrutina anterior OpenPair,
; fins que pitgem la tecla ‘s’
;
; Variables utilitzades:
; tecla: Codi ascii de la tecla pitjada.

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
openPairsContinuous proc
	push ebp
	mov  ebp, esp
	Push_all

inicio:
	call openPair
	cmp [tecla], 's'
	jne inicio

	Pop_all
	mov esp, ebp
	pop ebp
	ret
openPairsContinuous endp


END