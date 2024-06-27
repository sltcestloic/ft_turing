include Transition
include Turing_machine

let get_next_transition machine current_char =
  let current_state = machine#get_state in
  let transitions = Hashtbl.find_opt machine#get_transitions current_state in
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
        "[" ^ acc ^ String.make (20 - String.length acc) (String.get machine#get_blank 0) ^ "]"
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
  mark_tape machine#get_tape machine#get_head ""

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
  
let apply_transition (machine: turing_machine) (transition : Transition.transition): string =
  machine#set_state transition.to_state;

  let current_tape = machine#get_tape in
  let head_index = machine#get_head in
  let new_tape =
    let before = String.sub current_tape 0 head_index in
    let after = String.sub current_tape (head_index + 1) (String.length current_tape - head_index - 1) in
    before ^ transition.write ^ after
  in
  
  
  machine#set_tape new_tape;

  if transition.action = "RIGHT" then begin (
    machine#set_head (machine#get_head + 1);
    if machine#get_head = String.length machine#get_tape then (
      machine#set_tape (machine#get_tape ^ machine#get_blank)
    )
  )
  end else if transition.action = "LEFT" then begin
    machine#set_head (machine#get_head - 1);
    if machine#get_head == -1 then (
      machine#set_tape (machine#get_blank ^ machine#get_tape);
    machine#set_head 0
    )
  end;
  
  print_tape_output machine (Some transition);
  
  machine#get_state

let rec run_machine (machine : turing_machine) =
  let current_char = String.make 1 (String.get (machine#get_tape) (machine#get_head)) in
  match get_next_transition machine current_char with
  | Some transition ->
      (* Printf.printf "Transition to apply:\n";
      Printf.printf "  Read: %s\n" transition.read;
      Printf.printf "  To State: %s\n" transition.to_state;
      Printf.printf "  Write: %s\n" transition.write;
      Printf.printf "  Action: %s\n" transition.action; *)
      let new_state = apply_transition machine transition in
      (* Printf.printf "New state: %s\n" new_state; *)

      let final_states = machine#get_finals in
      if List.mem new_state final_states then
        print_endline "Done."
      else
        run_machine machine 
      
  | None -> print_endline "Error: No transition found.";
  ()