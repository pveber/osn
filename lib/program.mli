type t = {
  items : Parsetree.structure_item list ;
  typed_items : Typedtree.structure ;
}

val read : in_channel -> t
val to_dot : t -> string -> unit
