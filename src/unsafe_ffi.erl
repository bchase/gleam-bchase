-module('unsafe_ffi').
-export([
  undefined/0,
  apply/3
]).

undefined() ->
  nil.

apply(ModulePath, Func, Args) ->
  ModulePathBinary = binary:list_to_bin(lists:join(<<"@">>, ModulePath)),
  try
    M = erlang:binary_to_atom(ModulePathBinary),
    F = erlang:binary_to_atom(Func),
    {ok, erlang:apply(M, F, Args)}
  catch
    _Class:_Reason -> {error, nil}
  end.
