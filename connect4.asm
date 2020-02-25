# FILE:		connect4.asm
# AUTHOR:	Austin Cieslinski
#
#
#
# DESCRIPTION:
#	The game of connect 4 made in assembly

	
	.data

newline:
	.asciiz "\n"

welcomeEdge:
	.asciiz "   ************************\n"

welcomeMessage:
	.asciiz "   **    Connect Four    **\n"

columnCount:
	.asciiz "   0   1   2   3   4   5   6   \n"

boardEdge:
	.asciiz "+-----------------------------+\n"

boardLine:
	.asciiz "|+---+---+---+---+---+---+---+|\n"

rowOne:
	.asciiz "||   |   |   |   |   |   |   ||\n"

rowTwo:
	.asciiz "||   |   |   |   |   |   |   ||\n"

rowThree:
	.asciiz "||   |   |   |   |   |   |   ||\n"

rowFour:
	.asciiz "||   |   |   |   |   |   |   ||\n"

rowFive:
	.asciiz "||   |   |   |   |   |   |   ||\n"

rowSix:
	.asciiz "||   |   |   |   |   |   |   ||\n"

playerOneTok:
	.asciiz "X"

playerTwoTok:
	.asciiz "O"

empty:
	.asciiz " "	

playerOneTurnMsg:
	.asciiz "Player 1: select a row to place your coin (0-6 or -1 to quit):"

playerTwoTurnMsg:
	.asciiz "Player 2: select a row to place your coin (0-6 or -1 to quit):"

illegalColumnMsg:
	.asciiz "Illegal column number.\n"

illegalMoveMsg:
	.asciiz "Illegal move, no more room in that column.\n"

tieMsg:
	.asciiz "The game ends in a tie.\n"

playerOneWinMsg:
	.asciiz "Player 1 wins!\n"

playerTwoWinMsg:
	.asciiz "Player 2 wins!\n"

playerOneQuitMsg:
	.asciiz "Player 1 quit.\n"

playerTwoQuitMsg:
	.asciiz "Player 2 quit.\n"
#---------------------
	
	.text
	.align	2

	.globl	main

# Main gameplay function, displays the welcome message and ends the program
main:
	li	$s0, -1
	li	$s1, 6
	li	$s6, 0

	li	$v0, 4
	la	$a0, welcomeEdge
	syscall

	li      $v0, 4
        la      $a0, welcomeMessage
        syscall

	li      $v0, 4
        la      $a0, welcomeEdge
        syscall

	li      $v0, 4
        la      $a0, newline
        syscall

	sw	$ra, 0($sp)	

	jal	playerOne
		
	jr	$ra

# Player One's turn, first displays the board, and then takes input
playerOne:
	
	jal	displayBoard

playerOneTurn:

	li      $v0, 4
        la      $a0, playerOneTurnMsg
        syscall
	
	li	$v0, 5
	syscall

	move 	$t0, $v0
	li      $v0, 4
        la      $a0, newline
        syscall
	move	$v0, $t0

	beq	$v0, $s0, playerOneQuit

	slt	$t0, $v0, $s0
	bne	$t0, $zero, illegalColPOne

	slt	$t0, $s1, $v0
	bne	$t0, $zero, illegalColPOne

	li	$s7, 0

	jal	playerOnePlace		

# Player Two's turn, first displays the board, and then takes input
playerTwo:
	
	jal	displayBoard

playerTwoTurn:

	li      $v0, 4
        la      $a0, playerTwoTurnMsg
        syscall

	li      $v0, 5
        syscall

	move    $t0, $v0
        li      $v0, 4
        la      $a0, newline
        syscall
        move    $v0, $t0

        beq     $v0, $s0, playerTwoQuit

        slt     $t0, $v0, $s0
        bne     $t0, $zero, illegalColPTwo

        slt     $t0, $s1, $v0
        bne     $t0, $zero, illegalColPTwo

	li	$s7, 1

	jal	playerTwoPlace

	j	playerOne

# Gets player ones's token before placing it
playerOnePlace:

	la	$a0, playerOneTok
	lb	$s2, 0($a0)

	j	place

# Gets player two's token before placing it
playerTwoPlace:

	la      $a0, playerTwoTok
        lb      $s2, 0($a0)

        j	place

# Used for finding which row to place the token at, goes through each row to
# check for a blank space and places it there
place:

	la	$a0, empty
	lb	$s3, 0($a0)

	li      $t0, 4

        mult    $t0, $v0

        mflo    $t0

        addi    $t0, $t0, 3

	move	$s4, $t0
	
	li	$s5, 6
        la      $a0, rowSix
        add     $a0, $a0, $s4

	lb	$t1, 0($a0)

	beq	$t1, $s3, placeToken

	li	$s5, 5
	la      $a0, rowFive
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

	beq     $t1, $s3, placeToken

	li	$s5, 4
	la      $a0, rowFour
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

        beq     $t1, $s3, placeToken
	
	li	$s5, 3
	la      $a0, rowThree
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

        beq     $t1, $s3, placeToken

	li	$s5, 2
	la      $a0, rowTwo
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

        beq     $t1, $s3, placeToken

	li	$s5, 1
	la      $a0, rowOne
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

        beq     $t1, $s3, placeToken

	li      $v0, 4
        la      $a0, illegalMoveMsg
        syscall

	beq	$s7, $zero, playerOneTurn

	j	playerTwoTurn
	
# Places the token at the first blank space it finds at a column
placeToken:

	sw	$ra, 4($sp)	

        sb      $s2, 0($a0)

	j	checkVWin

# Check if they player won vertically. Determines which row to start at
# then check from that one -> down
checkVWin:
	
	li	$t0, 0
	li	$t2, 4
	li	$t3, 4
	
	slt	$t2, $t2, $s5
	bne	$t2, $zero, checkHWin

	li	$t2, 1
	beq	$t2, $s5, checkRowOneV

	li      $t2, 2
        beq     $t2, $s5, checkRowTwoV

	li      $t2, 3
        beq     $t2, $s5, checkRowThreeV

	j	checkHWin

checkRowOneV:

	la      $a0, rowOne
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

	bne	$s2, $t1, checkHWin

	addi	$t0, $t0, 1	

checkRowTwoV:

	la      $a0, rowTwo
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

        bne     $s2, $t1, checkHWin

        addi    $t0, $t0, 1

checkRowThreeV:

	la      $a0, rowThree
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

        bne     $s2, $t1, checkHWin

        addi    $t0, $t0, 1

	
	la      $a0, rowFour
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

        bne     $s2, $t1, checkHWin

        addi    $t0, $t0, 1

	beq	$t0, $t3, win_game


	la      $a0, rowFive
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

        bne     $s2, $t1, checkHWin

        addi    $t0, $t0, 1

        beq     $t0, $t3, win_game


	la      $a0, rowSix
        add     $a0, $a0, $s4

        lb      $t1, 0($a0)

        bne     $s2, $t1, checkHWin

        addi    $t0, $t0, 1

        beq     $t0, $t3, win_game

	j	checkHWin

# Gets the address for a row
getAddress:

	li	$t2, 1
	beq	$t2, $s5, getRowOne
	
	li      $t2, 2
        beq     $t2, $s5, getRowTwo

	li      $t2, 3
        beq     $t2, $s5, getRowThree

	li      $t2, 4
        beq     $t2, $s5, getRowFour

	li      $t2, 5
        beq     $t2, $s5, getRowFive

	li      $t2, 6
        beq     $t2, $s5, getRowSix

	j	checkTie


getRowOne:

	la	$a0, rowOne
	jr	$ra

getRowTwo:

	la	$a0, rowTwo
	jr	$ra

getRowThree:
	
	la	$a0, rowThree
	jr	$ra

getRowFour:

	la	$a0, rowFour
	jr	$ra

getRowFive:

	la	$a0, rowFive
	jr	$ra

getRowSix:

	la	$a0, rowSix
	jr	$ra

# Checks if they player won horizontally
checkHWin:

	jal	getAddress
	add	$a0, $a0, $s4

	li	$t0, 1
	move	$t1, $s4
	li	$t2, 27
	move	$a1, $a0
	li	$t5, 4	

# Counts tokens to the right of the placed token
checkHRight:

	slt	$t3, $t1, $t2
	beq	$t3, $zero, checkHLeft

	addi	$a1, $a1, 4

	lb      $t6, 0($a1)

        bne     $s2, $t6, checkHLeft

	addi	$t0, $t0, 1
	slt	$t6, $t0, $t5
	beq	$t6, $zero, win_game

	addi	$t1, $t1, 4

	j	checkHRight
	
# Counts to the left of the placed token
checkHLeft:

	move	$t1, $s4
	li	$t2, 3
	move	$a1, $a0

checkHLeft_loop:

	slt     $t3, $t1, $t2
        bne     $t3, $zero, checkTie

        addi    $a1, $a1, -4

        lb      $t6, 0($a1)

        bne     $s2, $t6, checkTie

        addi    $t0, $t0, 1
        slt     $t6, $t0, $t5
        beq     $t6, $zero, win_game


        addi    $t1, $t1, -4

        j       checkHLeft_loop

# Checks if a tie occured	
checkTie:

	addi	$s6, $s6, 1
	li	$t0, 42
	beq	$s6, $t0, tieGame
	
	lw	$ra, 4($sp)

	jr	$ra

# Used to determine if a player won the game
win_game:

	la	$a0, playerOneTok
	lb	$t0, 0($a0)

	beq	$s2, $t0, playerOneWin
	j	playerTwoWin

playerOneWin:
	
	jal	displayBoard

	li      $v0, 4
        la      $a0, playerOneWinMsg
        syscall

	j	end_game

playerTwoWin:

	jal	displayBoard

        li      $v0, 4
        la      $a0, playerTwoWinMsg
        syscall

        j       end_game


illegalColPOne:

	li      $v0, 4
        la      $a0, illegalColumnMsg
        syscall

	j playerOneTurn

illegalColPTwo:
	
	li      $v0, 4
        la      $a0, illegalColumnMsg
        syscall

        j playerTwoTurn

playerOneQuit:

	li      $v0, 4
        la      $a0, playerOneQuitMsg
        syscall

	j	end_game

playerTwoQuit:

	li      $v0, 4
        la      $a0, playerTwoQuitMsg
        syscall

	j	end_game

tieGame:

	jal	displayBoard
	
	li      $v0, 4
        la      $a0, tieMsg
        syscall

	j	end_game

end_game:
	
	lw      $ra, 0($sp)

        jr      $ra


# Displays the board	
displayBoard:
	
	li      $v0, 4
        la      $a0, columnCount
        syscall

	li      $v0, 4
        la      $a0, boardEdge
        syscall
	
	li      $v0, 4
        la      $a0, boardLine
        syscall

	li      $v0, 4
        la      $a0, rowOne
        syscall

	li      $v0, 4
        la      $a0, boardLine
        syscall

	li      $v0, 4
        la      $a0, rowTwo
        syscall

	li      $v0, 4
        la      $a0, boardLine
        syscall

	li      $v0, 4
        la      $a0, rowThree
        syscall

	li      $v0, 4
        la      $a0, boardLine
        syscall

	li      $v0, 4
        la      $a0, rowFour
        syscall

        li      $v0, 4
        la      $a0, boardLine
        syscall

	li      $v0, 4
        la      $a0, rowFive
        syscall

        li      $v0, 4
        la      $a0, boardLine
        syscall

	li      $v0, 4
        la      $a0, rowSix
        syscall

        li      $v0, 4
        la      $a0, boardLine
        syscall

	li      $v0, 4
        la      $a0, boardEdge
        syscall

	li      $v0, 4
        la      $a0, columnCount
        syscall

	li      $v0, 4
        la      $a0, newline
        syscall

	jr	$ra
