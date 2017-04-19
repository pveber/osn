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

module Dot = Graph.Graphviz.Dot(
  struct
    include Dep_graph
    let graph_attributes _ = []
    let default_vertex_attributes _ = []
    let vertex_name id = id.Ident.name
    let vertex_attributes _ = []
    let get_subgraph _ = None
    let default_edge_attributes _ = []
    let edge_attributes _ = []
  end
  )

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
  try
    let lexbuf = Lexing.from_channel oc in
    let loc = Location.curr lexbuf in
    let items = Parse.implementation lexbuf in
    let typed_items, _, _ = Typemod.type_structure Env.empty items loc in
    { items ; typed_items }
  with
  | Typetexp.Error (_,env,e) ->
    Typetexp.report_error env Format.std_formatter e ;
    failwith "42"
  | e -> failwith (Exn.to_string e)

let to_dot prg fn =
  let dep_graph = deps_of_structure Dep_graph.empty prg.typed_items in
  Out_channel.with_file fn ~f:(Fn.flip Dot.output_graph dep_graph)
