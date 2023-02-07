⎕IO ← 0

N ← 2048 ⍝ board will be this size in each direction, should be enough for input data
data ← ↑⊃⎕NGET'input'1

state ← (N÷2) + ⍸data='#' ⍝ 2d indices of elves positions, starting at N÷2

board ← { b ← N N⍴N N/0 ⋄ b[⍵] ← 1 ⋄ b } ⍝ create NxN board and put ones at given indices 

ns ← (⊂0 0)~⍨(,¯1 + ⍳3 3) ⍝ relative indices of the 8 neighbors in all directions
nidxs ← { ⍵ ∘.+ns } ⍝ indices of neighbors
neighbors ← { (board ⍵)[nidxs ⍵] } ⍝ for each neighbor in order, 1 if they are filled, 0 otherwise

step ← {
   x ← neighbors ⍵
   allz←{0=+/⍵≠0} ⍝ for each row, return 1 if all elements are zero
   xa ← allz x
   xn ← allz x[;0 1 2]
   xe ← allz x[;2 4 7]
   xs ← allz x[;5 6 7]
   xw ← allz x[;0 3 5]
   xc ← ⍉↑xa xn xs xw xe
   pick_cols ← {⍵⍳1}¨↓xc
   candidates ← ⍵, (nidxs ⍵)[;1 6 3 4], ⍵
   next_state ← candidates[↓⍉↑(⍳≢⍵) pick_cols]

   pos_counts ← {⍺(≢⍵)}⌸next_state
   repeated_pos ← (pos_counts[;1]>1)/↑pos_counts[;0]
   pos_is_repeated ← next_state ∊ repeated_pos ⍝ FIXME  this also rollsback positions that are repeated but one of them didn't move, can it happen?
   (pos_is_repeated/next_state) ← pos_is_repeated/⍵
   next_state
}

ans1 ← {
   s ← (step⍣10) ⍵ ⍝ run step 10 times starting at state ⍵
   ⍝ ⎕ ← s - N÷2
   (-≢s) + ×/↑1+⌈/s - ⌊/s ⍝ multiply difference between min and max cols and rows (+1) and subtract length of state
} state

ans2 ← {
   ⍺ ← 0 ⋄ ⎕ ← ⍺
   s ← step ⍵
   s ≡ ⍵ : ⍺ ⍝ if state didn't change, return accumulator
   ⍺ = 1000 : ⍺ ⍝ if it reaches max iterations, also stop
   (⍺+1)∇s ⍝ otherwise recurse
} state

⎕ ← ~∘' '⍕ans1 ',' ans2