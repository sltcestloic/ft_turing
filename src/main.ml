open Yojson.Basic.Util
open Printf

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
    for i = 0 to Array.length Sys.argv - 1 do
      Printf.printf "[%i] %s\n" i Sys.argv.(i);
    done;

    let filename = Sys.argv.(1) in
    let input = Sys.argv.(2) in
    if not (Sys.file_exists filename) then (
      printf "File %s does not exist.\n" filename;
      exit 1
    );

    try 
      let json = Yojson.Basic.from_file filename in
      printf "File %s is a valid JSON file.\n" filename;
    with
    | Yojson.Json_error msg ->
      printf "File %s is not a valid JSON file: %s\n" filename msg;
      exit 1
  )