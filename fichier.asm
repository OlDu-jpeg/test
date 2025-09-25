# ===== Section donnees =====  
.data
    #grille: .asciiz "415638972362479185789215364926341758138756429574982631257164893843597216691823547"
    grille: .asciiz "120056789690078215587291463352184697416937528978625341831542976269713854745869132"


   
    indice: .byte 0   
    disp:   .asciiz "DISPLAY \n"

                                                                                        
# ===== Section code =====  
.text
# ----- Main ----- 

main:
 
    jal transformAsciiValues

    jal displayGrille   
    jal addNewLine 
    
    la $a0, grille	# ecriture de @grille dans argument 1
    jal solve_sudoku
    jal displayGrille
    
    j exit


# ----- Fonctions ----- 


# ----- Fonction addNewLine -----  
# objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0
addNewLine:
    li      $v0, 11
    li      $a0, 10
    syscall
    jr $ra



# ----- Fonction displayGrille -----   
# Affiche la grille.
##ajout d'un saut à ligne tout les neuf chiffre
# Registres utilises : $v0, $a0, $t[0-2]
displayGrille:  
    la      $t0, grille         # charge adresse de grille en $t0
    add     $sp, $sp, -4        # Sauvegarde de la reference du dernier jump ## sauvegarde du pointeur de la pile en cas d'appel de fonction qui ecraserait le $ra 
    sw      $ra, 0($sp)		# stocke $ra dans l'adresse dans laquelle ona fait de la place juste au dessus $sp
    li      $t1, 0		# $t1 = 0, t1 est le compteur de la boucle qui parcours la chaine de 81 chiffres
    li      $t9, 9		## stocke 9 
    boucle_displayGrille:
        bge     $t1, 81, end_displayGrille     # Si $t1 est plus grand ou egal a 81 alors branchement a end_displayGrille
            add     $t2, $t0, $t1           # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau) donc $t2 sera l'indice du tableau
            lb      $a0, ($t2)              # load byte at $t2(adress) in $a0
            li      $v0, 1                  # code pour l'affichage d'un entier, tableau[$t2]
            syscall
            li      $a0, 32                 # lcharge 32 (ascii espace) in $a0
            li      $v0, 11                  # code pour l'affichage d'un charactere, un espace
            syscall            
            add     $t1, $t1, 1             # $t1 += 1;  incremantation du compteur
            div $t1, $t9                    # divise indice par 9
            mfhi $t8             	    # stocke le reste dans $t8
            bne $t8, $zero, boucle_displayGrille	# si le reste est different de zero, alors boucle normalement, sinon appel de addnewline
            jal addNewLine
            j boucle_displayGrille
    end_displayGrille:
        lw      $ra, 0($sp)                 # On recharge la reference du dernier jump 
        add     $sp, $sp, 4                 # et on remet le pointeur de la pile à sa place
    jr $ra


# ----- Fonction transformAsciiValues -----   
# Objectif : transforme la grille de ascii a integer
# Registres utilises : $t[0-3]
transformAsciiValues:  
    add     $sp, $sp, -4
    sw      $ra, 0($sp)		# sauvergarde de l'adresse du dernier jump
    la      $t3, grille		# charge adresse de grille dans $t3
    li      $t0, 0		# $t0 est un compteur de boucle?
    boucle_transformAsciiValues:			#								boucle while
        bge     $t0, 81, end_transformAsciiValues 	# si $t0 > 81, saut à end					condition d'arret	
            add     $t1, $t3, $t0			# t1 <- t3 + t0, indice = adresse de grille + compteur		charge la valeur
            lb      $t2, ($t1)  			# charge en byte la valeur de $t1 (indice) vers $t2 (pourquoi charge en bytes?)
            sub     $t2, $t2, 48                     	# y soustrait 48						la modifie
            sb      $t2, ($t1)				# le remet dans $t1						la sauvegarde la valeur dans la case mémoire source
            add     $t0, $t0, 1				# 								incrémente le compteur				
        j boucle_transformAsciiValues			# 								retour au debut du while
    end_transformAsciiValues:
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra


# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat dans : $v0
# Registres utilises : $a0
getModulo: 
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)
    boucle_getModulo:
        blt     $a0, $a1, end_getModulo
            sub     $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    lw      $ra, 0($sp)
    add     $sp, $sp, 4
    jr $ra


#################################################
#               A completer !                   #
#                                               #
# Nom et prenom binome 1 : Olivier DUMAY        #
# Nom et prenom binome 2 : Patrick SKALA        #
#                                               #

	################ Fonction check_n_column  ################												CHECK_N_COLUMN

  # Envoie dans check un tableau (tabacheck), contenant les 9 valeurs d'une colonne n de la grille
  #
  # Entrée: $a0, adresse de la grille
  #         $a1, entier, numero de la ligne à verifier
  #
  # Local:  $t0, adresse de la grille
  #         $t1, tableau de 9 entiers, tabacheck
  #
  #         $t2, $t3, $t4, entier, pour manipuler la sélection des indices
  #         $t5, entier, compteur de boucle
  #         $t7, entier, fin de compteur
  # Sortie: $a2, entier, booléen inversé (retour de check)
  
check_n_columns:  

  #- prologue
  addi $sp, $sp, -44	# décrementation de la pile
  sw $ra, 0($sp)	# sauvegarde de $ra
  sw $a0, 4($sp) 	# sauvegarde de l'adresse de la grille dans la pile  
  la $t1, 8($sp)	# éciture de l'adresse de tabacheck[0] dans $t1, cette case et les 8 prochaines cases sont le tableau tabacheck  


  #- corps de la fonction
  li $t5, 0		# initialisation compteur
  li $t7 ,8   		# initialisation fin de compteur
  sub $a1, $a1, 1		# n<- n-1
  
  # selection des indices de la n-ième colonne de la grille dans tabacheck,  numéro de colonne-1 + (compteur*9)
  boucle_check_n_column: 	
  bgt  $t5, $t7, check_n_column_fin

    li $t2, 9
    mul $t3, $t5, $t2		# t3 <- compteur*9 
    add $t4, $a1, $t3		# t4 <- (n-1) + (compteur*9)
    add $t4, $t4, $a0
    lb $t2, ($t4)		# écrit la valeur de grille[t4] 	(cad: t2 <- grille[(n-1) + (compteur*9)])
    add $t6, $t1, $t5
    sb $t2, ($t6)		# écrit t2 dans tabacheck[compteur]  	(cad: tabacheck[compteur] <- grille[(n-1) + (compteur*9)])
    
    addi $t5, $t5, 1		# incrémentation du compteur
    j boucle_check_n_column
    
  check_n_column_fin:
  
  move $a0, $t1 		# écriture de l' adresse de tabacheck dans argument 1
  jal check  			# appel de check(tabacheck), retour en $a2, pas besoin d'y toucher
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 44	# incrémentation du pointeur de la pile   
  jr $ra		  
  


	################ Fonction check_n_row  ################												CHECK_N_ROW

  # Envoie dans check un tableau (tabacheck), contenant les 9 valeurs d'une ligne n de la grille
  #
  # Entrée: $a0, adresse de la grille
  #         $a1, entier, numero de la ligne à verifier
  #
  # Local:  $t0, adresse de la grille
  #         $t1, tableau de 9 entiers, tabacheck
  #
  #         $t2, $t3, $t4, entier, pour manipuler la sélection des indices
  #         $t5, entier, compteur de boucle
  #         $t7, entier, fin de compteur
  # Sortie: $a2, entier, booléen inversé (retour de check)
  
  
check_n_rows:  

  #- prologue
  addi $sp, $sp, -44	# décrementation de la pile
  sw $ra, 0($sp)	# sauvegarde de $ra
  sw $a0, 4($sp) 	# sauvegarde de l'adresse de la grille dans la pile  
  la $t1, 8($sp)	# éciture de l'adresse de tabacheck[0] dans $t1, cette case et les 8 prochaines cases sont le tableau tabacheck  


  #- corps de la fonction
  li $t5, 0		# initialisation compteur
  li $t7 , 8   		# initialisation fin de compteur
  sub $a1, $a1, 1		# n<- n-1
  
  # selection des indices de la n-ième ligne de la grille dans tabacheck (de (n-1)*9 à (n-1)*9+8)
  li $t2, 9
  mul $t4, $a1, $t2	# t4 <- numero de ligne*9 
  
  boucle_check_n_row: 	
  bgt  $t5, $t7, check_n_row_fin
    
    add $t2, $t5, $t4		# $t2 <- compteur + ((n-1)*9)
    add $t2, $t2, $a0
    lb $t3, ($t2)		# écrit la valeur de grille[t2] 	(cad: t3 <- grille[compteur+(n-1)*9])
    add $t8, $t1, $t5
    sb $t3, ($t8)		# écrit t3 dans tabacheck[compteur]  	(cad: tabacheck[compteur] <- grille[compteur+(n-1)*9])
    
    addi $t5, $t5, 1		# incrémentation du compteur
    j boucle_check_n_row
    
  check_n_row_fin:
  
  move $a0, $t1 		# écriture de l' adresse de tabacheck dans argument 1
  jal check  			# appel de check(tabacheck), retour en $a2, pas besoin d'y toucher
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 44	# incrémentation du pointeur de la pile   
  jr $ra		  
  


	################ Fonction check_n_square  ################											CHECK_N_SQUARE
	
  # Envoie dans check les numeros d'une colonne n de la grille, en selectionnant les bons indices
  #
  # Entrée: $a0, adresse de la grille
  #         $a1, entier, numero de la ligne à verifier
  #
  # Local:
  #         $s1, tableau de 9 entiers, tabacheck
  #         $t0, entier, premier indice du carré
  #         $t1, $t2, $t3 entier, des compteurs de boucle
  #         $t4, entier, fin de compteur
  #         $t5, entier, pour manipuler la sélection des indices
  #         $t6, entier, pour manipuler la sélection des indices
  #         $t7, entier, pour manipuler la sélection des indices
  # Sortie: $a2, entier, booléen inversé (retour de check)




check_n_square:    

  #- prologue
  addi $sp, $sp, -40	# décrementation de la pile
  sw $ra, 0($sp)	# sauvegarde de $ra
  la $s1, 4($sp)	# stock l'adresse de tabacheck (dans la pile) dans $s1
  
  li $t1, 0		# initialisation compteur1
  li $t2, 0		# initialisation compteur2
  li $t3, 0		# initialisation compteur3
  li $t4, 2   		# initialisation fin de compteur
  
  ## selection des bons indices grace à 2 boucle for à 3 itérations (3x3 case)
  # premier indice du carré selectionner en brut: écrit dans $t0
  addi $t1, $t1, 1
  beq $a1, $t1, premIndiceUn
  addi $t1, $t1, 1
  beq $a1, $t1, premIndiceDeux
  addi $t1, $t1, 1
  beq $a1, $t1, premIndiceTrois
  addi $t1, $t1, 1
  beq $a1, $t1, premIndiceQuatre
  addi $t1, $t1, 1
  beq $a1, $t1, premIndiceCinq
  addi $t1, $t1, 1
  beq $a1, $t1, premIndiceSix
  addi $t1, $t1, 1
  beq $a1, $t1, premIndiceSept
  addi $t1, $t1, 1
  beq $a1, $t1, premIndiceHuit
  addi $t1, $t1, 1
  beq $a1, $t1, premIndiceNeuf
  
  premIndiceUn: li $t0, 0
  j fin_decl_premier_indice
  premIndiceDeux: li $t0, 3
  j fin_decl_premier_indice
  premIndiceTrois: li $t0, 6
  j fin_decl_premier_indice
  premIndiceQuatre: li $t0, 27
  j fin_decl_premier_indice
  premIndiceCinq: li $t0, 30
  j fin_decl_premier_indice
  premIndiceSix: li $t0, 33
  j fin_decl_premier_indice
  premIndiceSept: li $t0, 54
  j fin_decl_premier_indice
  premIndiceHuit: li $t0, 57
  j fin_decl_premier_indice
  premIndiceNeuf: li $t0, 60
  
  fin_decl_premier_indice:
  li $t1, 0
  
  # double boucle a trois itération: 3 indice de 3 ligne
  boucle_check_n_square: 	
    # indice $t1 de 0 à 8, pour l'indice de tabacheck
    bgt  $t2, $t4, fin_compteur_i #  premieère boucle pour i de 0 à 2 (déplacement dans la ligne)
  
     boucle_check_n_square2: 
       bgt $t3, $t4, boucle_check_n_square_fin # deuxieme boucle for j de 0 à 2 (déplacement dans les colonnes), stop la boucle quand j>2
       
         li $t7, 9
         mul $t5, $t3, $t7      # j*9
         add $t5, $t5, $t2	# (j*9)+i
    	 add $t5, $t5, $t0      # (j*9)+i+ premier indice
    	 add $t5, $t5, $a0
	 lb $t6, ($t5)		# écriture de la valeur de grille[(j*9)+ i + premier indice] dans $t6
    	 add $t7, $t1, $s1 		
    	 sb $t6, ($t7) 		# écriture de la valeur de $t6 dans tabacheck, tabacheck(t1) <- grille[(j*9)+ i + premier indice]
         
         addi $t1, $t1, 1	# incrémentation de t1
         addi $t2, $t2, 1       # incrémentation de i
         j boucle_check_n_square				
    							
    fin_compteur_i:  	# tous les 3 i, incrémentation de j	
    li $t2, 0 		# reset de i à 0
    addi $t3, $t3, 1	# incrémentation de j
    j boucle_check_n_square2
    									
    
  boucle_check_n_square_fin:
  move $a0, $s1 		# écriture de l' adresse de tabacheck dans argument 1
  jal check  			# appel de check(tabacheck), retour en $a2, pas besoin d'y toucher
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 40	# incrémentation du pointeur de la pile   
  jr $ra		  
  


	################ Fonction check_columns  ################                               						CHECK_COLUMNS                                                                    

  # Appels des check_n_columns en y envoyant la grille et le numero de ligne, 
  # et additionne les booleens (booléen inversé! VRAI=0, FAUX=1), en retour de check_n_columns, si l'addition fait 0, renvoie VRAI  
  #
  # Entrée: $a0, tableau d'entier, grille
  # Local: 
  #         $t1, entier, compteur de boucle 
  #         $t2, entier, somme des retour de check_n_column
  #
  #         $t7, entier, fin de compteur
  # Sortie: $a2, booléen inversé




check_columns:  
  #- prologue
  addi $sp, $sp, -20	# décrementation de la pile
  sw $ra, 0($sp)	# sauvegarde de $ra
  sw $a0, 4($sp) 	# sauvegarde de l'adresse de la grille dans la pile  
  
  #- corps de la fonction
  
  li $t2, 0		# déclaration de la somme des retours de check_n_columns
  li $t1, 1		# déclaration compteur boucle
  li $t7, 9		# déclaration fin de compteur boucle
  boucle_check_columns:
  bge $t1, $t7, boucle_check_columns_fin

    # sauvergarde/restauration des paramètres de la fonction pour effectuer un appel d'une autre fonction 
    lw $a0, 4($sp)		# écriture de l'adresse la grille en argument 1
    move $a1, $t1 		# ecriture du numéro de ligne en argument 2
    sw $t1, 8($sp)		# sauvegarde de $t1 dans la pile
    sw $t7, 12($sp)		# sauvegarde de $t7 dans la pile
    sw $t2, 16($sp)		# sauvegarde de $t2 dans la pile
     
    jal check_n_columns 		# retour en $a2 (retour de check)
    
    lw $t2, 16($sp)		# restauration de $t2 depuis la pile
    lw $t7, 12($sp)		# restauration de $t7 depuis la pile
    lw $t1, 8($sp)		# restauration de $t1 depuis la pile
    lw $t0, 4($sp)		# restauration de l'adresse la grille depuis la pile
    
    
    add $t2, $t2, $a2			# ajout du retour à $t2
    bnez $t2, boucle_check_rows_fin_faux 	# test: si un des check à rendu FAUX, stop la fonction et renvoie FAUX, sinon la boucle continue
    
      addi $t1, $t1, 1	# incrémentation compteur
      j boucle_check_columns
 
 
  boucle_check_columns_fin:
  li $a2, 0 		# écriture de VRAI dans $a2 (cad 0, booléen inversé pour une détection d'au moins un retour FAUX)
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 20	# incrémentation du pointeur de la pile 
  jr $ra
  
  boucle_check_columns_fin_faux:
  li $a2, 1		# écriture de FAUX dans $a2 (cad 1, booléen inversé pour une détection d'au moins un retour FAUX)
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 20	# incrémentation du pointeur de la pile 
  jr $ra
  
  
	################ Fonction check_rows  ################												CHECK_ROWS

  # Appels des check_n_row en y envoyant la grille et le numero de ligne, 
  # et additionne les booleens (booléen inversé! VRAI=0, FAUX=1), en retour des check_n_rows, si l'addition fait 0, renvoie VRAI  
  #
  # Entrée: $a0, tableau d'entier, grille
  # Local: 
  #         $t1, entier, compteur de boucle 
  #         $t2, entier, somme des retour de check_n_row
  #
  #         $t7, entier, fin de compteur
  # Sortie: $a2, booléen inversé

check_rows:  

  #- prologue
  addi $sp, $sp, -20	# décrementation de la pile
  sw $ra, 0($sp)	# sauvegarde de $ra
  sw $a0, 4($sp) 	# sauvegarde de l'adresse de la grille dans la pile  
  
  #- corps de la fonction
  li $t2, 0		# déclaration de la somme des retours de check_n_rows
  li $t1, 1		# déclaration compteur boucle
  li $t7, 9		# déclaration fin de compteur boucle
  boucle_check_rows:
  bge $t1, $t7, boucle_check_rows_fin
 
    # sauvergarde/restauration des paramètres de la fonction pour effectuer un appel d'une autre fonction 
    lw $a0, 4($sp)		# écriture de l'adresse la grille en argument 1
    move $a1, $t1 		# ecriture du numéro de ligne en argument 2
    sw $t1, 8($sp)		# sauvegarde de $t1 dans la pile
    sw $t7, 12($sp)		# sauvegarde de $t7 dans la pile
    sw $t2, 16($sp)		# sauvegarde de $t2 dans la pile
     
    jal check_n_rows 		# retour en $a2 (retour de check)
    
    lw $t2, 16($sp)		# restauration de $t2 depuis la pile
    lw $t7, 12($sp)		# restauration de $t7 depuis la pile
    lw $t1, 8($sp)		# restauration de $t1 depuis la pile
    lw $t0, 4($sp)		# restauration de l'adresse la grille depuis la pile
    
    
    add $t2, $t2, $a2			# ajout du retour à $t2
    bnez $t2, boucle_check_rows_fin_faux 	# test: si un des check à rendu FAUX, stop la fonction et renvoie FAUX, sinon la boucle continue
    
      addi $t1, $t1, 1	# incrémentation compteur
      j boucle_check_rows
 
  boucle_check_rows_fin:
  li $a2, 0 		# écriture de VRAI dans $a2 (cad 0, booléen inversé pour une détection d'au moins un retour FAUX)
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 20	# incrémentation du pointeur de la pile 
  jr $ra
  
  boucle_check_rows_fin_faux:
  li $a2, 1		# écriture de FAUX dans $a2 (cad 1, booléen inversé pour une détection d'au moins un retour FAUX)
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 20	# incrémentation du pointeur de la pile 
  jr $ra
  
  
  

	################   Fonction check_squares  ################												CHECK_SQUARES

  # Appels des check_n_square en y envoyant la grille et le numero de ligne, 
  # et additionne les booleens (booléen inversé! VRAI=0, FAUX=1), en retour des check_n_square, si l'addition fait 0, renvoie VRAI  
  #
  # Entrée:$a0, tableau d'entier, grille
  # Local: $t0, adresse de grille
  #        $t1, entier, compteur de boucle
  # 	  
  #
  #        $t7, entier, fin de compteur de boucle
  #
  # Sortie: $a2, entier, booléen inversé
	
check_squares:  

  #- prologue
  addi $sp, $sp, -20	# décrementation de la pile
  sw $ra, 0($sp)	# sauvegarde de $ra
  sw $a0, 4($sp) 	# sauvegarde de l'adresse de la grille dans la pile  
  
  #- corps de la fonction
  move $t0, $a0
  li $t2, 0		# déclaration de la somme des retours de check_n_squares
  li $t1, 1		# déclaration compteur boucle
  li $t7, 9		# déclaration fin de compteur boucle
  boucle_check_squares:
  bge $t1, $t7, boucle_check_squares_fin
 
    # sauvergarde/restauration des paramètres de la fonction pour effectuer un appel d'une autre fonction 
    lw $a0, 4($sp)		# écriture de l'adresse la grille en argument 1
    move $a1, $t1 		# ecriture du numéro de ligne en argument 2
    sw $t1, 8($sp)		# sauvegarde de $t1 dans la pile
    sw $t7, 12($sp)		# sauvegarde de $t7 dans la pile
    sw $t2, 16($sp)		# sauvegarde de $t2 dans la pile
     
    jal check_n_square		# retour en $a2 (retour de check)
    
    lw $t2, 16($sp)		# restauration de $t2 depuis la pile
    lw $t7, 12($sp)		# restauration de $t7 depuis la pile
    lw $t1, 8($sp)		# restauration de $t1 depuis la pile
    lw $t0, 4($sp)		# restauration de l'adresse la grille depuis la pile
    
    
    add $t2, $t2, $a2			# ajout du retour à $t2
    bnez $t2, boucle_check_squares_fin_faux 	# test: si un des check à rendu FAUX, stop la fonction et renvoie FAUX, sinon la boucle continue
    
      addi $t1, $t1, 1	# incrémentation compteur
      j boucle_check_squares
 
  boucle_check_squares_fin:
  li $a2, 0 		# écriture de VRAI dans $a2 (cad 0, booléen inversé pour une détection d'au moins un retour FAUX)
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 20	# incrémentation du pointeur de la pile 
  jr $ra
  
  boucle_check_squares_fin_faux:
  li $a2, 1		# écriture de FAUX dans $a2 (cad 1, booléen inversé pour une détection d'au moins un retour FAUX)
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 20	# incrémentation du pointeur de la pile 
  jr $ra
  			
					
									
	################ Fonction check_sudoku  ################											CHECK_SUDOKU
  # appel des check_rows, check_columns, check_squares, et renvoie VRAI si les 3 retours sont VRAI	
  # les 3 retours sont des booléens inversés (0=VRAI, 1=FAUX), il suffit d'un bnez de cette addition pour vérifier que tout renvoie vrai
  #
  # Entrée: $a0, tableau d'entier, grille 
  # Local : $t0, adresse de grille[0]
  # 	    
  # Sortie: $a0, adresse de la grille
  #         $a2, booléen inversé
 
check_sudoku:

  #- prologue
  addi $sp, $sp, -12	# décrementation de la pile
  sw $ra, 0($sp) 	# sauvegarde de $ra
  sw $a0, 4($sp) 	# sauvegarde de l'adresse de la grille dans la pile
  
  #- corps de la fonction
  li $t1, 0		# initialisation de la somme des retours des check_chose
  
  # sauvergarde/restauration des paramètres de la fonction pour effectuer un appel d'une autre fonction 
  lw $a0, 4($sp)	# écriture de l'adresse de la grille en argument 1
  sw $t1, 8($sp)	# sauvegarde de $t1 dans la pile
  
  jal check_squares
  
  lw $t1, 8($sp)	# restauration de $t1 depuis la pile

  add $t1, $t1, $a2	# additionne le retour de check_square dans $t1
  bnez $t1, check_faux 	# test: si le test à renvoyé FAUX, stop check_sudoku et renvoie faux
  
  # sauvergarde/restauration des paramètres de la fonction pour effectuer un appel d'une autre fonction   
  lw $a0, 4($sp)	# écriture de l'adresse de la grille en argument 1
  sw $t1, 8($sp)	# sauvegarde de $t1 dans la pile

  jal check_rows
  
  lw $t1, 8($sp)	# restauration de $t1 depuis la pile  
  
  add $t1, $t1, $a2	# additionne le retour de check_rows dans $t1
  bnez $t1, check_faux 	# test: si le test à renvoyé FAUX, stop check_sudoku et renvoie faux
  
  # sauvergarde/restauration des paramètres de la fonction pour effectuer un appel d'une autre fonction   
  lw $a0, 4($sp)	# écriture de l'adresse de la grille en argument 1
  sw $t1, 8($sp)	# sauvegarde de $t1 dans la pile
    
  jal check_columns
  
  lw $t1, 8($sp)	# restauration de $t1 depuis la pile  
  
  add $t1, $t1, $a2	# additionne le retour de check_columns dans $t1
  bnez $t1, check_faux 	# test: si le test à renvoyé FAUX, stop check_sudoku et renvoie faux
  
  
  # pas de retour faux, donc retourne VRAI
  li $a2, 0  		# booléen inversé, VRAI = 0
  
  #- épilogue  
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 12	# incrémentation du pointeur de la pile
  jr $ra
  
  check_faux: # retourne FAUX, cad 1
  li $a2, 1  		# booléen inversé, FAUX = 1

  #- épilogue  
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 12	# incrémentation du pointeur de la pile
  jr $ra
  
  
  
  
	################ Fonction solve_sudoku  ################											SOLVE_SUDOKU

# Entrée: $a0, tableau d'entier,  grille
# Local: $t0, adresse de grille(0) 
#        $t1, compteur de boucle
#        $t2, adresse + indice
#        $t3, entier, un chiffre la grille
#        $t4, entier, indice de case vide de la	grille
#
#
#         $t7, fin de compteur
# Sortie: $a3, booléen inversé

solve_sudoku:



  #- prologue
  addi $sp, $sp, -20  	# décrementation du pointeur de pile
  sw $ra, 0($sp)	# sauvegarde de $ra dans la pile
  sw $a0, 4($sp)		#sauvegarde de @ grille (3 mots mémoire)
  #- corps de la fonction 
  
  move $t0, $a0		# adresse de grille[0] -> $t0

  
 ## parcours de la grille, rend l'indice du premier 0, sinon affiche la grille
 
  li $t1, 0 		# déclaration compteur de la boucle
  li $t7, 80		# déclaration fin du compteur
  boucle_parcours_grille:
      bgt $t1, $t7, boucle_parcours_faux 		# tant que compteur < taille(grille), sinon branchement à fin de boucle
         add $t2, $t0, $t1 				# charge le compteur dans indice, pour pouvoir l'utiliser dans un lw 
         lb $t3, ($t2)					# charge tableau[indice] dans t3
             beqz $t3, boucle_parcours_fin_vrai 	# si grille[indice] = 0, branchement vers end_boucle_vrai, sinon:
                 addi $t1 , $t1, 1			# incrémentation compteur
                 j boucle_parcours_grille		# retour au debut de la boucle while

       boucle_parcours_faux :  	# aucune case vide trouvée, donc affichage de la grille cad renvoie vrai!!!!!!!!!!!
       
        sw $t0, 4($sp)		#sauvegarde de $t0
	jal display_en_ligne
	lw $t0, 4($sp)		# restaure $t0 depuis la pile
	
	j sortie_solve_sudoku
	
       boucle_parcours_fin_vrai:
         move $t4, $t1    	# stock l'indice dans $t4 


  li $t1, 1 	# charge 1 dans le compteur
  li $t7, 9	# charge 9 dans la fin de boucle
boucle_recursion:  
  bgt $t1, $t7, boucle_recursion_fin
      add $t2, $t4, $t0
      sb $t1, ($t2)   ## remplacer grille[indice vide] par t1
    
      ## Vérification: appel de check_sudoku     
      # Sauvergarde/restauration des paramètres de la fonction pour effectuer un appel d'une autre fonction 
      
      lw $a0, 4($sp)		# écriture de l'adresse la grille en argument 1
      sw $t1, 8($sp)		# sauvegarde de $t1 dans la pile
      sw $t7, 12($sp)		# sauvegarde de $t7 dans la pile
      sw $t4, 16($sp)		# sauvegarde de $t4 dans la pile
      
      jal check_sudoku  	# retour de check sudoku dans $a2
      
      lw $t4, 16($sp)		# restauration de $t4 depuis la pile
      lw $t7, 12($sp)		# restauration de $t7 depuis la pile
      lw $t1, 8($sp)		# restauration de $t1 depuis la pile
      lw $t0, 4($sp)		# restauration de l'adresse la grille depuis la pile
      
      bnez $a2, retropropagation	# si check_sudoku == FAUX (cad si a2=1), saut à rétropropagation
       				# sinon, appel recursif :
        
        lw $a0, 4($sp)		# écriture de l'adresse la grille en argument 1
        sw $t1, 8($sp)		# sauvegarde de $t1 dans la pile
        sw $t7, 12($sp)		# sauvegarde de $t7 dans la pile
        sw $t4, 16($sp)		# sauvegarde de $t4 dans la pile
        
        jal solve_sudoku 	
        ## ici 2 possibilités: - soit la grille envoyée dans solve_sudoku est complète, donc elle sera affichée
        ##		       - soit elle est incomplète, alors solve_sudoku va remplir le premier indice avec une nouvelle boucle de récurdion, etc...  
          
        lw $t4, 16($sp)		# restauration de $t4 depuis la pile
        lw $t7, 12($sp)		# restauration de $t7 depuis la pile
        lw $t1, 8($sp)		# restauration de $t1 depuis la pile
        lw $t0, 4($sp)		# restauration de l'adresse la grille depuis la pile  
        
      retropropagation: # refait la grille avec un autre chiffre dans l'indice vide
      addi $t1, $t1, 1 		# incrémentation compteur
      j boucle_recursion	# retour au début la boucle
    
  boucle_recursion_fin: ## Retourne FAUX  // Aucun chiffre valide
  li $a3, 0
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 20	# incrémentation du pointeur de la pile  
  jr $ra
  
  sortie_solve_sudoku: ## Retourne VRAI
  li $a3, 1
  
  #- épilogue
  lw $ra, 0($sp)	# restauration de l'adresse de retour
  addi $sp, $sp, 20	# incrémentation du pointeur de la pile
  jr $ra
  
  
  
  
# Autres fonctions que nous avons ajoute :      #

	################ Fonction check  ################													CHECK
  # Parcours un tableau de 9 entier (de 0 à 9), et verifie qu'un chiffre, de 1 à 9, ne soit pas présent plus d'une fois dans ce tableau
  # Grâce à un tableau de 9 entiers initialisé à 0, tabcompt, dont les valeurs représentent le nombre d'occurence des valeurs de ces propres indices dans tabacheck  
  #
  # Entrée: $a0, adresse tableau de 9 entier à vérifier, tabacheck
  # Local:  
  #         $t0, 
  #         $t1, tableau de 9 entiers, tabcompt [0]
  #
  #         $t2, entier, compteur de boucle
  #         $t3, entier, fin de compteur
  #         $t4, entier, pour manipuler une valeur de tabacheck
  #         $t5, entier, pour manipuler une valeur de tabcompt
  #
  #
  #
  # Sortie:  $a2, booléen inversé
  
  
check:

  #- prologue
  addi $sp, $sp, -36	# décrementation de la pile
  la $t1, 0($sp)	# éciture de l'adresse de tabacompt[0] dans $t1, cette case et les 8 prochaines sont le tableau tabacompt

  #- corps de la fonction
  
  # initialise à 0 les valeurs de tabcompt
  li $t2, 0		# compteur boucle
  li $t3, 8		# fin de compteur boucle
  boucle_init:		
  bgt $t2, $t3, boucle_init_fin
    add $t4, $t2, $t1	
    sb $zero, ($t4)		# tabcompt[compteur] <- 0
    addi $t2, $t2, 1		# incémentation du compteur
    j boucle_init
  boucle_init_fin:
  li $t2, 0		# reset le compteur $t2
  
  ## boucle d'incrementation de tabcompt[tabacheck[i-ème]]
  boucle_check: 		
    bgt $t2, $t3, boucle_check_fin_vrai  	
      add $t6, $t2, $a0
      lb $t4, ($t6) 		# charge la valeur de [tabacheck[i-ieme] dans $t4
      beqz $t4, continue_check	# test si [tabacheck[i-ieme]] != 0
      
        subi $t4, $t4, 1 	# on y soustrait 1
        add $t6, $t1, $t4	# on l'utilise comme indice pour tabcompt 
        lb $t5, ($t6)		# ecriture de la valeur de tabcompt($t4) dans $t5
      
        addi $t5, $t5, 1	# incremente de 1 $t5, on augmente le $t4-ème indice de tabcompt, pour compter combien de fois le chiffre [tabacheck[i-ieme]] est dans tabacheck
        
        bgt $t5, 1, boucle_check_fin_faux	# test: si $t5>1 (cad si ce chiffre était déja présent dans tabacheck), si oui, stop la fonction et retourne faux, sinon la boucle continue
          sb $t5, ($t6)		# écriture de $t5 incrémenté dans tabcompt
       continue_check:
       addi $t2, $t2, 1		# incémentation du compteur
       j boucle_check		
    
  boucle_check_fin_vrai: # aucun chiffre de 1 à 9 n'est présent deux fois
  li $a2, 0 		# fonction check retourne VRAI (cad 0, booléen inversé pour une détection facile d'au moins un retour FAUX)
  
  #- épilogue
  addi $sp, $sp, 36	# incrémentation du pointeur de la pile
  jr $ra		# saut à la fonction appellante
  
  boucle_check_fin_faux:
  li $a2, 1		# fonction check retourne FAUX (cad 1, booléen inversé pour une détection facile d'au moins un retour FAUX)
  
  #- épilogue
  addi $sp, $sp, 36	# incrémentation du pointeur de la pile
  jr $ra		# saut à la fonction appellante
  



	################ Fonction display_en_grille  ################													DISPLAY_EN_GRILLE
  # Nous avons refait un display en ligne car nous avions modifier le displayGrille pour qu'il affiche une grille avec des saut à la ligne
  # 
  # Affiche la grille, un tableau de 81 entiers, en une ligne de 81 caractères
  #
  # Entrée: $a0, adresse tableau de 81 entiers, grille
  # Local:  
  #         $t0, 
  #         $t1, tableau de 9 entiers, tabcompt [0]
  #
  #         $t2, entier, compteur de boucle
  #         $t3, entier, fin de compteur
  #         $t4, entier, pour manipuler une valeur de tabacheck
  #         $t5, entier, pour manipuler une valeur de tabcompt
  #
  #
  #
  # Sortie:  rien
  
  
display_en_ligne:  
  #- prologue

  #- corps de la fonction
    move $a1, $a0
    
    la $a0, disp
    li $v0, 4
    syscall
   
    li $t1, 0
    boucle_display:
        bge $t1, 81, fin_display   
            
            add $t2, $t1, $a1
            lb $a0, ($t2) 	# ecriture de grille[indice] dans $a0
            li $v0, 1           # code pour l'affichage d'un entier
            syscall
            add     $t1, $t1, 1             # $t1 += 1;
        j boucle_display
    fin_display:

   li      $v0, 11
    li      $a0, 10
    syscall

  #- épilogue
  jr $ra		
  

#                                               #
#                                               #
#                                               #
################################################# 





exit: 
    li $v0, 10
    syscall
