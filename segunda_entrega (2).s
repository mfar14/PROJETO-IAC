#
# IAC 2023/2024 k-means
# 
# Grupo: 58
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

#Input Test
n_points: .word 14
points: .word 0,0, 0,1, 0,2, 0,3, 1,3, 2,3, 12,12, 13,13, 31,30, 30,31, 30,30, 31,31, 0,31, 1,31

# Valores de centroids e k a usar na 1a parte do projeto:
#centroids:   .word 0,0
#k:           .word 1

# Valores de centroids, k e L a usar na 2a parte do prejeto:
centroids:   .word 0,0, 10,0, 0,10, 10,10
k:           .word 4
L:           .word 10

# Abaixo devem ser declarados o vetor clusters (2a parte) e outras estruturas de dados
# que o grupo considere necessarias para a solucao:
clusters: .zero 128  
ultimo_centroid: .word 0,0 0,0 0,0, 0,0




#Definicoes de cores a usar no projeto 

colors:      .word 0xff0000, 0x00ff00, 0x0000ff, 0xf0e68c # Cores dos pontos do cluster 0, 1, 2, etc.

.equ         black      0
.equ         white      0xffffff



# Codigo
 
.text
    # Chama funcao principal da 1a parte do projeto
    #jal mainSingleCluster

    # Descomentar na 2a parte do projeto:
    jal mainKMeans
    
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
#muda o valor do k para k=1
mudar_k:
    j if_mudar_k #ira verificar a condicao
    resto:
    	addi sp, sp, -4 # Aloca espaco para a pilha
    	sw a0, 0(sp) # Guarda o valor do registo a0
    	la a0, k # O endereco de k fica no registo a0
        sw t1, 0(a0) # Guarda o valor 1 em k
        lw a0, 0(sp)
        addi sp, sp, 4 # Recupera os dados e fecha a pilha
        jr ra # Volta a chamada da funcao
        
    if_mudar_k:
    bne, t0, t1, resto # Se k nao e igual a 1
    jr ra

### cleanScreen
# Limpa todos os pontos do ecran
# Argumentos: nenhum
# Retorno: nenhum

cleanScreen:
    li t0, 33 # Fora do limite
    li t1, 0 
    li a2, white # Guarda a cor branca em a2
    addi sp, sp, -4 # Aloca espaco na pilha
    sw ra, 0(sp) # Guarda o registo de retorno
    ciclo1:
        # Volta a inicializar os valores na coluna
        li t2, 0
    ciclo2:
        mv a1, t2
        mv a0, t1 # Inicializa as variaveis para printPoint
        jal printPoint
        addi t2, t2, 1 # Itera para a seguinte linha
        bne t2, t0, ciclo2 # Limpa os pontos numa coluna
        addi t1, t1, 1 # ja foi uma coluna "apagada"
        bne t1, t0, ciclo1 # Itera para a proxima coluna

    lw ra, 0(sp)
    addi sp, sp, 4   
    jr ra # Retorna ao ponto de chamada

    
### printClusters
# Pinta os agrupamentos na LED matrix com a cor correspondente.
# Argumentos: nenhum
# Retorno: nenhum

printClusters:
    lw t0, n_points # Numero de pontos e carregado para t0
    la t1, points # Enderco da lista dos pontos e carregado para t1
    la a3, clusters # Endereco do vetor identificador de cluster
    addi sp, sp, -4 # Aloca espaco na pilha para armazenar o endereco de retorno 
    sw ra, 0(sp) # Guarda o endereco de retorno 
    forClusters:  # Inicio do ciclo que faz print dos clusters
        lw a0, 0(t1) # X
        addi t1, t1, 4 # Avanca para a posicao seguinte na lista
        lw a1, 0(t1) # Y
        lw t3, 0(a3) # Identificador do primeiro ponto no cluster
        slli t3, t3, 2 # Multiplica por 4
        la t2, colors # Endereco da lista das cores dos pontos e carregado para t2
        add t2, t2, t3 # Novo indice
        lw a2, 0(t2) # Carrega a cor para a2
        addi sp, sp, -4
        sw a3, 0(sp) # Guarda o valor de a3
        jal printPoint  # Chama a funcao printPoint para dar print dos pontos
        lw a3, 0(sp) # Recupera o a3
        addi sp, sp, 4 # Desaloca memoria
        addi t1, t1, 4 # Avanca para o ponto seguinte
        addi t0, t0, -1 # Menos um ponto
        addi a3, a3, 4 # Avanca para o identificador de cluster seguinte
        bgt t0, x0, forClusters # Continua o ciclo
        lw ra, 0(sp) # Restaura o valor do endereco de retorno
        addi sp, sp, 4 # Fecha a pilha
    jr ra
    ###OPTIMIZATION
    # A funcao da primeira entrega foi adaptada de forma a que faca print de cada ponto
    # utilizando diretamente o identificador do cluster como endereco de cor
    # sendo preciso chamar a funcao uma unica vez por iteracao


### printCentroids
# Pinta os centroides na LED matrix
# Nota: deve ser usada a cor preta (black) para todos os centroides
# Argumentos: nenhum
# Retorno: nenhum

printCentroids:
    lw t0, k # Numero de centroids
    la t1, centroids # Coloca o array de centroides em t1
    li a2, black # Carrega preto para a2
    addi sp, sp, -4 # Aloca espaco
    sw ra, 0(sp) # Guarda o endereco de retorno
    for_centroids:
        lw a0, 0(t1) # X
        lw a1, 4(t1) # Y
        jal printPoint # Chama a funcao auxiliar 
        addi t1, t1, 8 # Avanca para o centroide seguinte
        addi t0, t0, -1  # Retira 1 a contagem de centroides
        bgt t0, x0, for_centroids # Continua o ciclo
        lw ra, 0(sp) # Restaura o endereco de retorno
        addi sp, sp, 4 # Fecha a pilha
    jr ra
    

### calculateCentroids
# Calcula os k centroides, a partir da distribuicao atual de pontos associados a cada agrupamento (cluster)
# Argumentos: nenhum
# Retorno: nenhum

calculateCentroids:
    la a3, centroids # Sera alterada na memoria a lista de centroids
    lw t4, k # Inicializamos t4 com o valor de k
    addi t6, t4, -1
    slli t6, t6, 3 # Muktiplica 8(k-1) assim tirando o indice do ultimo centroid
    add a3, a3, t6 # O primeiro centroid a calcular vai ser o ultimo
    j for_cada_Cluster
    
    final_calcula_Centroids:
        div t0, t0, t3 # (media de X)
        sw t0, 0(a3) # Guarda na coordenada X do centroid
        div t1, t1, t3 # (media de Y)
        sw t1, 4(a3) # Guarda na coordenada Y do centroid
        addi a3, a3, -8 # Centroid anterior
        bgt t4, x0, for_cada_Cluster # Quando o indice e zero, para
        jr ra # Retorna
        
    
    adiciona_ponto:
        lw s0, 0(a1) # Carrega a coordenda X do ponto atual para s0
        add t0, t0, s0 # Adiciona ao somatorio X
        lw s0, 4(a1) # Carrega a coordenda Y do ponto atual para s0
        add t1, t1, s0 # Adiciona ao somatorio Y
        addi t3, t3, 1 # Mais um ponto
        addi a1, a1, 8 # Avanca para o ponto seguinte da lista
        addi a2, a2, 4 # Seguinte no vetor clusters
        addi t2, t2, -1 # Menos um ponto
        bgt t2, x0, for_calcula_centroid
        j final_calcula_Centroids
    
    for_cada_Cluster:
        addi t4, t4, -1 # Novo indice
        lw a0, n_points # Carrega numero de pontos para a0
        la a1, points  # Carrega a lista de pontos para a1
        li t0, 0 # Soma X
        li t1, 0 # Soma Y
        mv t2, a0
        li t3, 0 # Este registo ira guardar o numero de pontos que pertencem a um mesmo cluster
        la a2, clusters # Endereco do vetor de clusters
        for_calcula_centroid: # Loop para calcular os centroides
            lw t5, 0(a2) # Guarda o identificador do primeiro ponto do vetor clusters
            beq t4, t5, adiciona_ponto
            addi a1, a1, 8 # Avanca para o ponto seguinte da lista
            addi a2, a2, 4 # Seguinte no vetor clusters
            addi t2, t2, -1 # Subtrai 1 ao numero de pontos
            bgt t2, x0, for_calcula_centroid # Se ainda houver pontos por calucular continua o ciclo
            j final_calcula_Centroids

        ###OPTIMIZATION
        #Adaptacao da funcao da primeira entrega que faz o calculo de cada
        #centroide dependendo dos pontos associados ao mesmo,
        #nao sendo necessaria a chamada da funcao tres vezes por cada cluster
        

### mainSingleCluster
# Funcao principal da 1a parte do projeto.
# Argumentos: nenhum
# Retorno: nenhum

mainSingleCluster:

    #1. Coloca k=1 (caso nao esteja a 1)
    lw t0, k  # Carrega o valor de k para t0
    li, t1, 1 # Registo t1 fica com o valor 1
    addi sp, sp, -4 # Aloca memoria na pilha
    sw ra, 0(sp) # Guarda o endereco de retorno
    jal mudar_k # Chama a funcao auxiliar
    lw ra, 0(sp) # Restaura o endereco de retorno
    addi sp, sp, 4 # Desaloca espaco na pilha
 
    #2. cleanScreen
    addi sp, sp, -16  # Aloca espaco na pilha
    sw ra, 0(sp)
    sw a2, 4(sp)# Guarda na pilha todos os valores
    sw a0, 8(sp)# Que serao utilizados na funcao clean
    sw a1, 12(sp)
    jal cleanScreen # Chama a funcao cleanScrean para limpar a tela
    lw ra, 0(sp) # Restaura os valores guardados na pilha
    lw a2, 4(sp)
    lw a0, 8(sp)
    lw a1, 12(sp)
    addi sp, sp, 16 # "Fecha" a pilha

    #3. printClusters
    addi sp, sp, -16 # Aloca espaco na pilha
    sw ra, 0(sp)
    sw a2, 4(sp)# Guarda na pilha os valores iniciais
    sw a0, 8(sp)# A ser utilizados na funcao printClusters
    sw a1, 12(sp)
    jal printClusters  # Chama a funcao printClusters para dar print aos clusters
    lw ra, 0(sp)
    lw a2, 4(sp)
    lw a0, 8(sp)
    lw a1, 12(sp)# Recupera os valores guardados na pilha
    addi sp, sp, 16 # Desaloca memoria na pilha
    

    #4. calculateCentroids
    addi sp, sp, -16 # Aloca espaco na pilha
    sw ra, 0(sp)
    sw a0, 4(sp) # Guarda na pilha os valores iniciais
    sw a1, 8(sp) # A ser utilizados na funcao calculateCentroids
    sw a2, 12(sp)
    jal calculateCentroids # Chama a funcao
    lw a2, 12(sp)
    lw a1, 8(sp)
    lw a0, 4(sp)
    lw ra, 0(sp) # Restaura os valores iniciais
    addi sp, sp, 16 # Desaloca espaco na pilha
    
    #5. printCentroids
    addi sp, sp, -16 #Aloca espaco
    sw ra, 0(sp)
    sw a0, 4(sp)
    sw a1, 8(sp)# Guarda todos os valores iniciais dos registos
    sw a2, 12(sp)# A ser manipulados pela funcao
    jal printCentroids # Chama a funcao printCentroids para dar print aos centroides
    lw a2, 12(sp)
    lw a1, 8(sp)
    lw a0, 4(sp)
    lw ra, 0(sp) # Restaura todos os valores
    addi sp, sp, 16  # Desaloca espaco na pilha
    
    #6. Termina
    jr ra

###initializeSeed
# Inicializa um valor para a seed baseado nos centroids anteriores
initializeSeed:
    li a7, 30 # Numero do system call
    ecall # Retorna os milisegundos no registo a0
    neg a0, a0 # O modulo do valor dado
    mv t3, a0
    jr ra # Retorna

###initializeCentroids
# Inicializa os valores dos centroid pseudo-aleatoriamente

initializeCentroids:
    la a0, centroids  # Carrega o endereco dos centroids para a0
    lw t0, k  # Carrega o valor de k para t0
    addi sp, sp, -16  # Aloca memoria na pilha
    sw ra, 0(sp)  # Guarda o endereco de retorno
    sw a0, 4(sp) 
    sw a7, 8(sp)  # Guarda os valores a ser alterados em initializeSeed
    sw a1, 12(sp) # Este e alterado pela chamada ao sistema
    jal initializeSeed
    lw ra, 0(sp)  
    lw a0, 4(sp) 
    lw a7, 8(sp)  # Recupera todos os valores
    lw a1, 12(sp)
    addi sp, sp, 16  # Desaloca memoria na pilha
    li t4, 33  # Define o limite superior para a gerar pseudo-aleatoria
    for_initializeCentroids:
        lw t1, 0(a0)  # Carrega o valor de X do centroid para t1
        lw t2, 4(a0)  # Carrega o valor de Y do centroid para t2
        add t1, t1, t3                            
        add t2, t2, t3 # Adiciona cada valor com a seed
        mul t1, t1, t0
        mul t2, t2, t0 # Multiplica cada ponto com o contador
        remu t1, t1, t4 # Calcula o resto da divisao pelo limite superior
        remu t2, t2, t4 # Este resto sera entre 0 e 31, portanto esta nos limites da LED matrix
        sw t1, 0(a0)  # Armazena o valor pseudo-aleatorio no endereco do centroid
        sw t2, 4(a0)
        addi a0, a0, 8  # Avanca para o proximo centroid
        addi t0, t0, -1  # Ja foi inicializado um vetor
        bgtz t0, for_initializeCentroids  # Continua o loop se ainda houver centroids
    jr ra

### manhattanDistance
# Calcula a distancia de Manhattan entre (x0,y0) e (x1,y1)
# Argumentos:
# a0, a1: x0, y0
# a2, a3: x1, y1
# Retorno:
# a0: distance

manhattanDistance:
    sub t0, a0, a2 # x0 - y0
    bgtz t0, x_maior # Caso seja um valor positivo, salta ao proximo calculo
    neg t0, t0 # Se for  negativo,  calcula o modulo
    
    x_maior:
    sub t1, a1, a3 # x1 - y1
    bgtz t1, y_maior # Mesma logica para a segunda coordenada
    neg t1, t1 # Caso seja negativo, calcula o modulo
    
    y_maior:
    add a0, t0, t1 # a0 fica com o valor da distancia calculada
    jr ra # Retorna ao ponto de chamada


### nearestCluster
# Determina o centroide mais perto de um dado ponto (x,y).
# Argumentos:
# a0, a1: (x, y) point
# Retorno:
# a0: cluster index

nearestCluster:
    la a5, centroids
    addi sp, sp, -4
    sw ra, 0(sp) # Guarda o endereco de retorno anterior
    li t1, 0 # t1 vai guardar o indice da menor distancia
    lw t2, k # Numero de centroids
    li t3, 0 # t3 funciona como o endereco do centroid
    li t6, 70 # Iniciliza t6 com uma distancia superior e maior distancia possivel
    for_nearestC:
        lw a2, 0(a5)
        lw a3, 4(a5) # Inicializa as coordenadas do centroid
        addi sp, sp, -8 # Aloca memoria na pilha
        sw a0, 0(sp) # Guarda o valor de a0 (X)
        sw t1, 4(sp) # Guarda o t1, dado que sera alterado em manhattanDistance
        jal manhattanDistance
        blt a0, t6, save_Distance #caso encontre uma nova distancia menor que a anteiror, guarda-a
        lw a0, 0(sp) # Recupera o valor do a0 (X)
        lw t1, 4(sp) # Recupera o valor de t1 (indice da menor distancia)
        addi sp, sp, 8 # Desaloca memoria
        addi a5, a5, 8
        addi t3, t3, 1
        blt t3, t2, for_nearestC # Se ainda existem centroids continua o ciclo
        mv a0, t1 # Caso terminal, guarda o endereco em a0
        lw ra, 0(sp) # Recupera o endereco de retorno
        addi sp, sp, 4 # Desaloca memoria na pilha
        jr ra
        save_Distance:
            mv t6, a0 # t6 fica com a nova distancia
            lw a0, 0(sp) 
            lw t1, 4(sp)# Recupera os valores
            addi sp, sp, 8 # Recupera o valor do a0 e desaloca memoria
            mv t1, t3 # O indice do centroid mais perto e guardado
            addi a5, a5, 8 # Itera para o proximo centroid
            addi t3, t3, 1 # Indice seguinte
            blt t3, t2, for_nearestC
            mv a0, t1 # Caso terminal
            lw ra, 0(sp) # Recupera o endereco de retorno
            addi sp, sp, 4 # Desaloca memoria na pilha
            jr ra # Volta ao ponto de chamada


### assignClusters
# Por cada ponto do vetor points determina o indice do cluster mais proximo
assignClusters:
la a2, points # Carrega o endereco dos pontos
la a3, clusters # Carrega o endereco dos clusters
lw t1, n_points # Numero de pontos
addi sp, sp, -4
sw ra, 0(sp) # Guarda o endereco de retorno
for_assignCluster:
    lw a0, 0(a2)
    lw a1, 4(a2) # Carrega as coordenadas do ponto
    addi sp, sp, -16
    sw a5, 0(sp) # Guarda o endereco de centroids
    sw a2, 4(sp) # Guarda o endereco de points
    sw a3, 8(sp) # Guarda o endereco de clusters
    sw t1, 12(sp) # Guarda o t1 que é alterado na funcao nearestCluster
    jal nearestCluster # Chama a funcao auxiliar
    lw t1, 12(sp)
    lw a3, 8(sp)
    lw a2, 4(sp) # Recupera todos os dados guardados na pilha
    lw a5, 0(sp)
    addi sp, sp, 16 # Desaloca memoria
    sw a0, 0(a3) 
    addi a3, a3, 4 # Proximo lugar no vetor clusters
    addi a2, a2, 8 # Proximo ponto
    addi t1, t1, -1 # ja foi visto um ponto
    bgtz t1, for_assignCluster # Continua o ciclo se ainda existem pontos
    lw ra, 0(sp) # Recupera o endereco de retorno
    addi sp, sp, 4 # Desaloca memoria
    jr ra #retorna

    ####OPTIMIZATION
    #Funcao que determina o centroide proximo de um ponto e 
    #o identifica automaticamente no vetor clusters, de forma
    #a ser necessaria a chamada de uma unica funcao para identificar
    #a que cluster pertence cada ponto

### copy_Centroids
###Esta funcao copia os centroides atuais para o vetor de ultimos centroides
copyCentroids:
la a3, centroids # Carrega o endereco do vetor clusters
la a4, ultimo_centroid # Carrega o endereco do vetor ultimo centroid
lw t0, k # Carrega o valor de k
for_copyCentroids:
    lw t1, 0(a3) # X Centroid atual
    lw t2, 4(a3) # Y Centroid atual
    sw t1, 0(a4)
    sw t2, 4(a4) # Copia as coordenadas para o vetor de ultimos centroides
    addi a3, a3, 8 #  Avanca para o proximo centroid
    addi a4, a4, 8 # Avanca para o proximo centroid dos anteriores
    addi t0, t0, -1 # Menos um centroid
    bgt t0, x0, for_copyCentroids # Continua o ciclo
    jr ra # Retorna ao ponto de chamada

    ###OPTIMIZATION
    #Caso existam mudancas nos valores dos centroides, sera necessaria
    #outra iteracao. Esta funcao auxiliar permite que funcao de verificacao
    #(verifyChanges) tambem guardar os novos centroides calculados

### verifyChanges
#Verifica se os clusters mudaram em relacao ao ciclo anterior
###Retorno: a0=1 se houve mudancas, a0=0 caso contrario
verifyChanges:
    la a3, centroids # Carrega o endereco do vetor clusters
    la a4, ultimo_centroid # Carrega o endereco do vetor ultimo centroid
    lw t0, k # Carrega o valor de k
    addi sp, sp, -4
    sw ra, 0(sp) # Guarda o endereco de retorno
    for_verifyChanges:
        lw t1, 0(a3) # X centroid atual
        lw t2, 0(a4) # X centroid anterior
        lw t3, 4(a3) # Y centroid atual
        lw t4, 4(a4) # Y centroid anterior
        bne t1, t2, has_changed # Houve mudanca
        bne t3, t4, has_changed # Houve mudanca
        addi a3, a3, 8 # Avanca para o proximo centroid
        addi a4, a4, 8 # Avanca para o proximo centroid dos anteriores
        addi t0, t0, -1 # Menos um centroid
        bgt t0, x0, for_verifyChanges # Continua o ciclo
        li a0, 0 # Caso nao haja mudancas, a0 fica com o valor 0
        # O valor 0 indicara "falso", isto e, que nao houve mudancas
        lw ra, 0(sp) # Recupera o endereco de retorno
        addi sp, sp, 4 # Desaloca memoria
        jr ra # Retorna ao ponto de chamada


        has_changed:
            li a0, 1 # Caso haja mudancas, a0 fica com o valor 1
            jal copyCentroids # Chama a funcao auxiliar
            lw ra, 0(sp) # Recupera o endereco de retorno
            addi sp, sp, 4 # desaloca memoria
            jr ra # Retorna ao ponto de chamada



### mainKMeans
# Executa o algoritmo *k-means*.
# Argumentos: nenhum
# Retorno: nenhum

mainKMeans:  
    lw t5, L # O contador de iteracoes
    
    # Chama a funcao de inicializacao
    addi sp, sp, -8
    sw ra, 0(sp)
    sw a0, 4(sp)
    jal initializeCentroids
    lw a0, 4(sp)
    lw ra, 0(sp)
    addi sp, sp, 8
    
    for_KMeans:
        beq t5, x0, end_KMeans # A Cada ciclo verifica se ainda existem iteracoes
        li a0, 0 # Inicializa o identificador de mudancas com 0
        
        # Inicia o loop por limpar o ecran, para poder mudar o local dos centroides
        addi sp, sp, -16
        sw ra, 0(sp)
        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a3, 12(sp)
        jal cleanScreen
        lw a3, 12(sp)
        lw a1, 8(sp)
        lw a0, 4(sp)
        lw ra, 0(sp)
        addi sp, sp, 16
        
        # Atribui cada um dos pontos a um cluster
        addi sp, sp, -20
        sw ra, 0(sp)
        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a2, 12(sp)
        sw a3, 16(sp)
        jal assignClusters
        lw a3, 16(sp)
        lw a2, 12(sp)
        lw a1, 8(sp)
        lw a0, 4(sp)
        lw ra, 0(sp)
        addi sp, sp, 20
        
        # Atribui um centroide a cada cluster
        addi sp, sp, -24
        sw ra, 0(sp)
        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a2, 12(sp)
        sw a3, 16(sp)
        sw t5, 20(sp)
        jal calculateCentroids
        lw t5, 20(sp)
        lw a3, 16(sp)
        lw a2, 12(sp)
        lw a1, 8(sp)
        lw a0, 4(sp)
        lw ra, 0(sp)
        addi sp, sp, 24

        # Coloca os clusters na tela
        addi sp, sp, -20
        sw ra, 0(sp)
        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a2, 12(sp)
        sw a3, 16(sp)
        jal printClusters
        lw a3, 16(sp)
        lw a2, 12(sp)
        lw a1, 8(sp)
        lw a0, 4(sp)
        lw ra, 0(sp)
        addi sp, sp, 20
        
        # Coloca os centroides na tela
        addi sp, sp, -20
        sw ra, 0(sp)
        sw a0, 4(sp)
        sw a1, 8(sp)
        sw a2, 12(sp)
        sw a3, 16(sp)
        jal printCentroids
        lw a3, 16(sp)
        lw a2, 12(sp)
        lw a1, 8(sp)
        lw a0, 4(sp)
        lw ra, 0(sp)
        addi sp, sp, 20
        
        # Finalmente verifica se entre esta itercao e a anterior houve alguma alteracao
        addi sp, sp, -12
        sw ra, 0(sp)
        sw a3, 4(sp)
        sw a4, 8(sp)
        jal verifyChanges
        lw a4, 8(sp)
        lw a3, 4(sp)
        lw ra, 0(sp)
        addi sp, sp, 12
        
        addi t5, t5, -1
        bne a0, x0, for_KMeans # Caso os centroids tenham mudado faz mais uma iteracao
        j end_KMeans # Os centroids nao mudaram, termina   
        
    end_KMeans: # Termina o programa
    jr ra # Retorna a funcao

