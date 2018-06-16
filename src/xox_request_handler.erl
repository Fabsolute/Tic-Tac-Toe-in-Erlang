%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Jun 2018 05:44
%%%-------------------------------------------------------------------
-module(xox_request_handler).
-author("ahmetturk").
-include("xox.hrl").

%% API
-export([auth/3, message/3, find_match/3]).

auth(Connection, Request, State) ->
  case Connection#connection.username of
    undefined ->
      case maps:get(<<"username">>, Request, undefined) of
        undefined ->
          {reply, <<"bad_request">>, State};
        Username ->
          NewConnection = {Connection#connection.pid, Connection#connection{username = Username}},
          {reply, <<"authentication_success">>, private_update_connection(NewConnection, State)}
      end;
    _ ->
      {reply, <<"user_already_authenticated">>, State}
  end.

message(Connection, Request, State) ->
  case Connection#connection.username of
    undefined ->
      {reply, <<"unauthorized">>, State};
    _ ->
      case maps:get(<<"message">>, Request, undefined) of
        undefined ->
          {reply, <<"bad_request">>, State};
        Message ->
          xox_connection:send_all(Message, Connection#connection.pid),
          {reply, <<"message_sent">>, State}
      end
  end.

find_match(Connection, Request, State) ->
  case Connection#connection.username of
    undefined ->
      {reply, <<"unauthorized">>, State};
    _ ->
      case maps:get(<<"marker">>, Request, undefined) of
        <<"x">> ->
          private_handle_game(Connection, x, State);
        <<"o">> ->
          private_handle_game(Connection, o, State);
        _ ->
          {reply, <<"bad_request">>, State}
      end
  end.

private_handle_game(Connection, Marker, State) ->
  Game = xox_game_handler:new_game(Connection, Marker),
  case Game#game.player1 of
    Connection ->
      %todo update state
      {reply, <<"waiting_opponent">>, State};
    Other ->
      %todo update state
      xox_connection:send(Other, <<"game_started">>),
      {reply, <<"game_started">>, State}
  end.

private_update_connection(NewConnection, State) ->
  lists:keyreplace(NewConnection#connection.pid, 1, State, NewConnection).