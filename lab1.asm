; Program linie.asm
; wyświetlanie linie w takt przerwań zegarowych

; zakończenie 'x'
; asemblacja (MASM 4.0) : masm linie.asm,,,;
; konsolidacja (LINK 3.60) : link linie.obj;

.386
rozkazy	SEGMENT		use16
		ASSUME		CS:rozkazy
				
linia PROC

	PUSH AX
	PUSH BX
	PUSH ES
	
	mov al, cs:licznik
	mov ah, cs:kolor
	
	inc al
	cmp al, 3									; podmianka co 3 s
	jb dalej
	
	mov al, 0									; co 3 -> zatem po osiągnięciu 3 należy ustawić 0
	
	mov ah, cs:kolor
	cmp ah, 0									; czarny
	je zmien_na_zolty
	cmp ah, 00001110b									; żółty
	je zmien_na_czarny
	
	zmien_na_zolty:
		mov ah, 00001110b
		jmp dalej
		
	zmien_na_czarny:
		mov ah, 0
		jmp dalej
		
	dalej:
		mov cs:licznik, al
		mov cs:kolor, ah
	
	MOV AX, 0A000h								; adres pamięci ekranu dla trybu 13H
	MOV ES, AX

	mov ax, 30555								; 95*320+155
	mov CS:adres_piksela, ax
	MOV BX, CS:adres_piksela
	
	mov cx, 10
	koloruj_wiersz:
		mov al, cs:kolor
		mov es:[bx+di], al
		inc di
		cmp di, 10
		jb koloruj_wiersz
		
		add bx, 320
		mov di, 0
		loop koloruj_wiersz
	
	wyjdz:
	POP ES
	POP BX
	POP AX
	
	JMP dword PTR CS:wektor8
	
	
	kolor			db	0
	adres_piksela	dw 	0
	wektor8			dd	?
	kolumna			db	0
	wiersz			db	0
	licznik			db	0
linia ENDP

zacznij:
	; ustawienie trybu sterownika graficznego na 13H
	MOV AH, 0
	MOV AL, 13H
	INT 10H

	MOV BX, 0
	MOV ES, BX	; zerowanie ES
	MOV EAX, ES:[32]
	MOV CS:wektor8, EAX

	MOV AX, SEG linia
	MOV BX, OFFSET linia

	CLI

	MOV ES:[32], BX
	MOV ES:[32+2], AX

	STI

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
		
	; ustawienie trybu sterownika graficznego na 3H
	MOV AH, 0
	MOV AL, 3H
	INT 10H

	MOV EAX, CS:wektor8
	MOV ES:[32], EAX

	; zakończenie
	MOV AX, 4C00h
	INT 21H

	rozkazy ENDS

	stosik SEGMENT stack
		db 256 dup (?)
	stosik ENDS

END zacznij
