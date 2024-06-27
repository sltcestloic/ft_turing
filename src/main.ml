include Printf
include Transition
include Turing_machine
include Parser
include Runner

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
      Printf.printf "Machine Name: %s\n" machine#get_name;
      Printf.printf "Alphabet: %s\n" (String.concat ", " machine#get_alphabet);
      Printf.printf "Blank: %s\n" machine#get_blank;
      Printf.printf "States: %s\n" (String.concat ", " machine#get_states);
      Printf.printf "Initial State: %s\n" machine#get_initial;
      Printf.printf "Final States: %s\n" (String.concat ", " machine#get_finals);
      Printf.printf "Transitions:\n";
      machine#print_transitions;

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

 