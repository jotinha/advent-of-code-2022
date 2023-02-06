⎕IO ← 0

data ← ↑⊃⎕NGET'test'1
state ← ⍸data='#' ⍝ 2d indices of elves positions

board ← {s←⊃1+⌈/⍵-⌊/⍵ ⋄ b←s⍴s/0 ⋄ b[⍵] ← 1 ⋄ b} ⍝ create 2d board from indices

ns ← (⊂0 0)~⍨(,¯1 + ⍳3 3) ⍝ relative indices of the 8 neighbors in all directions
neighbors ← {⍵ ∘.+ns}  

⎕ ← board state 
