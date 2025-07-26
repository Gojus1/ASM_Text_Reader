.MODEL SMALL
.STACK 100h

.DATA
filename       db 'f1.txt', 0
outputFile     db 'F2.txt', 0
outputHandle   dw ?

buffer         db 2 dup(?)
msgStart       db 'Program started.$', 0
msgError       db 'Error opening file.$', 0
msgDone        db 'Processing done.$', 0
msgChars       db 'Characters: $', 0
msgWords       db 'Words: $', 0
msgLowercase   db 'Lowercase: $', 0
msgUppercase   db 'Uppercase: $', 0
msgProcess     db 'Processing file...$', 0
crlf           db 0Dh, 0Ah, '$'

charCount      dw 0
wordCount      dw 0
lowercase      dw 0
uppercase      dw 0
inWord         db 0

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
    JNC OPEN_OUTPUT_FILE
    JMP FILE_ERROR

OPEN_OUTPUT_FILE:
    MOV AH, 3Ch
    XOR CX, CX
    LEA DX, outputFile
    INT 21h
    MOV outputHandle, AX
    JC FILE_ERROR

    MOV DX, OFFSET msgProcess
    MOV AH, 09h
    INT 21h

READ_LOOP:
    MOV AH, 3Fh
    MOV BX, AX
    LEA DX, buffer
    MOV CX, 2
    INT 21h
    JC FILE_ERROR
    OR AX, AX
    JZ CLOSE_FILES
    MOV CX, AX
    MOV SI, OFFSET buffer
    CALL GATHER_STATS
    JMP READ_LOOP

CLOSE_FILES:
    MOV AH, 3Eh
    MOV BX, AX
    INT 21h
    MOV AH, 3Eh
    MOV BX, outputHandle
    INT 21h

    MOV DX, OFFSET msgDone
    MOV AH, 09h
    INT 21h
    JMP END_PROGRAM

FILE_ERROR:
    MOV DX, OFFSET msgError
    MOV AH, 09h
    INT 21h

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

    MOV BL, inWord

PROCESS_BUFFER:
    MOV CX, 2
    MOV SI, OFFSET buffer

READ_CHAR:
    LODSB
    TEST AL, AL
    JZ END_BUFFER
    INC charCount

    CMP AL, ' '
    JE HANDLE_WHITESPACE
    CMP AL, 0DH
    JE HANDLE_WHITESPACE
    CMP AL, 0AH
    JE HANDLE_WHITESPACE
    CMP AL, '.'
    JE HANDLE_WHITESPACE
    CMP AL, ','
    JE HANDLE_WHITESPACE

    CMP AL, 'A'
    JB NOT_A_LETTER
    CMP AL, 'Z'
    JBE IS_LETTER
    CMP AL, 'a'
    JB NOT_A_LETTER
    CMP AL, 'z'
    JBE IS_LETTER
    JMP CONTINUE_PROCESSING

IS_LETTER:
    TEST BL, BL
    JNE CONTINUE_PROCESSING
    MOV BL, 1
    INC wordCount
    JMP CONTINUE_PROCESSING

NOT_A_LETTER:
    MOV BL, 0
    JMP CONTINUE_PROCESSING

HANDLE_WHITESPACE:
    MOV BL, 0

CONTINUE_PROCESSING:
    LOOP READ_CHAR

END_BUFFER:
    MOV inWord, BL
    POP SI
    POP DX
    POP CX
    POP BX
    POP AX
    RET
GATHER_STATS ENDP

END MAIN
