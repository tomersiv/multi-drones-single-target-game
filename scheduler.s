section .data 
extern temp1
extern Rstate
extern MAX_INT
extern Rstate32bit
extern floatNum
extern range
extern rangeFloat
extern numco
extern constRange
extern constRangeFloat
extern maxAlpha
extern constPi
extern temp1
extern temp2
extern currentDroneToRun
extern numStepsToPrint
extern currentStepNum
extern numDestroyToWin
extern betaTemp
extern beta
extern gamma
extern maxDistance
extern NumOfDrones
extern droneIdCounter

section .bss
extern Drones
extern currDrone
extern RestCors
extern CURR
extern SPT
extern SPMAIN
extern schedulerStruct
extern printerStruct
extern targetStruct

section	.rodata	
    extern formatTarget
    extern formatDrone
    extern formatCheckArgs
    extern formatCheckRandom
    extern winner_format
    extern formatMyId
    extern argBuffer
    STKSIZE equ 16*1024
    CODEP equ 0
    SPP equ 4
    droneId equ 32
    Xposition equ 8
    Yposition equ 16
    alphaPosition equ 24
    numOfTargetsDestroyedPos equ 36
    DroneSize equ  40 ; func , stack pointer ,  x , y , alpha ,id, num of targets destroyed.
    TargetSize equ 24 ; func , stack pointer, x , y
    RANDOM_MASK equ 0x2D



section .text
global schedulerFunc
extern generateRandom
extern scaleRandom
extern endCo
extern resume
extern printf







schedulerFunc:
; mov ebx,[printerStruct]
; jmp resume
;     push 0
;     push formatID
;     call printf
;     add esp,8
;     push dword nextFunc
;     jmp resume
; nextFunc:
;     push 2
;     push formatID
;     call printf
;     add esp,8
    push schedulerFunc ; push the function for next time
    mov esi,[numStepsToPrint]
    cmp esi, [currentStepNum]
    jnz noPrint
    mov dword [currentStepNum] , 0 ;start counting steps to print from beggining
    mov ebx,[printerStruct]
    jmp resume
noPrint:
    inc dword [currentDroneToRun]
    mov esi, [NumOfDrones]
    cmp [currentDroneToRun] , esi
    jle setDrone
    mov dword [currentDroneToRun] , 1 ;if the current drone num is bigger than num of drones, start round robin again.
setDrone:
    mov eax,0
    mov eax,[currentDroneToRun]
    dec eax
    mov esi,0
    mov esi,DroneSize
    mul esi
    mov ebx,0
    mov ebx, [Drones]
    add ebx, eax
    mov [currDrone] , ebx
    jmp resume
