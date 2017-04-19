open Printf
open Solvuu_build.Std
open Solvuu_build.Util

let project_name = "osn"
let version = "dev"

let annot = ()
let bin_annot = ()
let g = ()
let short_paths = ()
let thread = ()


let lib =
  Project.lib project_name
    ~thread
    ~findlib_deps:["compiler-libs.common";"core";"ocamlgraph"]
    ~dir:"lib"
    ~style:(`Pack project_name)
    ~install:(`Findlib project_name)

let app =
  Project.app "osn_app"
    ~file:"app/osn_app.ml"
    ~internal_deps:[lib]

let () = Project.solvuu1 ~project_name ~version [ lib ; app ]
