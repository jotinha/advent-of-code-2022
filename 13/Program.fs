let lines = System.IO.File.ReadAllLines("test")

let empty = System.String.IsNullOrWhiteSpace

lines |> Array.filter (not << empty) |> Array.map (printfn "%s")

