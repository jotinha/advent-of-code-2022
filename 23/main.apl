⎕IO ← 0

N ← 30 ⍝ board will be this size in each direction, should be enough for input data
data ← ↑⊃⎕NGET'test'1

state ← (N÷2) + ⍸data='#' ⍝ 2d indices of elves positions, starting at N÷2

board ← { b ← N N⍴N N/0 ⋄ b[⍵] ← 1 ⋄ b } ⍝ create NxN board and put ones at given indices 

ns ← (⊂0 0)~⍨(,¯1 + ⍳3 3) ⍝ relative indices of the 8 neighbors in all directions
nidxs ← { ⍵ ∘.+ns } ⍝ indices of neighbors
neighbors ← { (board ⍵)[nidxs ⍵] } ⍝ for each neighbor in order, 1 if they are filled, 0 otherwise

x ← neighbors state
allz←{0=+/⍵≠0} ⍝ for each row, return 1 if all elements are zero
xa ← allz x
xn ← allz x[;0 1 2]
xe ← allz x[;2 4 7]
xs ← allz x[;5 6 7]
xw ← allz x[;0 3 5]
xc ← ⍉↑xa xn xs xw xe
pick_cols ← {⍵⍳1}¨↓xc
candidates ← state, (nidxs state)[;1 6 3 4], state
next_state ← candidates[↓⍉↑(⍳22) pick_cols]

⎕ ← next_state
⎕ ← next_state