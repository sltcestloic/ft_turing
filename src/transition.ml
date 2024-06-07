module Transition = struct
  type transition = {
    read : string;
    to_state : string;
    write : string;
    action : string;
  }
end