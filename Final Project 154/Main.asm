; ------------------------------------------------------------
; Program Description : Guessing game final project
; Team Name: Avengers Assembly
; Team Member Names: Michael Haydel, Katelyn McQueen, Jose Carlos, Kyle Nguyen
; Creation Date : April - May 2025
; Language: IA-32 x86
; Assembler: Microsoft Macro Assembler (MASM)
; Collaboration: 
; ----------------------------------------------------------

INCLUDE Irvine32.inc

;protoype the exit macro so we can use it later
ExitProcess proto, dwExitCode : dword

.data

namePrompt BYTE "Please enter your name(15 character max): ", 0

menu BYTE "*** Avengers Assembly ***", 0Ah, 0Ah,
"*** MAIN MENU ***", 0Ah, 0Ah,
"    1: Display my available credit", 0Ah,
"    2: Add credit to my account (Max $20)", 0Ah,
"    3: Play the guessing game (Costs $1)", 0Ah,
"    4: Display my statistics", 0Ah,
"    5: To exit", 0Ah, 0Ah,
"Please enter a selection: ", 0

triesMsg BYTE "Your number of tries remaining is: ", 0
badInputMsg BYTE "Invalid input entered. Please try again.", 0Ah, 0
tooManyTriesMsg BYTE "Too many tries, exiting application.", 0
goodBye BYTE "Exiting program. Goodbye!", 0Ah, 0
balanceMsg BYTE "Your available balance is: $", 0
addBalanceMsg BYTE "Please enter the amount you would like to add: ", 0

maxCreditMsg BYTE 0Ah, "Maximum allowable credit is $20.00", 0Ah,
		"Please enter a different amount and try again.", 0Ah, 0

balanceAdd BYTE "Credit has been added to your account.", 0Ah, 0
takeGuess BYTE "I've created a random number from 1-10. Please guess the number.", 0Ah, 0

guessRangeMsg BYTE "The number you entered is out of the valid range. Please try again.", 0Ah, 0

congrats BYTE "Congradulations! You guessed ", 0
congrats2 BYTE " correctly! You won $2!", 0Ah, 0

lost BYTE "Sorry, the number was ", 0
lost2 BYTE ". Better luck next time!", 0Ah, 0

playAgain BYTE 0Ah, "Would you like to play again?", 0Ah,
"    1: Yes", 0Ah,
"    2: No", 0Ah, 0Ah, 0

lowBalance BYTE "Sorry, your balance is too low. Please add credit before trying to play again.", 0Ah, 0Ah, 0
highBalance BYTE "You already have at least $20! You can't add any more credit right now.", 0Ah, 0
statsHeader BYTE 0Ah, "== Player Statistics ==", 0Ah, 0
playerNameLabel BYTE "Player Name: ", 0
balanceLabel BYTE "Current Balance: $", 0
gamesPlayedLabel BYTE "Games Played: ", 0
correctGuessesLabel BYTE "Correct Guesses: ", 0
missedGuessesLabel BYTE "Missed Guesses: ", 0
moneyWonLabel BYTE "Money Won: $", 0
moneyLostLabel BYTE "Money Lost: $", 0
pressKey BYTE 0Ah, 0Ah, "Please press any key to continue.", 0


balance DWORD 0
MAX_ALLOWED = 20 ;maximum ammount of allowed money
ammount DWORD 0
correctGuesses DWORD 0
missedGuesses DWORD 0
nameString BYTE 15 dup(0), 0 ;a null terminated 15 character string
gamesPlayed DWORD 0
selection DWORD 0
guess DWORD 0
hidden DWORD 0
triesLeft DWORD 3



.code

main proc

;get the player's name
;the function takes the buffer's base in edx, and the maximum length in ecx
;the function adds one null character to the string, so ecx must be one smaller than the buffer
MOV EDX, OFFSET namePrompt
call writeString
MOV EDX, OFFSET nameString
MOV ECX, 16
call readstring
call clrScr

;seed the rng
call Randomize

;sets up the number of tries the user should have
TRIES_MAX = 3
MOV triesLeft, TRIES_MAX 



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

;if our input is bad
badInt:
call clrScr
MOV EDX, OFFSET badInputMsg
call writeString
MOV EDX, OFFSET triesMsg
call writeString
SUB triesLeft, 1
mov eax, triesLeft
call writeDec
call crlf
cmp triesLeft, 0
jne read
call tooManytries



;the 1st menu item, display's the user's credits
sel1:
MOV triesLeft, TRIES_MAX 
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
MOV triesLeft, TRIES_MAX 
call Clrscr

MOV EBX, balance
CMP EBX, 20
JL adding

MOV EDX, OFFSET highBalance
call writeString
call keyPress
JMP read


adding:
mov EDX, OFFSET addBalanceMsg
call writeString
call readInt
JO nintAdd            ; if overflow flag is set we don't have an integer

;here we need to check if the value of our balance would be higher than 20
mov ebx, balance
add ebx, eax
cmp ebx, 20
ja maxBal
JMP goodAdd

nintAdd:
call clrscr
SUB triesLeft, 1
mov EDX, OFFSET badInputMsg
call writeString
mov EDX, OFFSET triesMsg
call writeString
mov EAX, triesLeft
call writeDec
call crlf
cmp triesLeft, 0
jne adding
call tooManyTries


maxBal:
mov edx, offset maxCreditMsg
call writeString
call keypress
JMP adding

; adds the value to the balance and sends the user back to the main menu the main menu
goodAdd:
mov balance, ebx
mov EDX, OFFSET balanceAdd
call writeString
call keyPress
JMP read



;the 3rd menu item, play the guessing game
sel3: 
MOV triesLeft, TRIES_MAX 
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
;mov triesLeft, TRIES_MAX ;resets tries counter
mov EDX, OFFSET takeGuess
call writeString
call readInt	;takes integer input
JO nintGuess		;if overflow flag is set we don't have an integer
CMP EAX, 10		;checking if guess is in range
JG badGuess
CMP EAX, 1
JL badGuess
inc gamesPlayed
JMP goodGuess

nintGuess:
call clrscr
SUB triesLeft, 1
mov EDX, OFFSET badInputMsg
call writeString
mov EDX, OFFSET triesMsg
call writeString
mov EAX, triesLeft
call writeDec
call crlf
cmp triesLeft, 0
jne guessing
call tooManyTries

badGuess:		;if guess is out of range
call clrscr
SUB triesLeft, 1
mov EDX, OFFSET guessRangeMsg
call writeString
mov EDX, OFFSET triesMsg
call writeString
mov EAX, triesLeft
call writeDec
call crlf
cmp triesLeft, 0
jne guessing
call tooManyTries

goodGuess:		;if guess is in range
mov EBX, EAX
mov EAX, 10
call RandomRange
inc EAX
cmp EAX, EBX
JE win

mov EDX, OFFSET lost
inc missedGuesses
call writeString
call writeDec
mov EDX, OFFSET lost2
call writeString
JMP repeatGame

win:
mov EDX, OFFSET congrats
inc correctGuesses
add balance, 2
call writeString
call writeDec
mov EDX, OFFSET congrats2
call writeString
mov EAX, 2
JMP repeatGame

repeatGame:
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
call clrScr
SUB triesLeft, 1
cmp triesLeft, 0
jne badRepInternal ;this is a bad naming convention, I don't know that I care to fix it
call tooManyTries
badRepInternal:
mov EDX, OFFSET badInputMsg
call writeString
MOV EDX, OFFSET triesMsg
call writeString
MOV EAX, triesLeft
call writeDec
call crlf
JMP repeatGame

yesPlay:
JMP sel3

noPlay:	
call Clrscr
JMP read



;the 4th menu item, displays the user's stats
sel4:
MOV triesLeft, TRIES_MAX 
showStats:
call clrScr

; Display header
mov edx, OFFSET statsHeader
call writeString

; Player Name
mov edx, OFFSET playerNameLabel
call writeString
mov edx, OFFSET nameString
call writeString
call crlf

; Balance
mov edx, OFFSET balanceLabel
call writeString
mov eax, balance
call writeDec
call crlf

; Games Played
mov edx, OFFSET gamesPlayedLabel
call writeString
mov eax, gamesPlayed
call writeDec
call crlf

; Correct Guesses
mov edx, OFFSET correctGuessesLabel
call writeString
mov eax, correctGuesses
call writeDec
call crlf

; Missed Guesses
mov edx, OFFSET missedGuessesLabel
call writeString
mov eax, missedGuesses
call writeDec
call crlf

; Money Won = correctGuesses * 2
mov edx, OFFSET moneyWonLabel
call writeString
mov eax, correctGuesses
shl eax, 1
call writeDec
call crlf

; Money Lost = gamesPlayed - correctGuesses
mov edx, OFFSET moneyLostLabel
call writeString
mov eax, missedGuesses
add eax, correctGuesses
call writeDec
call crlf
call keyPress
JMP read



;the 5th menu item, exits the game
sel5:
call Clrscr
MOV EDX, OFFSET goodBye
call writeString

exit
main endp



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




tooManyTries proc
MOV EDX, OFFSET tooManyTriesMsg
call writeString
invoke ExitProcess, 1
tooManyTries endp



end main
