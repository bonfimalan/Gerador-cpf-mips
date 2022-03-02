.data
  FRASE1: .asciiz "Digite 9 digitos para gerar um cpf (ex: 590232134): "
  FRASE2: .asciiz "O CPF gerado eh "
  CPF: .asciiz ""

.text
.globl main
main:
  # imprime a frase 1
  li $v0, 4
  la $a0, FRASE1
  syscall

  # le o cpf
  li $v0, 8
  la $a0, CPF
  li $a1, 11
  syscall

  # calcula o primeiro digito
  la $a0, CPF
  li $a1, 10
  li $a2, 9
  jal DIGITO

  # calcula o segundo digito
  la $a0, CPF
  li $a1, 11
  li $a2, 10
  jal DIGITO

  li $v0, 4
  la $a0, FRASE2
  syscall

  # adicionando o byte de fim de string no cpf
  #li $t0, 0
  #la $t1, CPF
  #sb $t0, 11($t1)

  # imprime a frase 2
  li $v0, 4
  la $a0, CPF
  syscall

  j END

# nome da funcao: DIGITO
# argumentos:
#   $a0 = ponteiro do cpf
#   $a1 = multiplicador
#   $a2 = tamanho do cpf no momento (9 ou 10 digitos)
# retorno:
#   sem retorno
DIGITO:
  # armazenando registradores na pilha
  addi $sp, $sp, -12
  sw $t0, 0($sp)
  sw $t1, 4($sp)
  sw $t2, 8($sp)


  li $t0, 0                 # contador
  li $t1, 0                 # soma das multiplicacoes
  LOOP:
    lb $t2, 0($a0)          # char na posicao 0 do ponteiro
    addi $t2, $t2, -48      # transgforma de ascii para digito
    mul $t2, $t2, $a1       # multiplica o numero para calcular a verificacao
    add $t1, $t1, $t2       # soma com o total
    addi $t0, $t0, 1        # incrementa o contador
    addi $a1, $a1, -1       # decrementa o multiplicador
    addi $a0, $a0, 1        # incrementa o ponteiro
    bne $t0, $a2, LOOP

  # calculando o mod
  addi $sp, $sp, -8
  sw $ra, 0($sp)
  sw $a0, 4($sp)

  move $a0, $t1
  li $a1, 11
  jal MOD

  lw $a0, 4($sp)
  lw $ra, 0($sp)
  addi $sp, $sp, 8
  #-----------------------

  # calculando o valor do digito de verificacao
  # 11 - reto
  # $v0 = resto
  li $t0, 11                # constante que eh usada para subtrair do resto
  sub $t0, $t0, $v0

  li $t1, 10
  slt $t1, $t0, $t1         # se 11 - resto < 10, $t1 = 1, se nao $t1 = 0
  bne $t1, $zero, ELSE
    li $t0, 0 # $t0 recebe 0, caso o resto tenha sido 1 ou 0
  ELSE: # se $t0 < 10

  # adicionando o numero ao final do cpf
  addi $t0, $t0, 48         # transforma o numero no codigo ascii do char
  sb $t0, 0($a0)

  # recarregando os registradores com os valores presentes na pilha
  lw $t0, 0($sp)
  lw $t1, 4($sp)
  lw $t2, 8($sp)
  addi $sp, $sp, 12
  jr $ra

# nome da funcao: MOD
# argumentos:
#   $a0 = dividendo
#   $a1 = divisor
# retorno:
#   $v0 = resto da divisao
MOD:
  div $v0, $a0, $a1
  mul $v0, $a1, $v0
  sub $v0, $a0, $v0
  jr $ra

END: