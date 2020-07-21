%include "includes/io.inc"

extern getAST
extern freeAST

section .data
    input_array times 1000 dd 0 ; Vectorul unde salvam valorile din input
    counter dd 4                ; Contor folosit la stocarea datelor in vector

section .bss
    ; La aceasta adresa, scheletul stocheaza radacina arborelui
    root: resd 1

section .text
global main

; Functie ce ia valoarea din fiecare nod in mod recursiv
get_nodes:
    cmp ebx, 0 ; Testam daca adresa structurii este NULL
    je return
    
    push ebx ; Stocam adresa structurii pe stiva
    mov edx, ebx ; Stocam adresa structurii in edx
    
    ; Dereferentiem de doua ori si punem in ebx valoarea din nod
    mov ebx, dword [ebx]
    mov esi, ebx ; Salvam in esi adresa nodului
    mov ebx, dword [ebx]

    ; Comparam valoarea din ebx cu valoare operanzilor
    ; Daca este un operand, il adaugam in vector
    cmp ebx, '+'
    je add_operand_to_array
    
    cmp ebx, '-'
    je add_operand_to_array
    
    cmp ebx, '*'
    je add_operand_to_array
    
    cmp ebx, '/'
    je add_operand_to_array

    ; Salvam valorile registrelor pe stiva
    push eax
    push ebx
    push ecx
    push edx
    
    ; Initializam registrele cu noile valori
    xor edx, edx
    xor eax, eax
    mov ebx, 10
    xor edi, edi
    xor ecx, ecx

; Parcurgem registrul byte cu byte si transformam valoarea ASCII in valoare intreaga
string_to_int:
    mov cl, byte [esi]

    ; Verificam daca primul caracter este minus
    cmp cl, '-'
    je change_edi
    jne continue_string_to_int
    
; Setam un flag daca numarul este negativ
change_edi:
    mov edi, 1
    inc esi
    jmp string_to_int

continue_string_to_int:                
    inc esi
    cmp cl, 0 ; Comparam caracterul cu terminatorul de sir
    je end_string_to_int
    
    push edx
    cdq
    imul ebx ; Inmultim numarul curent cu 10
    sub cl, '0' ; Trecem din codul ASCII in valoarea intreaga
    add eax, ecx ; Adaugam cifra la numarul curent
    pop edx
    jmp string_to_int
    
; Testam daca numarul este negativ    
end_string_to_int:
    cmp edi, 1
    je neg_eax
    jne add_eax_to_array

; Negam valoarea lui eax  
neg_eax:
    neg eax
    
; Adaugam valoarea din eax in vector
add_eax_to_array:
    mov edx, dword [counter]
    mov dword [input_array + edx], eax
    add edx, 4
    mov dword [counter], edx
    jmp pop_label

; Adaugarea operandului in vector  
add_operand_to_array:
    push edx
    mov edx, dword [counter]
    mov dword [input_array + edx], ebx
    add edx, 4
    mov dword [counter], edx
    pop edx
    jmp left_subtree
    
; Restauram valorile de pe stiva
pop_label:    
    pop edx
    pop ecx
    pop ebx
    pop eax

; Continuam recursiv pe subarborele stang
left_subtree:    
    mov ebx, edx
    
    mov edx, ebx
    mov ebx, dword [ebx + 4]
    call get_nodes
    mov ebx, edx

; Continuam recursiv pe subarborele drept    
right_subtree:  
    pop ebx
    mov edx, ebx
    mov ebx, dword [ebx + 8]
    call get_nodes
    mov ebx, edx
    
return:
    ret

; Restauram doua numere de pe stiva si facem suma lor
plus:
    pop eax
    pop ebx
    add eax, ebx
    push eax ; Punem rezultatul pe stiva
    jmp check_operand

; Restauram doua numere de pe stiva si facem diferenta lor    
minus:
    pop eax
    pop ebx
    sub eax, ebx
    push eax ; Punem rezultatul pe stiva
    jmp check_operand
    
; Restauram doua numere de pe stiva si le inmultim
multiply:
    pop eax
    pop ebx
    
    ; Salvam valoarea registrului edx pe stiva, pentru a putea face inmultirea corect
    push edx
    xor edx, edx
    cdq
    imul ebx
    pop edx
    
    push eax ; Punem rezultatul pe stiva
    jmp check_operand
    
; Restauram doua numere de pe stiva si le impartim
divide:
    pop eax
    pop ebx
    
    ; Salvam valoarea registrului edx pe stiva, pentru a putea face impartirea corect
    push edx
    xor edx, edx
    cdq
    idiv ebx
    pop edx
    
    push eax ; Punem rezultatul pe stiva
    jmp check_operand

main:
    mov ebp, esp; for correct debugging
    ; NU MODIFICATI
    push ebp
    mov ebp, esp
    
    ; Se citeste arborele si se scrie la adresa indicata mai sus
    call getAST
    mov [root], eax
    
    ; Implementati rezolvarea aici:
     
    mov ebx, dword [root]
    call get_nodes
    
    ; Aflam lungimea vectorului si o salvam in eax
    mov eax, dword [counter]
    xor edx, edx
    sub eax, 4
    mov ebx, 4
    idiv ebx
    
    ; Salvam in ecx valoarea lui eax
    mov ecx, eax
    
; Parcurgem vectorul invers
check_operand:
    cmp ecx, 0
    je print_final_value
    mov edx, dword [input_array + 4 * ecx]
    dec ecx
    
    ; Comparam valoarea din vector cu cea a operanzilor si facem operatia corespunzatoare
    cmp edx, '+'
    je plus
    
    cmp edx, '-'
    je minus
    
    cmp edx, '*'
    je multiply
    
    cmp edx, '/'
    je divide
    
    ; Salvam numarul pe stiva
    push edx
    
    cmp ecx, 0
    jne check_operand
    
print_final_value:
    PRINT_DEC 4, eax
    
    ; NU MODIFICATI
    ; Se elibereaza memoria alocata pentru arbore  
    push dword [root]
    call freeAST
    
    xor eax, eax
    leave
    ret