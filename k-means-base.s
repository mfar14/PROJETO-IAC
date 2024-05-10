#
# IAC 2023/2024 k-means
# 
# Grupo:
# Campus: Alameda
#
# Autores:
# ist1109625, Francisco Pestana
# ist1107357, Andreia Andrade
# ist1109695, Miguel Ribeiro
#
# Tecnico/ULisboa


# ALGUMA INFORMACAO ADICIONAL PARA CADA GRUPO:
# - A "LED matrix" deve ter um tamanho de 32 x 32
# - O input e' definido na seccao .data. 
# - Abaixo propomos alguns inputs possiveis. Para usar um dos inputs propostos, basta descomentar 
#   esse e comentar os restantes.
# - Encorajamos cada grupo a inventar e experimentar outros inputs.
# - Os vetores points e centroids estao na forma x0, y0, x1, y1, ...


# Variaveis em memoria
.data

#Input A - linha inclinada
#n_points:    .word 9
#points:      .word 0,0, 1,1, 2,2, 3,3, 4,4, 5,5, 6,6, 7,7 8,8

#Input B - Cruz
#n_points:    .word 5
#points:     .word 4,2, 5,1, 5,2, 5,3 6,2

#Input C
#n_points:    .word 23
#points: .word 0,0, 0,1, 0,2, 1,0, 1,1, 1,2, 1,3, 2,0, 2,1, 5,3, 6,2, 6,3, 6,4, 7,2, 7,3, 6,8, 6,9, 7,8, 8,7, 8,8, 8,9, 9,7, 9,8

#Input D
#n_points:    .word 30
#points:      .word 16, 1, 17, 2, 18, 6, 20, 3, 21, 1, 17, 4, 21, 7, 16, 4, 21, 6, 19, 6, 4, 24, 6, 24, 8, 23, 6, 26, 6, 26, 6, 23, 8, 25, 7, 26, 7, 20, 4, 21, 4, 10, 2, 10, 3, 11, 2, 12, 4, 13, 4, 9, 4, 9, 3, 8, 0, 10, 4, 10



# Valores de centroids e k a usar na 1a parte do projeto:
centroids:   .word 0,0
k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
#centroids:   .word 0,0, 10,0, 0,10
#k:           .word 3
#L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
#clusters:    




#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff  # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    #jal mainKMeans
    
    #Termina o programa (chamando chamada sistema)
    li a7, 10
    ecall


### printPoint
# Pinta o ponto (x,y) na LED matrix com a cor passada por argumento
# Nota: a implementacao desta funcao ja' e' fornecida pelos docentes
# E' uma funcao auxiliar que deve ser chamada pelas funcoes seguintes que pintam a LED matrix.
# Argumentos:
# a0: x
# a1: y
# a2: cor

printPoint:
    li a3, LED_MATRIX_0_HEIGHT
    sub a1, a3, a1
    addi a1, a1, -1
    li a3, LED_MATRIX_0_WIDTH
    mul a3, a3, a1
    add a3, a3, a0
    slli a3, a3, 2
    li a0, LED_MATRIX_0_BASE
    add a3, a3, a0   # addr
    sw a2, 0(a3)
    jr ra
    
###mudar_k
#muda o valor do k a k=1
mudar_k:
    resto:
    	addi sp, sp, -4
    	sw a0, 0(sp)
    	la a0, k
        sw t1, 0(a0)
        lw a0, 0(sp)
        addi sp, sp, 4
        jr ra
    bne, t0, t1, resto
    jr ra

### cleanScreen
# Limpa todos os pontos do ecr?
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    # POR IMPLEMENTAR (1a parte)
    lw t0, n_points
    la t1, points
    lw a2, white
    ciclo:
        addi sp, sp, -4
        sw ra, 0(sp)
        lw a0, 0(t1)
        addi t1, t1, 4
        lw a1, 0(t1)
        jal printPoint
        lw ra, 0(sp)
        addi sp, sp, 4
        addi t1, t1, 4
        addi t0, t0, -1
        bgt t0, x0, ciclo #limpa os pontos definidos no input
        la t1, centroids
        lw a0, 0(t1)
        addi, t1, t1, 4
        lw a1, 0(t1) 
        addi sp, sp, -4
        sw ra, 0(sp)
        jal printPoint #chama a funcao print para o centroid
        lw ra, 0(sp) #retorna ao ra
        addi sp, sp, 4
    jr ra

    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    # POR IMPLEMENTAR (1a e 2a parte)
    lw t0, n_points
    la t1, points
    la t2, colors
    lw a2, 0(t2)
    forClusters:
        addi sp, sp, -4
        sw ra, 0(sp)
        lw a0, 0(t1) #X
        addi t1, t1, 4
        lw a1, 0(t1) #Y
        jal printPoint
        lw ra, 0(sp)
        addi sp, sp, 4
        addi t1, t1, 4
        addi t0, t0, -1
        bgt t0, x0, forClusters #continua o ciclo
    jr ra


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    # POR IMPLEMENTAR (1a e 2a parte)
    li t0, 1 #numero de centroids
    la t1, centroids
    lw a2, black
    for_centroids:
        addi sp, sp, -4
        sw ra, 0(sp)
        lw a0, 0(t1) #X
        addi t1, t1, 4
        lw a1, 0(t1) #Y
        jal printPoint
        lw ra, 0(sp)
        addi sp, sp, 4
        addi t1, t1, 4
        addi t0, t0, -1
        bgt t0, x0, forClusters #continua o ciclo
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    # POR IMPLEMENTAR (1a e 2a parte)
    lw a0, n_points
    la a1, points
    li t0, 0 #soma X
    li t1, 0 #soma Y
    mv t2, a0
    for_calcula_centroid:
        lw s0, 0(a1)
        add t0, t0, s0
        lw s0, 4(a1)
        add t1, t1, s0
        addi a1, a1, 8
        addi t2, t2, -1
        bgt t2, x0, for_calcula_centroid
        la a1, centroids
        div t0, t0, a0
        sw t0, 0(a1)
        div t1, t1, a0
        sw t1, 4(a1)
    jr ra


### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:

    #1. Coloca k=1 (caso nao esteja a 1)
    # POR IMPLEMENTAR (1a parte)
    lw t0, k
    li, t1, 1
    addi sp, sp, -4
    sw ra, 0(sp)
    jal mudar_k
    lw ra, 0(sp)
    addi sp, sp, 4
 
    #2. cleanScreen
    # POR IMPLEMENTAR (1a parte)
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a2, 4(sp)# guarda na pilha todos os valores
    sw a0, 8(sp)#que serao utilizados na funcao clean
    sw a1, 12(sp)
    jal cleanScreen
    lw ra, 0(sp)
    lw a2, 4(sp)
    lw a0, 8(sp)
    lw a1, 12(sp)#recupera os valores
    addi sp, sp, 16 #"fecha" a pilha

    #3. printClusters
    # POR IMPLEMENTAR (1a parte)
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a2, 4(sp)# guarda na pilha os valores iniciais
    sw a0, 8(sp)
    sw a1, 12(sp)
    jal printClusters
    lw ra, 0(sp)
    lw a2, 4(sp)
    lw a0, 8(sp)
    lw a1, 12(sp)#recupera os valores
    addi sp, sp, 16
    

    #4. calculateCentroids
    # POR IMPLEMENTAR (1a parte)
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    jal calculateCentroids
    lw a2, 12(sp)
    lw a1, 8(sp)
    lw a0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    
    #5. printCentroids
    # POR IMPLEMENTAR (1a parte)
    addi sp, sp, -16
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)
    sw a2, 12(sp)
    jal printCentroids
    lw a2, 12(sp)
    lw a1, 8(sp)
    lw a0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 16
    
    #6. Termina
    jr ra



### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    # POR IMPLEMENTAR (2a parte)
    jr ra


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    # POR IMPLEMENTAR (2a parte)
    jr ra


### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    # POR IMPLEMENTAR (2a parte)
    jr ra
