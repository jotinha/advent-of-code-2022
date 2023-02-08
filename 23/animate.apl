⎕LOAD 'main.ws'

save_pnm ← {
   img←'P1'(⍕⌽⍴⍵),⍕¨↓⍵
   (⊂img)⎕NPUT⍺
}

animate ← 0 {
   s ← ⍺ step ⍵
   fname ← ~∘' ' ⍕ 'frames/' (1E5 + ⍺) '.pnm'
   _ ← fname save_pnm s
   s ≡ ⍵ : ⍬ ⋄ (⍺+1)∇s
} S
