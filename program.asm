.MODEL SMALL
.STACK 100h

.DATA
filename db 'ANY_TXT_FILE.txt', 0
buffer db 2 dup(?)
msgStart db 'Program started.$', 0
msgError db 'Error opening file.$', 0
msgDone db 'Processing done.$', 0
msgChars db 'Characters: $', 0
msgWords db 'Words: $', 0
msgLowercase db 'Lowercase: $', 0
msgUppercase db 'Uppercase: $', 0
msgProcess db 'Processing file...$', 0
crlf db 0Dh, 0Ah, '$'

charCount dw 0
wordCount dw 0
lowercase dw 0
uppercase dw 0
inWord db 0  

.CODE
MAIN PROC
    MOV AX, @DATA
    MOV DS, AX
    MOV DX, OFFSET msgStart
    MOV AH, 09h
    INT 21h

    MOV DX, OFFSET filename
    MOV AH, 3Dh
    MOV AL, 0
    INT 21h
    JNC SKIP_FILE_ERROR
    JMP FILE_ERROR
SKIP_FILE_ERROR:
    MOV BX, AX
    MOV DX, OFFSET msgProcess
    MOV AH, 09h
    INT 21h

READ_LOOP:
    MOV AH, 3Fh
    MOV CX, 2
    MOV DX, OFFSET buffer
    INT 21h
    JNC SKIP_READ_ERROR
    JMP FILE_ERROR
SKIP_READ_ERROR:
    OR AX, AX
    JZ CLOSE_FILE
    MOV CX, AX
    MOV SI, OFFSET buffer
    CALL GATHER_STATS
    JMP READ_LOOP

CLOSE_FILE:
    MOV AH, 3Eh
    MOV BX, BX
    INT 21h
    MOV DX, OFFSET msgDone
    MOV AH, 09h
    INT 21h
    MOV DX, OFFSET crlf
    MOV AH, 09h
    INT 21h

    MOV DX, OFFSET msgChars
    MOV AH, 09h
    INT 21h
    MOV AX, charCount
    CALL PRINT_NUMBER
    MOV DX, OFFSET crlf
    MOV AH, 09h
    INT 21h
    MOV DX, OFFSET msgWords
    MOV AH, 09h
    INT 21h
    MOV AX, wordCount
    CALL PRINT_NUMBER

    MOV DX, OFFSET crlf
    MOV AH, 09h
    INT 21h
    MOV DX, OFFSET msgLowercase
    MOV AH, 09h
    INT 21h
    MOV AX, lowercase
    CALL PRINT_NUMBER

    MOV DX, OFFSET crlf
    MOV AH, 09h
    INT 21h
    MOV DX, OFFSET msgUppercase
    MOV AH, 09h
    INT 21h
    MOV AX, uppercase
    CALL PRINT_NUMBER

    JMP END_PROGRAM

FILE_ERROR:
    MOV DX, OFFSET msgError
    MOV AH, 09h
    INT 21h
    JMP END_PROGRAM

END_PROGRAM:
    MOV AH, 4Ch
    INT 21h
    RET
MAIN ENDP

GATHER_STATS PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    PUSH SI

    MOV AL, inWord  
    MOV BL, AL     
    XOR BH, BH    

PROCESS_BUFFER:
    LODSB
    DEC CX
    CMP AL, 0
    JE END_BUFFER

    INC charCount
    CMP AL, 'A'
    JB CHECK_LOWERCASE
    CMP AL, 'Z'
    JBE COUNT_UPPERCASE

CHECK_LOWERCASE:
    CMP AL, 'a'              
    JB CHECK_WHITESPACE
    CMP AL, 'z'
    JBE COUNT_LOWERCASE

COUNT_UPPERCASE:
    INC uppercase
    JMP MARK_IN_WORD

COUNT_LOWERCASE:
    INC lowercase
    JMP MARK_IN_WORD

MARK_IN_WORD:
    CMP BX, 1
    JE CONTINUE_PROCESSING
    INC wordCount
    MOV BX, 1

CHECK_WHITESPACE:
    CMP AL, 20h
    JE END_WORD
    CMP AL, 0Dh
    JE END_WORD
    CMP AL, 0Ah
    JE END_WORD
    JMP CONTINUE_PROCESSING

END_WORD:
    MOV BX, 0

CONTINUE_PROCESSING:
    TEST CX, 0
    JNZ PROCESS_BUFFER

END_BUFFER:
    MOV inWord, BL
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
GATHER_STATS ENDP

PRINT_NUMBER PROC
    PUSH AX
    PUSH BX
    PUSH CX
    PUSH DX
    XOR CX, CX

PRINT_LOOP:
    XOR DX, DX
    MOV BX, 10
    DIV BX
    ADD DL, '0'
    PUSH DX
    INC CX
    TEST AX, AX
    JNZ PRINT_LOOP

PRINT_DIGITS:
    POP DX
    MOV AH, 02h
    INT 21h
    LOOP PRINT_DIGITS

    POP DX
    POP CX
    POP BX
    POP AX
    RET
PRINT_NUMBER ENDP
END MAIN
