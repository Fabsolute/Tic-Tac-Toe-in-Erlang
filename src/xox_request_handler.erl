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
-export([auth/3, message/3]).

auth(Connection, Request, State) ->
  case Connection#connection.username of
    undefined ->
      case maps:get(<<"username">>, Request, undefined) of
        undefined ->
          {reply, <<"bad_request">>, State};
        Username ->
          NewConnection = {Connection#connection.pid, Connection#connection{username = Username}},
          NewConnectionList = lists:keyreplace(Connection#connection.pid, 1, State#state.connections, NewConnection),
          NewState = State#state{connections = NewConnectionList},
          {reply, <<"authentication_success">>, NewState}
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
