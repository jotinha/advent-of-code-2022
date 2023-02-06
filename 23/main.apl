⎕IO ← 0

data ← ↑⊃⎕NGET'test'1
state ← ⍸data='#' ⍝ 2d indices of elves positions

⎕ ← state 
