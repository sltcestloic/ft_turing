include Printf
include Transition
include Turing_machine
include Parser
include Runner

let print_transitions transitions =
  Hashtbl.iter (fun state trans_list ->
    Printf.printf "State %s:\n" state;
    List.iter (fun (trans : Transition.transition) ->
      Printf.printf "  Read: %s, To State: %s, Write: %s, Action: %s\n"
        trans.read trans.to_state trans.write trans.action
    ) trans_list
  ) transitions


let () =
  if Array.length Sys.argv = 1 then
    print_endline "Invalid arguments, try --help"
  else if Sys.argv.(1) = "--help" || Sys.argv.(1) = "-h" then (
    print_endline "usage: ft_turing [-h] jsonfile input\n";
    print_endline "positional arguments:";
    print_endline " jsonfile       json description of the machine\n";
    print_endline " input          input of the machine\n";
    print_endline "optional arguments:";
    print_endline "-h, --help show this help message and exit";
  )
  else if Array.length Sys.argv = 2 then
    print_endline "Invalid arguments, try --help"
  else (
    let filename = Sys.argv.(1) in
    let input = Sys.argv.(2) in
    if not (Sys.file_exists filename) then (
      print_endline "File does not exist.";
      exit 1
    );

    try 
      let json = Yojson.Basic.from_file filename in
      let machine = parse_machine json input in
      Printf.printf "Machine Name: %s\n" machine.name;
      Printf.printf "Alphabet: %s\n" (String.concat ", " machine.alphabet);
      Printf.printf "Blank: %s\n" machine.blank;
      Printf.printf "States: %s\n" (String.concat ", " machine.states);
      Printf.printf "Initial State: %s\n" machine.initial;
      Printf.printf "Final States: %s\n" (String.concat ", " machine.finals);
      Printf.printf "Transitions:\n";
      print_transitions machine.transitions;
      print_endline "";

      if validate_machine machine then (
        if not (validate_input machine input) then
          exit 1;
        print_tape_output machine None;
        run_machine machine
      )

    with
    | Yojson.Json_error msg ->
      Printf.printf "File %s is not a valid JSON file: %s\n" filename msg;
      exit 1
  )