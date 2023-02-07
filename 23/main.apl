⎕IO ← 0

N ← 2048 ⍝ board will be this size in each direction, should be enough for input data
data ← ↑⊃⎕NGET'input'1

state ← (N÷2) + ⍸data='#' ⍝ 2d indices of elves positions, starting at N÷2

board ← { b ← N N⍴N N/0 ⋄ b[⍵] ← 1 ⋄ b } ⍝ create NxN board and put ones at given indices 

ns ← 9⍴(⍳3 3)-1 ⍝ indices of a 3x3 square around (0 0). Goes left-to-right, up-down order (the 4th entry is (0 0))

zipWithIndex ← {↓⍉↑(⍳≢⍵) ⍵}
step ← {
   state ← ⍵
   pos9 ← state ∘.+ns ⍝ each row has 9 entries with the positions of the neighbors in the left-to-right, up-down order (4 is the position of the elf)
   has_elf ← pos9 ∊ state ⍝ for each entry in pos9, put 1 if there's an elf in it already (col 4 will be all 1's of course)
   
   a ← 1=+/has_elf ⍝ for each row, 1 if all neighbors (except the center) are zero
   allz←{0=+/⍵≠0} ⍝ for each row, return 1 if all elements are zero
   n ← allz has_elf[;0 1 2] ⍝ for the N direction, 1 if no elf in the NW,N,NE positions
   e ← allz has_elf[;2 5 8]
   s ← allz has_elf[;6 7 8]
   w ← allz has_elf[;0 3 6]
   
   cond_mat ← ⍉↑(a n s w e)[0,(order+1)] ⍝ concantenate as column vectors, with the current order of the directions
   pick_cols ← {⍵⍳1}¨↓cond_mat ⍝ for each row, find index of first column that is true, if not returns 5

   pos6 ← pos9[;4,(1 7 3 5)[order],4]
   next_state ← pos6[zipWithIndex pick_cols]

   ⍝ need to account for situations where positions are repeated (this is slow)
   pos_counts ← {⍺(≢⍵)}⌸next_state
   repeated_pos ← (pos_counts[;1]>1)/↑pos_counts[;0]
   pos_is_repeated ← next_state ∊ repeated_pos ⍝ FIXME  this also rollsback positions that are repeated but one of them didn't actually move. But this shouldn't happen
   (pos_is_repeated/next_state) ← pos_is_repeated/state
   order ⊢← 1⌽order ⍝ update global variable
   next_state
}

order ← 0 1 2 3
ans1 ← {
   s ← (step⍣10) ⍵ ⍝ run step 10 times starting at state ⍵
   ⍝ ⎕ ← s - N÷2
   (-≢s) + ×/↑1+⌈/s - ⌊/s ⍝ multiply difference between min and max cols and rows (+1) and subtract length of state
} state

order ← 0 1 2 3
ans2 ← 0 {
   ⍺ ← 0 ⍝ ⋄ ⎕ ← ⍺
   s ← step ⍵
   s ≡ ⍵ : ⍺+1⍝ if state didn't change, return accumulator (iteration number)
   ⍺ = 1000 : ⍺+1 ⍝ if it reaches max iterations, also stop
   (⍺+1)∇s ⍝ otherwise recurse
} state
⎕ ← ~∘' '⍕ans1 ',' ans2