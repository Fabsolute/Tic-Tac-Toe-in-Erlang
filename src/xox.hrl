%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Jun 2018 05:45
%%%-------------------------------------------------------------------
-author("ahmetturk").

-record(connection, {
  pid = undefined,
  username = undefined,
  state = waiting
}).

-record(game, {
  player1 = null,
  player2 = null,
  player1_marker = null,
  game_table = [
    null, null, null,
    null, null, null,
    null, null, null
  ]
}).
