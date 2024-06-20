include Printf
include Transition
include Turing_machine
include Parser

let () =
  if Array.length Sys.argv = 1 then
    Printf.printf "Invalid arguments, try --help\n"
  else if Sys.argv.(1) = "--help" || Sys.argv.(1) = "-h" then (
    Printf.printf "usage: ft_turing [-h] jsonfile input\n\n";
    Printf.printf "positional arguments:\n";
    Printf.printf " jsonfile       json description of the machine\n\n";
    Printf.printf " input          input of the machine\n\n";
    Printf.printf "optional arguments:\n";
    Printf.printf "-h, --help show this help message and exit\n";
  )
  else if Array.length Sys.argv = 2 then
    Printf.printf "Invalid arguments, try --help\n"
  else (
    let filename = Sys.argv.(1) in
    let input = Sys.argv.(2) in
    if not (Sys.file_exists filename) then (
      printf "File %s does not exist.\n" filename;
      exit 1
    );

    try 
      let json = Yojson.Basic.from_file filename in
      let machine = parse_machine json in
      Printf.printf "Turing Machine Name: %s\n" machine#get_name;
      Printf.printf "Alphabet: %s\n" (String.concat ", " machine#get_alphabet);
      Printf.printf "Blank: %s\n" machine#get_blank;
      Printf.printf "States: %s\n" (String.concat ", " machine#get_states);
      Printf.printf "Initial State: %s\n" machine#get_initial;
      Printf.printf "Final States: %s\n" (String.concat ", " machine#get_finals);
      Printf.printf "Transitions:\n";
      machine#print_transitions;

      if validate_machine machine then (
        print_endline "Machine is valid !";
      )

    with
    | Yojson.Json_error msg ->
      printf "File %s is not a valid JSON file: %s\n" filename msg;
      exit 1
  )

 