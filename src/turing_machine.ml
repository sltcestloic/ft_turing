include Transition

type turing_machine = {
  name: string;
  alphabet: string list;
  blank: string;
  states: string list;
  initial: string;
  finals: string list;
  state: string;
  tape: string;
  head: int;
  transitions: (string, Transition.transition list) Hashtbl.t;
}