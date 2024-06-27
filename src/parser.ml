include Turing_machine
include Yojson.Basic.Util

let validate_machine machine =
  let name = machine#get_name in
  let alphabet = machine#get_alphabet in
  let blank = machine#get_blank in
  let states = machine#get_states in
  let initial = machine#get_initial in
  let finals = machine#get_finals in
  let transitions = machine#get_transitions in

  if name = "" then false
  else if not (List.for_all (fun s -> String.length s = 1) alphabet) then (
    print_endline "Error: Each item of the alphabet must be exactly 1 char long";
    false
  )
  else if List.length alphabet != List.length (List.sort_uniq compare alphabet) then (
    print_endline "Error: Duplicate items in the alphabet";
    false
  )
  else if List.length finals != List.length (List.sort_uniq compare finals) then (
    print_endline "Error: Duplicate items in the finals";
    false
  )
  else if not (List.mem blank alphabet) then (
    print_endline "Error: Blank symbol is not part of the alphabet";
    false
  )
  else if List.length states != List.length (List.sort_uniq compare states) then (
    print_endline "Error: Duplicate items in the states";
    false
  )
  else if not (List.mem initial states) then (
    print_endline "Error: Initial state is not part of the states";
    false
  )
  else if finals = [] then (
    print_endline "Error: No final states defined";
    false
  )
  else if not (List.for_all (fun f -> List.mem f states) finals) then (
    print_endline "Error: One or more of the final states are not part of the states";
    false
  )
  else if not (List.for_all (fun s -> List.mem s finals || Hashtbl.mem transitions s) states) then (
    print_endline "Error: One or more of the states don't have a corresponding transitions";
    false
  )
  else
    let validate_transition state trans_list =
      List.for_all (fun (t: Transition.transition) ->
          if not (List.mem t.read alphabet) then (
            print_endline ("Validation error: Transition read symbol " ^ t.read ^ " is not part of the alphabet");
            false
          ) else if not (List.mem t.write alphabet) then (
            print_endline ("Validation error: Transition write symbol " ^ t.write ^ " is not part of the alphabet");
            false
          ) else if not (List.mem t.to_state states || List.mem t.to_state finals) then (
            print_endline ("Validation error: Transition to_state " ^ t.to_state ^ " is not part of the states or finals");
            false
          ) else if not (t.action = "RIGHT" || t.action = "LEFT") then (
            print_endline ("Validation error: Transition action " ^ t.action ^ " is not valid (must be RIGHT or LEFT)");
            false
          ) else true
        ) trans_list
    in
    try
      Hashtbl.iter (fun state trans_list ->
          if not (validate_transition state trans_list) then raise Exit
        ) transitions;
      true
    with Exit -> false

let parse_machine json input =
  let machine = new turing_machine in
  machine#set_name (json |> member "name" |> to_string);
  machine#set_alphabet (json |> member "alphabet" |> to_list |> List.map to_string);
  machine#set_blank (json |> member "blank" |> to_string);
  machine#set_states (json |> member "states" |> to_list |> List.map to_string);
  machine#set_initial (json |> member "initial" |> to_string);
  machine#set_finals (json |> member "finals" |> to_list |> List.map to_string);
  machine#set_state machine#get_initial;
  machine#set_tape (".." ^ input ^ "..");
  machine#set_head 2;

  let transitions_tbl = Hashtbl.create 10 in
  let transitions_json = json |> member "transitions" |> to_assoc in
  List.iter (fun (state, transitions) ->
      match transitions with
      | `List transitions ->
        let transitions_list = List.map (fun t ->
            {
              Transition.read = t |> member "read" |> to_string;
              Transition.to_state = t |> member "to_state" |> to_string;
              Transition.write = t |> member "write" |> to_string;
              Transition.action = t |> member "action" |> to_string;
            }
          ) transitions in
        Hashtbl.add transitions_tbl state transitions_list
      | _ -> failwith "Error: Invalid transitions format"
    ) transitions_json;
  machine#set_transitions transitions_tbl;
  machine