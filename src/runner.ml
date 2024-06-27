include Transition
include Turing_machine

let get_next_transition machine current_char =
  let current_state = machine.state in
  let transitions = Hashtbl.find_opt machine.transitions current_state in
  match transitions with
  | None -> None
  | Some trans_list ->
      let rec find_transition transitions current_char =
        match transitions with
        | [] -> None
        | (transition : Transition.transition)::rest -> 
          if transition.read = current_char then
            Some transition
          else
            find_transition rest current_char
      in
      find_transition trans_list current_char

let tape_with_marker machine =
  let rec mark_tape tape index acc =
    if String.length tape = 0 then
      if String.length acc < 20 then
        "[" ^ acc ^ String.make (20 - String.length acc) (String.get machine.blank 0) ^ "]"
      else
        "[" ^ String.sub acc 0 20 ^ "]"
    else
      let c = String.get tape 0 in
      let rest = String.sub tape 1 (String.length tape - 1) in
      let marked_char =
        if index = 0 then Printf.sprintf "<%c>" c
        else Printf.sprintf "%c" c
      in
      mark_tape rest (index - 1) (acc ^ marked_char)
  in
  mark_tape machine.tape machine.head ""

let print_tape_output (machine : turing_machine) (transition : Transition.transition option) =
  let tape_output = tape_with_marker machine in
  Printf.printf "%s" tape_output;
  match transition with
  | Some t ->
      Printf.printf " (%s, %s, %s)\n"
        t.to_state
        t.write
        t.action
  | None -> print_endline ""

let apply_transition (machine: turing_machine) (transition : Transition.transition): turing_machine =
  let new_state = transition.to_state in

  let current_tape = machine.tape in
  let head_index = machine.head in
  let new_tape =
    let before = String.sub current_tape 0 head_index in
    let after = String.sub current_tape (head_index + 1) (String.length current_tape - head_index - 1) in
    before ^ transition.write ^ after
  in

  let new_head, new_tape =
    if transition.action = "RIGHT" then
      let new_head = head_index + 1 in
      if new_head = String.length new_tape then
        (new_head, new_tape ^ machine.blank)
      else
        (new_head, new_tape)
    else if transition.action = "LEFT" then
      let new_head = head_index - 1 in
      if new_head = -1 then
        (0, machine.blank ^ new_tape)
      else
        (new_head, new_tape)
    else
      (head_index, new_tape)
  in

  { machine with state = new_state; tape = new_tape; head = new_head }

let rec run_machine (machine : turing_machine) =
  let current_char = String.make 1 (String.get (machine.tape) (machine.head)) in
  match get_next_transition machine current_char with
  | Some transition ->
      let new_machine = apply_transition machine transition in
      print_tape_output new_machine (Some transition);

      if List.mem new_machine.state new_machine.finals then
        print_endline "Done."
      else
        run_machine new_machine
  | None -> print_endline "Error: No transition found."