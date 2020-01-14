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
global droneFunc
extern ass3.s
extern generateRandom
extern scaleRandom
extern endCo
extern resume
extern printf






droneFunc:
    
    ; push droneFunc ;push the function for next time
    ;  mov ebx,[currDrone]
    ;  inc dword [currentStepNum]
    ; push dword [ebx+droneId]
    ; push formatMyId
    ; call printf
    ; add esp,8
    ; mov ebx,[schedulerStruct]
    ; jmp resume
    inc dword [currentStepNum]
    call generateRandom ;Generate delta alpha
    push dword 120
    call scaleRandom
    add esp,4
    mov ebx,[currDrone]
;break:
    finit
    fld qword [floatNum]
    fsub qword [rangeFloat] ;Scaling to [-60,60]
    fstp qword [floatNum]

    finit
    fild dword [constPi]   ; Convert radians into degrees
    fmul qword [ebx+alphaPosition] ;180*angle(rad)
    fstp qword [temp1] ; ;180*angle(rad)
    finit
    fldpi
    fld qword [temp1]
    fdiv st0,st1
    fstp qword [temp1]  ;original alpha in degrees

    finit
    fld qword [temp1]
    fadd qword [floatNum]
    fstp qword [floatNum] ;new alpha in degrees
    finit
    fld qword [floatNum]
    fld qword [maxAlpha]
    fcomi
    jae checkBelowZero
    ;above360
    finit
    fld qword [floatNum]
    fsub qword [maxAlpha]
    fstp qword [floatNum]
    jmp inTheRange
checkBelowZero:
    finit
    fld qword [floatNum]
    fldz
    fcomi
    jbe inTheRange
    ;below0
    finit
    fld qword [floatNum]
    fadd qword [maxAlpha]
    fstp qword [floatNum]


inTheRange:
    finit
    fldpi   ; Convert degrees into radians
    fmul qword [floatNum]
    fidiv dword [constPi]
    fstp qword [ebx+alphaPosition] ; put new alpha
    finit
    call generateRandom ;Generate delta distance
    push dword 50
    call scaleRandom
    add esp,4
    mov ebx,[currDrone]
    finit
    fld qword [ebx+alphaPosition]
    fsin
    fmul qword [floatNum] ;Now top stack contains delta in Y position
    fadd qword [ebx+Yposition]
    fstp qword [ebx+Yposition] ; Update Y position
    finit
    fld qword [ebx+alphaPosition]
    fcos
    fmul qword [floatNum] ;Now top stack contains delta in X position
    fadd qword [ebx+Xposition]
    fstp qword [ebx+Xposition] ; Update X position
    
    finit  ;Checking edges on torus
    fldz
    fld qword [ebx+Xposition]
    fcomi
    jb xBelowZero
check1:
    finit
    fldz
    fld qword [ebx+Yposition]
    fcomi
    jb yBelowZero
check2:
    finit
    fld qword [constRangeFloat] ;100 
    fld qword [ebx+Xposition]
    fcomi
    ja xAbove100
check3:
    finit
    fld qword [constRangeFloat]
    fld qword [ebx+Yposition]
    fcomi
    ja yAbove100
    jmp continueFunc

xBelowZero:
    finit
    fld qword [constRangeFloat]
    fadd qword [ebx+Xposition]
    fstp qword [ebx+Xposition]
    jmp check1

yBelowZero:
    finit
    fld qword [constRangeFloat]
    fadd qword [ebx+Yposition]
    fstp qword [ebx+Yposition]
    jmp check2

xAbove100:
    finit
    fld qword [ebx+Xposition]
    fsub qword [constRangeFloat]
    fstp qword [ebx+Xposition]
    jmp check3

yAbove100:
    finit
    fld qword [ebx+Yposition]
    fsub qword [constRangeFloat]
    fstp qword [ebx+Yposition]

continueFunc:
    push dword [currDrone]
    call mayDestroy
    add esp,4
    push droneFunc ;push for next time
    cmp eax,0x0001
    jz true
    mov ebx,[schedulerStruct]
    jmp resume
true: 
    inc dword [ebx+numOfTargetsDestroyedPos] ;Increase destroyed targets for that drone
    mov esi,dword [numDestroyToWin] 
    cmp dword [ebx+numOfTargetsDestroyedPos],esi ;Checking if destroyed target number >= T
    jl droneDidntWin
    push dword [ebx+droneId]
    push winner_format
    call printf
    add esp,8
    jmp endCo
     
droneDidntWin:
    mov ebx,[targetStruct]
    jmp resume





mayDestroy:
    push ebp
    mov ebp,esp
    mov ebx,[ebp+8] ;get co-routine argument
    mov ecx,[targetStruct]
    finit
    fld qword [ecx+Xposition]
    fsub qword [ebx+Xposition]
    fstp qword[temp1] ;x2-x1
    finit
    fld qword [ecx+Yposition]
    fsub qword [ebx+Yposition]
    fstp qword[temp2];y2-y1
    finit
    fld qword [temp2]
    fld qword [temp1]
    fpatan
    fstp qword [gamma] ; gamma contains arctan2(y2-y1, x2-x1)
    finit 
    fld qword [ebx+alphaPosition]
    fsub qword [gamma]
    fabs
    fstp qword [temp1];|alpha-gamma|
    finit
    fldpi
    fld qword [temp1]
    fcomi ;Checking |alpha-gamma|>pi
    jbe belowEqualPi
    finit
    fld qword [ebx+alphaPosition]
    fld qword [gamma]
    fcomi 
    ja gammaIsLarger
gammaIsSmaller:
    finit ;add 2*pi to gamma
    fldpi
    fld qword [gamma]
    fadd st0,st1
    fldpi
    fadd st0,st1
    fstp qword [gamma]
    jmp belowEqualPi

gammaIsLarger: ;add 2*pi to alpha
    finit
    fldpi
    fld qword [ebx+alphaPosition]
    fadd st0,st1
    fldpi
    fadd st0,st1
    fstp qword [ebx+alphaPosition]    

belowEqualPi:
    finit
    fld qword [ebx+alphaPosition]
    fsub qword [gamma]
    fabs
    fstp qword [temp1];abs(alpha-gamma)
    finit
    fld qword [beta]
    fld  qword [temp1]
    fcomi ;Checking (abs(alpha-gamma) < beta)
    jae noDestroy
    finit
    mov ecx,[targetStruct]
    fld qword [ecx+Xposition]
    fsub qword [ebx+Xposition]
    fstp qword [temp1] ;x2-x1
    finit
    fld qword [temp1]
    fmul qword [temp1] 
    fstp qword [temp1] ;Now temp1 stack contains (x2-x1)^2
    finit
    mov ecx,[targetStruct]
    fld qword [ecx+Yposition]
    fsub qword [ebx+Yposition]
    fstp qword [temp2] ;y2-y1
    finit
    fld qword [temp2]
    fmul qword [temp2] ;Now top stack stack contains (y2-y1)^2 
    fadd qword [temp1] 
    fsqrt ;Now top stack contains sqrt((y2-y1)^2+(x2-x1)^2)
    fstp qword [temp2] ;contains sqrt((y2-y1)^2+(x2-x1)^2)
    finit
    fild dword [maxDistance] ;load d argument to stack
    fld qword [temp2]
    fcomi ;Checking sqrt((y2-y1)^2+(x2-x1)^2) < d
    jae noDestroy
    mov eax,0x0001 ;Destroyed target - return true
    jmp endMayDestroy

noDestroy:
    mov eax,0 
endMayDestroy:
     mov esp,ebp
     pop ebp
     ret 

