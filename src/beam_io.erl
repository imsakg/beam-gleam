-module(beam_io).
-export([arguments/0, write_file/2, read_file/1, remove_file/1, stdout/1, error/1, exit/1]).
arguments() -> [unicode:characters_to_binary(A) || A <- init:get_plain_arguments()].
write_file(Path, Data) -> result(file:write_file(Path, Data)).
read_file(Path) -> case file:read_file(Path) of {ok, Data} -> {ok, Data}; {error, Why} -> {error, atom_to_binary(Why, utf8)} end.
remove_file(Path) -> result(file:delete(Path)).
stdout(Data) ->
    ok = io:setopts(standard_io, [binary, {encoding, latin1}]),
    result(file:write(standard_io, Data)).
error(Message) -> io:format(standard_error, "~ts~n", [Message]), nil.
exit(Code) -> erlang:halt(Code).
result(ok) -> {ok, nil};
result({error, Why}) -> {error, atom_to_binary(Why, utf8)}.
