:-module(basics, [
             pkg/1,
             meet/2,
             met/2,
             depends/3
         ]).

%
%  WRITING DEPS
%
%  You need one each of these three statements. E.g.
%
%  pkg(python).
%  met(python, _) :- which(python, _).
%  meet(python, osx) :- sh('brew install python').
%
:- multifile pkg/1.
:- multifile meet/2.
:- multifile met/2.
:- multifile depends/3.

:- discontiguous pkg/1.
:- discontiguous meet/2.
:- discontiguous met/2.
:- discontiguous depends/3.

