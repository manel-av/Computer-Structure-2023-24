.586
.MODEL FLAT, C


; Funcions definides en C
printChar_C PROTO C, value:SDWORD
gotoxy_C PROTO C, value:SDWORD, value1: SDWORD
getch_C PROTO C


;Subrutines cridades des de C
public C posCurScreen, getMove, moveCursor, moveCursorContinuous, openCard, openCardContinuous
                         
;Variables utilitzades - declarades en C
extern C row:DWORD, col: BYTE, rowScreen: DWORD, colScreen: DWORD, RowScreenIni: DWORD, ColScreenIni: DWORD 
extern C carac: BYTE, tecla: BYTE, gameCards: DWORD, indexMat: DWORD


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
; en funci� de la fila i columna indicats per les variables colScreen i rowScreen
; cridant a la funci� gotoxy_C.
;
; Variables utilitzades: 
; Cap
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
gotoxy proc
   push ebp
   mov  ebp, esp
   Push_all

   ; Quan cridem la funci� gotoxy_C(int row_num, int col_num) des d'assemblador 
   ; els par�metres s'han de passar per la pila
      
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
; Mostrar un car�cter, guardat a la variable carac
; en la pantalla en la posici� on est� el cursor,  
; cridant a la funci� printChar_C.
; 
; Variables utilitzades: 
; carac : variable on est� emmagatzemat el caracter a treure per pantalla
; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
printch proc
   push ebp
   mov  ebp, esp
   ;guardem l'estat dels registres del processador perqu�
   ;les funcions de C no mantenen l'estat dels registres.
   
   
   Push_all
   

   ; Quan cridem la funci�  printch_C(char c) des d'assemblador, 
   ; el par�metre (carac) s'ha de passar per la pila.
 
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
; Llegir un car�cter de teclat   
; cridant a la funci� getch_C
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
; Posicionar el cursor a la pantalla, dins el tauler, en funci� de
; les variables row (int) i col (char), a partir dels
; valors de les variables RowScreenIni i ColScreenIni.
; Primer cal restar 1 a row (fila) per a que quedi entre 0 i 4
; i convertir el char de la columna (A..D) a un n�mero entre 0 i 3.
; Per calcular la posici� del cursor a pantalla (rowScreen) i 
; (colScreen) utilitzar aquestes f�rmules:
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
;	rowScreenIni : fila de la primera posici� de la matriu a la pantalla.
;	colScreenIni : columna de la primera posici� de la matriu a la pantalla.
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
; Llegir un car�cter de teclat cridant a la subrutina que us donem implementada getch.
; Verificar que el car�cter introdu�t es troba entre els car�cters �i� i �l�, 
; o b� correspon a les tecles espai � � o �s�, i deixar-lo a la variable tecla.
; Si la tecla pitjada no correspon a cap de les tecles permeses, 
; espera que pitgem una de les tecles permeses.
;
; Variables utilitzades:
; tecla : variable on s�emmagatzema el car�cter corresponent a la tecla pitjada
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
; Actualitzar les variables (row) i (col) en funci� de
; la tecla pitjada que tenim a la variable (tecla) 
; (i: amunt, j:esquerra, k:avall, l:dreta).
; Comprovar que no sortim del tauler, 
; (row) i (col) nom�s poden 
; prendre els valors [1..5] i [A..D], respectivament. 
; Si al fer el moviment es surt del tauler, no fer el moviment.
; Posicionar el cursor a la nova posici� del tauler cridant a la subrutina posCurScreen
;
; Variables utilitzades:
; tecla : car�cter llegit de teclat
; �i�: amunt, �j�:esquerra, �k�:avall, �l�:dreta 
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
; del cursor fins que pitgem �s� o � espai � �
; S�ha d�anar cridant a la subrutina moveCursor
;
; Variables utilitzades:
; tecla: variable on s�emmagatzema el car�cter llegit
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
; Calcular l��ndex per a accedir a la matriu gameCards en assemblador.
; gameCards[row][col] en C, �es [gameCards+indexMat] en assemblador.
; on indexMat = (row*4 + col (convertida a n�mero))*4 .
;
; Variables utilitzades:
; row: fila per a accedir a la matriu gameCards
; col: columna per a accedir a la matriu gameCards
; indexMat: �ndex per a accedir a la matriu gameCards
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
; S�ha de cridar a movCursorContinuous per a triar la casella desitjada.
; Un cop som a la casella desitjada premem al tecla � � (espai per a veure el contingut)
; Calcular la posici� de la matriu corresponent a la
; posici� que ocupa el cursor a la pantalla, cridant a la subrutina calcIndexP1. 
; Mostrar el contingut de la casella corresponent a la posici� del cursor al tauler.
; Considerar que el valor de la matriu �s un  int (entre 0 i 9)
; que s�ha de �convertir� al codi ASCII corresponent. 
;
; Variables utilitzades:
; tecla: variable on s�emmagatzema el car�cter llegit
; row : fila per a accedir a la matriu gameCards
; col : columna per a accedir a la matriu gameCards
; indexMat : �ndex per a accedir a la matriu gameCards 
; gameCards : matriu 5x4 on tenim els valors de les cartes.
; carac : car�cter per a escriure a pantalla.
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
; S�ha d'anar cridant a openCard fins que pitgem la tecla 's'
;
; Variables utilitzades:
; tecla: variable on s�emmagatzema el car�cter llegit
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


END