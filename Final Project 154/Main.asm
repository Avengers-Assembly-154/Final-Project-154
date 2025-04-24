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
"    5: To exit", 0Ah, 0Ah,
"Please enter a selection: ", 0

triesMsg BYTE "Your number of tries remaining is: ", 0

badIn BYTE "Invalid character entered. Please try again.", 0Ah, 0

tooManyTries BYTE "Too many tries, exiting application.", 0

goodBye BYTE "Exiting program. Goodbye!", 0

selection DWORD 0
guess DWORD 0
hidden DWORD 0



.code
main proc

tries = 3
MOV ECX, tries ;the ecx register holds a counter for how many tries should be allowed

read:

MOV EDX, OFFSET menu
call writeString

call readInt
JNO goodInt ;if the overflow flag is not set we have a good integer
JMP badInt ;otherwise we have a bad one

goodInt:
CMP EAX, 1
JE sel1
CMP EAX, 2
JE sel2
CMP EAX, 3
JE sel3
CMP EAX, 4
JE sel4
CMP EAX, 5
JE sel5

;if it's not one of these it's a bad input
JMP badInt



sel1:

JMP normalExit
sel2:

JMP normalExit
sel3:

JMP normalExit
sel4:

JMP normalExit
sel5:

JMP normalExit



badInt:
MOV EDX, OFFSET badIn
call writeString
SUB ECX, 1
CMP ECX, 0 ;if we have no tires left jump to that exit point
;I think the comp is unecessary, I don't have time to check if there's a jump
;that'll work with the flags the sub sets
JE tmt
JMP read ;otherwise try and read again

tmt:
MOV EDX, OFFSET tooManyTries
call writeString
jmp final

normalExit:
MOV EDX, OFFSET goodBye
call writeString
final:

exit
main endp

	; insert additional procedures here

end main