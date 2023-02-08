⎕IO ← 0

N ← 32 ⍝ board will be this size in each direction, should be enough for input data
S ← '#' = ↑⊃⎕NGET'test'1
draw ← { ⍺ ←'.#' ⋄ ⎕ ← ⍺[⍵] ⋄ ⎕ ← ''}

S ← (-N÷2) ⊖ (-N÷2) ⌽ N N ↑ S  ⍝ expand and center

step ← {
   S ← ⍵

   Sn ← 1 0 ¯1 ∘.⊖ 1 0 ¯1⌽¨⊂S ⍝ a 9x9 grid of S shifted in all directions
   n ← S ^ ⊃ 0=+/¯1↑Sn ⍝ positions where there are no neighbors to the north
                       ⍝ 1) take last row of Sn and sum, this gives the number of neighbors in the NW N NE places for each position
                       ⍝ 2) see where it equals 0 (no neighbors at NW N NE)
                       ⍝ 3) intersect with previous positions of S
   s ← S ^ ⊃ 0=+/1↑Sn  ⍝ same for south
   w ← S ^ ⊃ 0=+/¯1↑⍉Sn ⍝ west
   e ← S ^ ⊃ 0=+/1↑⍉Sn ⍝ east
   a ← ⊃ ∧/n s e w ⍝ all directions are free
   o ← S ≠ ⊃ ∨/n s e w ⍝ all directions are occupied

   moves ← {(~⍺)^⍵}\(o a n s w e ) ⍝ TODO: explain

   stay ← moves[0] ∨ moves[1]

   y ← (1⊖¨moves[2]) + (¯1⊖¨moves[3])
   y ← (y=1) ∨ (1⊖¨y>1) ∨ ¯1⊖¨y>1

   x ← (1⌽¨moves[4]) + (¯1⌽¨moves[5])
   x ← (x=1) ∨ (1⌽¨x>1) ∨ ¯1⌽¨x>1

   ⊃ stay + y + x
}   

score ← {
   idxs ← ⍸⍵  ⍝ get indices where argument is 1 (as vector of 2-tuples)
   (-≢idxs) + ×/↑1+⌈/idxs - ⌊/idxs ⍝ multiply difference between min and max cols and rows (+1) and subtract length of state
}

ans1 ← {
   score (step⍣10) ⍵ ⍝ run step 10 times starting at state ⍵
} S

⎕ ← ans1 