%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Jun 2018 05:45
%%%-------------------------------------------------------------------
-author("ahmetturk").

-record(state, {
  connections = []
}).

-record(connection, {
  pid = undefined,
  username = undefined
}).
