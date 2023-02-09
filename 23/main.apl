⍝ A solution partially inspired by the conway's game of life solution
⍝ https://www.youtube.com/watch?v=a9xAKttWgP4

⎕IO ← 0

N ← 256 ⍝ board will be this size in each direction, should be enough for input data (the smaller, the faster it is, but if too small gives the wrong answer)
S ← '#' = ↑⊃⎕NGET'input'1
draw ← { ⍺ ←'.#' ⋄ ⎕ ← ⍺[⍵] ⋄ ⎕ ← ''}

S ← (-N÷2) ⊖ (-N÷2) ⌽ N N ↑ S  ⍝ expand and center

step ← {
   S ← ⍵

   Sn ← 1 0 ¯1 ∘.⊖ 1 0 ¯1⌽¨⊂S ⍝ a 9x9 grid of S shifted in all directions
   
   ⍝ Sum Sn in the x-axis and check where it equals 0, this gives 3 matricies containing a mask where there are no neighbors in the y-direction
   ⍝ Then intersect with the positions S because we don't care about having no neighbors at empty positions
   ⍝ The first mask (sum of Sn[0;]) is the mask of the positions with no neighbors at SW S SE
   ⍝ The third mask (sum of Sn[2;]) is the mask of the positions with no neighbors at NW N NE
   ⍝ Then do the same in the other direction
   (s _ n) ← (⊂S) ^ 0=+/Sn   
   (e _ w) ← (⊂S) ^ 0=+⌿Sn
   
   f ← ⊃ ∧/n s w e      ⍝ all directions are (f)ree
   o ← S ≠ ⊃ ∨/n s w e  ⍝ all directions are (o)ccupied
   r ← f ∨ o            ⍝ (r)emain if any of the two previous conditions hold

   ⍝ Create a vector of all possible moves, in the correct order (rotated ⍺ times, the iteration number)
   ⍝ The r mask is put at the beggining because it's the most important rule
   ⍝ Then apply a scan along the vector such that only the first valid move is kept at 1, the remaining ones to the right are zeroed
   ⍝ Drop the first element of the vector, rotate back and reassign the masks
   (n s w e) ← (-⍺)⌽ 1↓ {(~⍺)^⍵}\ (⊂r),⍺⌽n s w e

                                 ⍝ to avoid collisions, we need only consider situations where two positions are in the same row or col. Can't happen for positions in the diagonal
   y ← (1⊖n) + (¯1⊖s)            ⍝ attempt to move in the y dir, both up and down as given by the n and s masks. When we sum the two resulting arrays we might have collisions
   y ← (y=1) ∨ (1⊖y>1) ∨ ¯1⊖y>1  ⍝ Where y>1, rollback by going back in the oposite directions

   x ← (1⌽w) + (¯1⌽e)            ⍝ do the same for the x direction
   x ← (x=1) ∨ (1⌽x>1) ∨ ¯1⌽x>1

   r+x+y                         ⍝ join all masks, shouldn't be any number > 1
}   

score ← {
   idxs ← ⍸⍵  ⍝ get indices where argument is 1 (as vector of 2-tuples)
   (-≢idxs) + ×/↑1+⌈/idxs - ⌊/idxs ⍝ multiply difference between min and max cols and rows (+1) and subtract length of state
}

ans1 ← 0 {
   s ← ⍺ step ⍵
   ⍺ = 9 : score s ⋄ (⍺+1)∇s ⍝ if it reaches max iterations, return score, otherwise recurse
} S

ans2 ← 0 {
   s ← ⍺ step ⍵
   s ≡ ⍵ : ⍺+1 ⋄ (⍺+1)∇s     ⍝ if state didn't change, return iteration number, otherwise recurse
} S

⎕ ← ~∘' '⍕ans1 ',' ans2

⎕SAVE 'main.ws'