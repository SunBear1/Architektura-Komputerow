; Program gwiazdki.asm
; Wyświetlanie znaków * w takt przerwań zegarowych
; Uruchomienie w trybie rzeczywistym procesora x86
; lub na maszynie wirtualnej
; zakończenie programu po naciśnięciu klawisza 'x'
; asemblacja (MASM 4.0): masm gwiazdki.asm,,,;
; konsolidacja (LINK 3.60): link gwiazdki.obj;
.386
rozkazy SEGMENT use16
ASSUME CS:rozkazy

; podprogram 'wyswietl_AL' wyświetla zawartość rejestru AL
; w postaci liczby dziesiętnej bez znaku
wyswietl_AL PROC
; wyświetlanie zawartości rejestru AL na ekranie wg adresu
; podanego w ES:BX
; stosowany jest bezpośredni zapis do pamięci ekranu
; przechowanie rejestrów
push ax
push cx
push dx
mov cl, 10 ; dzielnik

mov ah, 0 ; zerowanie starszej części dzielnej
; dzielenie liczby w AX przez liczbę w CL, iloraz w AL,
; reszta w AH (tu: dzielenie przez 10)
div cl
add ah, 30H ; zamiana na kod ASCII
mov es:[bx+4], ah ; cyfra jedności
mov ah, 0
div cl ; drugie dzielenie przez 10
add ah, 30H ; zamiana na kod ASCII
mov es:[bx+2], ah ; cyfra dziesiątek
add al, 30H ; zamiana na kod ASCII
mov es:[bx+0], al ; cyfra setek
; wpisanie kodu koloru (intensywny biały) do pamięci ekranu
mov al, 00001111B
mov es:[bx+1],al
mov es:[bx+3],al
mov es:[bx+5],al
; odtworzenie rejestrów
pop dx
pop cx
pop ax
ret ; wyjście z podprogramu
wyswietl_AL ENDP

;=======================================================
; procedura obsługi przerwania zegarowegos
obsluga_zegara PROC
; przechowanie używanych rejestrów
push ax
push bx
push es
push ecx
; wpisanie adresu pamięci ekranu do rejestru ES - pamięć
; ekranu dla trybu tekstowego zaczyna się od adresu B8000H,
; jednak do rejestru ES wpisujemy wartość B800H,
; bo w trakcie obliczenia adresu procesor każdorazowo mnoży
; zawartość rejestru ES przez 16
mov ax, 0B800h ;adres pamięci ekranu
mov es, ax
mov bx, cs:licznik
in al, 60H
call wyswietl_AL
pop ecx
pop es
pop bx
pop ax
; skok do oryginalnej procedury obsługi przerwania zegarowego
jmp dword PTR cs:wektor9
; dane programu ze względu na specyfikę obsługi przerwań
; umieszczone są w segmencie kodu
licznik dw 0 ; wyświetlanie począwszy od 2. wiersza
wektor9 dd ?
zmienna dw 0
prawo dw 160
linia dw 0
obsluga_zegara ENDP
;============================================================
; program główny - instalacja i deinstalacja procedury
; obsługi przerwań
; ustalenie strony nr 0 dla trybu tekstowego
zacznij:
mov al, 0
mov ah, 5
int 10
mov ax, 0
mov ds,ax ; zerowanie rejestru DS
; odczytanie zawartości wektora nr 8 i zapisanie go
; w zmiennej 'wektor8' (wektor nr 8 zajmuje w pamięci 4 bajty
; począwszy od adresu fizycznego 8 * 4 = 32)
mov eax,ds:[32] ; adres fizyczny 0*16 + 32 = 32
mov cs:wektor9, eax

; wpisanie do wektora nr 8 adresu procedury 'obsluga_zegara'
mov ax, SEG obsluga_zegara ; część segmentowa adresu
mov bx, OFFSET obsluga_zegara ; offset adresu
cli ; zablokowanie przerwań
; zapisanie adresu procedury do wektora nr 8
mov ds:[32], bx ; OFFSET
mov ds:[34], ax ; cz. segmentowa
sti ;odblokowanie przerwań
; oczekiwanie na naciśnięcie klawisza 'x'
aktywne_oczekiwanie:
mov ah,1
int 16H
; funkcja INT 16H (AH=1) BIOSu ustawia ZF=1 jeśli
; naciśnięto jakiś klawisz
jz aktywne_oczekiwanie
; odczytanie kodu ASCII naciśniętego klawisza (INT 16H, AH=0)
; do rejestru AL

mov ah, 0
int 16H

cmp al, 'x' ; porównanie z kodem litery 'x'
jne aktywne_oczekiwanie ; skok, gdy inny znak
; deinstalacja procedury obsługi przerwania zegarowego
; odtworzenie oryginalnej zawartości wektora nr 8
mov eax, cs:wektor9
cli
mov ds:[32], eax ; przesłanie wartości oryginalnej
; do wektora 8 w tablicy wektorów
; przerwań
sti
; zakończenie programu
mov al, 0
mov ah, 4CH
int 21H
rozkazy ENDS
nasz_stos SEGMENT stack
db 128 dup (?)
nasz_stos ENDS
END zacznij
