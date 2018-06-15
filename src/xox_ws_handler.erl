%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. May 2018 11:27
%%%-------------------------------------------------------------------
-module(xox_ws_handler).
-author("ahmetturk").

%% API
-export([init/2, websocket_init/1, websocket_handle/2, websocket_info/2, terminate/3]).

init(Req, State) ->
  Opts = #{compress => true},
  {cowboy_websocket, Req, State, Opts}.

websocket_init(State) ->
  xox_connection:connected(),
  {ok, State}.

websocket_handle({text, Message}, State) ->
  Response = xox_connection:json_handle(jiffy:decode(Message, [return_maps])),
  {reply, {text, Response}, State};

websocket_handle(_Data, State) ->
  {ok, State}.

websocket_info({text, Message}, State) ->
  {reply, {text, Message}, State};
websocket_info(_Info, State) ->
  {ok, State}.

terminate(_Reason, _Req, _State) ->
  xox_connection:disconnected(),
  ok.
