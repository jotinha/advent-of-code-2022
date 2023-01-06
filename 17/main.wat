(module
  (import "js" "mem" (memory 1))
  (func $getpiece (export "getpiece") (param $i i32) (result i32)
    (local $piece i32)
    (i32.rem_u (local.get $i) (i32.const 5)) ;; offset 
    (i32.mul (i32.const 4)) ;; *4
    i32.load
    return)

  (func $piece_height (param $piece i32) (result i32)
    (local $i i32)
    (local.set $i (i32.const 0))
    (loop
      (local.set $i (i32.add (local.get $i) (i32.const 1)))
      (local.set $piece  ;; piece = piece >> 8
        (i32.shr_u (local.get $piece) (i32.const 8)))
      (i32.eqz ;; piece & 0xFF == 0
        (i32.and (local.get $piece) (i32.const 0xFF)))
      (br_if 0 (i32.eqz)) ;; continue loop if not previous cond
      )
    (return (local.get $i)))

  (func (export "main") (result i32)
    i32.const 3 
    call $getpiece
    call $piece_height
    return)
)    

