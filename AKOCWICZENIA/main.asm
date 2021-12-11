.686
.model flat

extern _MessageBoxA@16 : PROC
extern _MessageBeep@4 : PROC
extern _ExitProcess@4 : PROC

public _main

.data
	tytul db 'TESTOWIRON', 0
	tresc db 'CZY PAPIEŻ MOZE ZJEŚĆ KREMOWKE?', 0

.code
_main PROC
		push 24H				; TAK/NIE + znak zapytania
		push OFFSET tytul
		push OFFSET tresc
		push 0
		call _MessageBoxA@16

		 eax, 6
		jne koniec

		push 0
		call _MessageBeep@4

koniec:
		push 0
		call _ExitProcess@4
_main ENDP

END