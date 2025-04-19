; ------------------------------------------------------------
; Program Description : a program that adds two integers
; Author:
; Creation Date :
; Language: IA-32 x86
; Assembler: Microsoft Macro Assembler (MASM)
; Collaboration:
; ----------------------------------------------------------

INCLUDE Irvine32.inc

.data

menu BYTE "*** Avengers Assembly ***", 0Ah, 0Ah, 0Ah, 0Ah,
"*** MAIN MENU ***", 0Ah, 0Ah,
"    1: Display my available credit", 0Ah,
"    2: Add credit to my account", 0Ah,
"    3: Play the guessing game", 0Ah,
"    4: Display my statistics", 0Ah,
"    5: To exit", 0Ah, 0


.code
main proc

MOV EDX, OFFSET menu
call writeString

exit
main endp

	; insert additional procedures here

end main