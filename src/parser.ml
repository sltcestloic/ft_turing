include Turing_machine

include Yojson.Safe.Util

let validate_input (machine : turing_machine) (input : string) : bool =
  let alphabet = machine.alphabet in
  let blank = String.get machine.blank 0 in
  let has_invalid_char =
    String.exists (fun c -> not (List.exists (fun s -> s = String.make 1 c) alphabet)) input
  in
  if input = "" then begin
    print_endline "Error: Input is empty.";
    false
  end else if has_invalid_char then begin
    print_endline "Error: Input contains characters that are not part of the alphabet.";
    false
  end else if String.contains input blank then begin
    print_endline "Error: Input contains the blank symbol.";
    false
  end else
    true


let validate_machine machine =
  let name = machine.name in
  let alphabet = machine.alphabet in
  let blank = machine.blank in
  let states = machine.states in
  let initial = machine.initial in
  let finals = machine.finals in
  let transitions = machine.transitions in

  if name = "" then (
    print_endline "Error: Name is empty";
    false
  )
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
    print_endline "Error: One or more of the states doesn't have a corresponding transitions";
    false
  )
  else if Hashtbl.fold (fun _ v acc -> acc || v = []) transitions false then (
    print_endline "Error: One or more of the transitions lists is empty";
    false
  )
  else if not (List.for_all (fun final_state ->
    Hashtbl.fold (fun _ transitions acc ->
      acc || List.exists (fun transition -> transition.to_state = final_state) transitions
    ) transitions false
  ) finals) then (
    print_endline "Error: One or more of the final states doesn't have a corresponding transition";
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

let get_member json name =
  match member name json with
  | `Null ->
    print_endline ("Error: Missing element in JSON: " ^ name);
    exit 1
  | value -> value

let parse_machine json input =
  let name = get_member json "name" |> to_string in
  let alphabet = get_member json "alphabet" |> to_list |> List.map to_string in
  let blank = get_member json "blank" |> to_string in
  let states = get_member json "states" |> to_list |> List.map to_string in
  let initial = get_member json "initial" |> to_string in
  let finals = get_member json "finals" |> to_list |> List.map to_string in
  let state = initial in
  let tape = input in
  let head = 0 in

  let transitions_tbl = Hashtbl.create 10 in
  let transitions_json = get_member json "transitions" |> to_assoc in
  List.iter (fun (state, transitions) ->
      match transitions with
      | `List transitions ->
        let transitions_list = List.map (fun t ->
            {
              Transition.read = get_member t "read" |> to_string;
              Transition.to_state = get_member t "to_state" |> to_string;
              Transition.write = get_member t "write" |> to_string;
              Transition.action = get_member t "action" |> to_string;
            }
          ) transitions in
        Hashtbl.add transitions_tbl state transitions_list
      | _ -> failwith "Error: Invalid transitions format"
    ) transitions_json;

  {
    name;
    alphabet;
    blank;
    states;
    initial;
    finals;
    state;
    tape;
    head;
    transitions = transitions_tbl;
  }