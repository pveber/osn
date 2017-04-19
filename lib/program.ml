open Core.Std

type t = {
  items : Parsetree.structure_item list ;
  typed_items : Typedtree.structure ;
}

module Vertex = struct
  include Ident
  (* let compare = Path.compare *)
  (* let equal x y = compare x y = 0 *)
  (* let hash = Hashtbl.hash *)
end

module Dep_graph = Graph.Persistent.Digraph.Concrete(Vertex)

open Typedtree

let rec deps_of_structure g { str_items ; _ } =
  List.fold str_items ~init:g ~f:deps_of_structure_item

and deps_of_structure_item g { str_desc ; _ } =
  match str_desc with
  | Tstr_value (_, vbs) ->
    List.fold vbs ~init:g ~f:deps_of_value_binding
  | _ -> g

and deps_of_value_binding g { vb_pat ; _ } =
  let idents = idents_from_pattern vb_pat in
  List.fold idents ~init:g ~f:Dep_graph.add_vertex


and idents_from_pattern { pat_desc ; _ } =
  match pat_desc with
  | Tpat_var (id, _) -> [ id ]
  | _ -> []

let read oc =
  let lexbuf = Lexing.from_channel oc in
  let loc = Location.curr lexbuf in
  let items = Parse.implementation lexbuf in
  let typed_items, _, _ = Typemod.type_structure Env.empty items loc in
  let _ = deps_of_structure Dep_graph.empty typed_items in
  { items ; typed_items }
