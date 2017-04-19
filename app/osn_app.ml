open Core.Std
open Osn

let main fn () =
  let prg = In_channel.with_file fn ~f:Program.read in
  Program.to_dot prg "rien.dot" ;
  printf "%d\n" (List.length prg.Program.items)

let spec =
  let open Command.Spec in
  empty
  +> anon ("FILE" %: file)

let command = Command.basic ~summary:"OSN!" spec main

let () = Command.run command
