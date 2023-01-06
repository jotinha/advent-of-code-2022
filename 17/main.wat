(module
  (import "js" "mem" (memory 1))
  (func $getpiece (param $i i32) (result i32)
    (local $piece i32)
    (i32.rem_u (local.get $i) (i32.const 5)) ;; offset 
    (i32.mul (i32.const 4)) ;; *4
    i32.load
    return)

  (func $getmove (param $i i32) (result i32)
    local.get $i
    (i32.load (i32.const 20))  ;; n_moves
    i32.rem_u ;; i % n_moves
    (i32.add (i32.const 24)) ;; +24
    i32.load8_u ;; load a byte at offset 24 + i%n_moves
    return)
  
  (func $getframe (param $y i32) (result i32)
    (i32.add (local.get $y) (i32.const 64))  ;; TODO: generalize (world starts at byte 60 for test)
    i32.load
  )

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
 
  (func $move_wind (param $moveidx i32) (param $piece i32) (result i32)    
    (local $candidate i32)
    ;; shift $piece 1 bit right if getmove(moveidx) == 1 else shift 1 bit left
    (if (result i32)  
      (call $getmove (local.get $moveidx))
      (then (i32.shr_u (local.get $piece) (i32.const 1)))
      (else (i32.shl   (local.get $piece) (i32.const 1))))
  )

  (func $move_wind_unless_hit (param i32) (param i32) (result i32)
    (local $candidate i32)
    (local.set $candidate 
      (call $move_wind (local.get 0) (local.get 1)))
    
    local.get 0

  )
 
  (func $simulate (param $n i32) (result i32)
    (local $piece_idx i32)
    (local $move_idx i32)
    (local $piece i32)
    (local $it i32)

    (local.set $it (i32.const 1))
    (local.set $piece_idx (i32.const 0))
    (local.set $move_idx (i32.const 0))

    (call $move_wind
      (local.get $it)
      (call $getpiece (local.get $it)))
  )

  (func (export "main") (result i32)
    i32.const 0 
    call $getframe
    ;;call $simulate
    return)
)    

