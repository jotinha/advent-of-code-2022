⎕IO ← 0

N ← 2048 ⍝ board will be this size in each direction, should be enough for input data
S ← '#' = ↑⊃⎕NGET'input'1
draw ← { ⍺ ←'.#' ⋄ ⎕ ← ⍺[⍵] ⋄ ⎕ ← ''}

S ← (-N÷2) ⊖ (-N÷2) ⌽ N N ↑ S  ⍝ expand and center

step ← {
   ⍺ ← 0
   order ← 0 1 ,(2 + ⍺⌽0 1 2 3)
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

   moves ← {(~⍺)^⍵}\(o a n s w e )[order] ⍝ TODO: explain
   moves[order] ← moves
   (o a n s w e) ← moves
   
   y ← (1⊖n) + (¯1⊖s)
   y ← (y=1) ∨ (1⊖y>1) ∨ ¯1⊖y>1

   x ← (1⌽w) + (¯1⌽e)
   x ← (x=1) ∨ (1⌽x>1) ∨ ¯1⌽x>1

   o+a+x+y

}   

score ← {
   idxs ← ⍸⍵  ⍝ get indices where argument is 1 (as vector of 2-tuples)
   (-≢idxs) + ×/↑1+⌈/idxs - ⌊/idxs ⍝ multiply difference between min and max cols and rows (+1) and subtract length of state
}

ans1 ← {
   ⍺ ← 0
   s ← ⍺ step ⍵
   ⍺ = 9 : score s ⍝ if it reaches max iterations, return score 
   (⍺+1)∇s ⍝ otherwise recurse
} S

ans2 ← {
   ⍺ ← 0
   s ← ⍺ step ⍵
   s ≡ ⍵ : ⍺+1 ⍝ if state didn't change, return iteration number
   (⍺+1)∇s ⍝ otherwise recurse
} S

⎕ ← ~∘' '⍕ans1 ',' ans2