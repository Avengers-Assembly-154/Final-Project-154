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

balanceMsg BYTE "Your available balance is: $", 0

addMsg BYTE "Please enter the amount you would like to add: ", 0

badAdd BYTE "Maximum allowable credit is $20.00", 0Ah,
            "Please enter a different amount and try again.", 0Ah, 0

badCredit BYTE "Add at least $1.00 to your account.", 0Ah,
               "Please enter a different amount and try again.", 0Ah, 0

balanceAdd BYTE "Credit has been added to your account.", 0Ah, 0

takeGuess BYTE 0Ah, "I've created a random number from 1-10. Please guess the number.", 0Ah, 0

congrats BYTE "Congradulations! You guessed ", 0
congrats2 BYTE " correctly! You won $2!", 0Ah, 0

lost BYTE "Sorry, the number was ", 0
lost2 BYTE ". Better luck next time!", 0Ah, 0

playAgain BYTE 0Ah, "Would you like to play again?", 0Ah,
"    1: Yes", 0Ah,
"    2: No", 0Ah, 0Ah, 0

lowBalance BYTE 0Ah, 0Ah, "Sorry, your balance is too low. Please add credit before trying to play again.", 0Ah, 0Ah, 0

pressKey BYTE 0Ah, 0Ah, "Please press any key to continue.", 0


balance DWORD 0
MAX_ALLOWED = 20 ;maximum ammount of allowed money
ammount DWORD 0
correctGuesses DWORD 0
missedGuesses DWORD 0
name BYTE 15 dup(0), 0 ;a null terminated 15 character string

selection DWORD 0
guess DWORD 0
hidden DWORD 0



.code

main proc

;sets up the number of tries the user should have
tries = 3
MOV ECX, tries ;the ecx register holds a counter for how many tries should be allowed

;put all setup code for the main loop above this label
;the main loop, prints the menu then accepts user input
read:

;print out the main menu
MOV EDX, OFFSET menu
call writeString

;get the user's input, if it's a valid input jump to parsing which selection
;if it's bad process the bad input
call readInt
JNO goodInt ;if the overflow flag is not set we have a good integer
JMP badInt ;otherwise we have a bad one

;determine which menu item the user selected, if it's not one of the options, the input is invalid
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

;if our input is bad, not sure this should remain here long term.
badInt:
MOV EDX, OFFSET badAdd
call writeString
SUB ECX, 1
JECXZ tmt ;found a jump that avoids the cmp
JMP read ;otherwise try and read again

;too many tries, exits the game
tmt:
MOV EDX, OFFSET tooManyTries
call writeString
jmp final


;the 1st menu item, display's the user's credits
sel1:
call Clrscr
mov EDX, OFFSET balanceMsg
call writeString
mov EAX, balance
call writeDec
mov al, 0Ah
call writeChar
call keyPress
JMP read


;the 2nd menu item, add credit to the user's account
sel2:
call Clrscr

mov EDX, OFFSET addMsg
call writeString

call readInt
JO badInt            ; if overflow flag is set we don't have an integer
CMP EAX, MAX_ALLOWED ; checking if value is under 20
JG badmax
CMP EAX, 1           ; checking if value is at least 1
JL badmin
JMP goodAdd

; if the value is higher than 20, call sel2
badmax:
mov EDX, OFFSET badAdd
call writeString
call keyPress
JMP sel2

; if the value is lower than 1, call sel2
badmin:
mov EDX, OFFSET badCredit
call writeString
call keyPress
JMP sel2

; adds the value to the balance and sends the user back to the main menu the main menu
goodAdd:
call addBal

mov EDX, OFFSET balanceAdd
call writeString
call keyPress
JMP read


;the 3rd menu item, play the guessing game
sel3: 
call Clrscr
mov EAX, balance
cmp EAX, 0			;check user's balance
JLE tooLow ;if balance is <= 0, user can't play
dec EAX
mov balance, EAX
JMP guessing

tooLow:
mov EDX, OFFSET lowBalance
call writeString
call keyPress
JMP read

guessing:
mov ECX, tries	;resets tries counter
mov EDX, OFFSET takeGuess
call writeString
call readInt	;takes integer input
JO badInt		;if overflow flag is set we don't have an integer
CMP EAX, 10		;checking if guess is in range
JG badGuess
CMP EAX, 1
JL badGuess
JMP goodGuess


badGuess:		;if guess is out of range
SUB ECX, 1
;JECXZ tmt ;currently commented out bc jump is out of range
JMP sel3


goodGuess:		;if guess is in range
mov EBX, EAX
call Randomize
mov EAX, 10
call RandomRange
inc EAX
cmp EAX, EBX
JE win

mov EDX, OFFSET lost
call writeString
call writeDec
mov EDX, OFFSET lost2
call writeString

mov EAX, missedGuesses
inc EAX
mov missedGuesses, EAX

JMP repeatGame

win:
mov EDX, OFFSET congrats
call writeString
call writeDec
mov EDX, OFFSET congrats2
call writeString

mov EAX, 2
call addBal

mov EAX, correctGuesses
inc EAX
mov correctGuesses, EAX

JMP repeatGame



repeatGame:
mov ECX, tries
mov EDX, OFFSET playAgain	;asks if user would like to play again
call writeString
call readInt
JO badRep
CMP EAX, 1
JE yesPlay
CMP EAX, 2
JE noPlay
JMP badRep

badRep:
SUB ECX, 1
;JECXZ tmt		;jump was out of range, took out temporarily
mov EDX, OFFSET badIn
call writeString
JMP repeatGame

yesPlay:
JMP sel3

noPlay:	
call Clrscr
JMP read



;the 4th menu item, displays the user's stats
sel4:

mov EAX, correctGuesses
call writeDec
mov EAX, missedGuesses
call writeDec

JMP read

;the 5th menu item, exits the game
sel5:
JMP normalExit





normalExit:
MOV EDX, OFFSET goodBye
call writeString

final:

exit
main endp


addBal proc
push ebp
mov ebp, esp

add EAX, balance
mov balance, EAX

mov esp, ebp
pop ebp
ret
addBal endp

keyPress proc
push ebp
mov ebp, esp

mov edx, offset pressKey
call writeString

LookForKey:
mov eax, 50
call Delay
call ReadKey
jz LookForKey

call Clrscr

mov esp, ebp
pop ebp
ret
keyPress endp

end main
