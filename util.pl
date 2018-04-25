%
%  util.pl
%  marelle-deps
%
%  Utility methods common to multiple deps.
%
:- module(util, [
              make_executable/1,
              curl/2,
              sformat/3,
              expand_path/2,
              isfile/1,
              isdir/1,
              interleave/3,
              sh/2,
              bash/2,
              sh/1,
              bash/1,
              sh_output/2,
              bash_output/2,
              join/2,
              join_if_list/2,
              which/1,
              which/2
          ]).

expand_path(Path0, Path) :-
    ( atom_concat('~/', Suffix, Path0) ->
        getenv('HOME', Home),
        join([Home, '/', Suffix], Path)
    ;
        Path = Path0
    ).

isfile(Path0) :-
    expand_path(Path0, Path),
    exists_file(Path).

isdir(Path0) :-
    expand_path(Path0, Path),
    exists_directory(Path).

make_executable(Path) :-
    sh(['chmod a+x ', Path]).

curl(Source, Dest) :-
    sh(['curl -s -o ', Dest, ' ', Source]).

% sformat(+S0, +Vars, -S) is semidet.
%   String interpolation, where {} is replaced by an argument in the list.
%   Will fail if the number of {} is not the same as the number of vars passed
%   in.
%
%   sformat('Hello ~a!', ['Bob'], 'Hello Bob!').
%
sformat(S0, Vars, S) :-
    atomic_list_concat(Parts, '~a', S0),
    ( length(Vars, N), N1 is N + 1, length(Parts, N1) ->
        true
    ;
        throw('wrong number of arguments in interpolation')
    ),
    interleave(Parts, Vars, S1),
    atomic_list_concat(S1, '', S).

interleave(Xs, Ys, Zs) :-
    ( Ys = [] ->
        Zs = Xs
    ;
        Ys = [Y|Yr],
        Xs = [X|Xr],
        Zs = [X, Y|Zr],
        interleave(Xr, Yr, Zr)
    ).



% sh(+Cmd, -Code) is semidet.
%   Execute the given command in shell. Catch signals in the subshell and
%   cause it to fail if CTRL-C is given, rather than becoming interactive.
%   Code is the exit code of the command.
sh(Cmd0, Code) :-
    join_if_list(Cmd0, Cmd),
    catch(shell(Cmd, Code), _, fail).

bash(Cmd0, Code) :- sh(Cmd0, Code).

% sh(+Cmd) is semidet.
%   Run the command in shell and fail unless it returns with exit code 0.
sh(Cmd) :- sh(Cmd, 0).

bash(Cmd0) :- sh(Cmd0).

% sh_output(+Cmd, -Output) is semidet.
%   Run the command in shell and capture its stdout, trimming the last
%   newline. Fails if the command doesn't return status code 0.
sh_output(Cmd0, Output) :-
    tmp_file(syscmd, TmpFile),
    join_if_list(Cmd0, Cmd),
    join([Cmd, ' >', TmpFile], Call),
    sh(Call),
    read_file_to_codes(TmpFile, Codes, []),
    atom_codes(Raw, Codes),
    atom_concat(Output, '\n', Raw).

bash_output(Cmd, Output) :- sh_output(Cmd, Output).

join(L, R) :- atomic_list_concat(L, R).

join_if_list(Input, Output) :-
    ( is_list(Input) ->
        join(Input, Output)
    ;
        Output = Input
    ).


% which(+Command, -Path) is semidet.
%   See if a command is available in the current PATH, and return the path to
%   that command.
which(Command, Path) :-
    sh_output(['which ', Command], Path).

% which(+Command) is semidet.
%   See if a command is available in the current PATH.
which(Command) :- which(Command, _).
