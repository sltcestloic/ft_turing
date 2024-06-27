include Transition

class turing_machine =
  object
    val mutable name : string = ""
    val mutable alphabet : string list = []
    val mutable blank : string = ""
    val mutable states : string list = []
    val mutable initial : string = ""
    val mutable finals : string list = []
    val mutable transitions : (string, Transition.transition list) Hashtbl.t = Hashtbl.create 10
    val mutable head : int = 0
    val mutable state : string = ""
    val mutable tape : string = ""

    method get_name = name
    method get_alphabet = alphabet
    method get_blank = blank
    method get_states = states
    method get_initial = initial
    method get_finals = finals
    method get_transitions = transitions
    method get_head = head
    method get_state = state
    method get_tape = tape

    method print_transitions =
      Hashtbl.iter (fun state trans_list ->
        Printf.printf "State %s:\n" state;
        List.iter (fun (trans : Transition.transition) ->
          Printf.printf "  Read: %s, To State: %s, Write: %s, Action: %s\n"
            trans.read trans.to_state trans.write trans.action
        ) trans_list
      ) transitions

    method set_name n = name <- n
    method set_alphabet a = alphabet <- a
    method set_blank b = blank <- b
    method set_states s = states <- s
    method set_initial i = initial <- i
    method set_finals f = finals <- f
    method set_transitions t = transitions <- t
    method set_head h = head <- h
    method set_state s = state <- s
    method set_tape t = tape <- t
  end