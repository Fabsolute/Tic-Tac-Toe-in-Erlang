%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. Jun 2018 04:08
%%%-------------------------------------------------------------------
-module(xox_connection).
-author("ahmetturk").

-behavior(gen_server).

-export([connected/0, disconnected/0, json_handle/1, send_all/1, send_all/2]).
-export([start_link/0, start/0, stop/0]).
-export([init/1, handle_call/3, handle_cast/2]).
-include("xox.hrl").
%API

connected() ->
  gen_server:cast(?MODULE, {connected, self()}).

disconnected() ->
  gen_server:cast(?MODULE, {disconnected, self()}).

json_handle(Request) when is_map(Request) ->
  Method = get_method(Request),
  case Method of
    undefined ->
      <<"bad_request">>;
    _ ->
      gen_server:call(?MODULE, {handle, self(), Method, Request})
  end;

json_handle(Content) ->
  io:fwrite("~p", [Content]),
  <<"bad_request">>.

send_all(Message) ->
  send_all(Message, self()).

send_all(Message, Pid) ->
  gen_server:cast(?MODULE, {send_all, Pid, Message}).

%% Gen server

start() ->
  gen_server:start({local, ?MODULE}, ?MODULE, [], []).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

stop() ->
  gen_server:stop(?MODULE).

% implementations

init([]) ->
  {ok, #state{}}.

handle_call({handle, Pid, Method, Request}, _From, State) ->
  io:fwrite("handle ~p connections ~p~n", [Pid, State#state.connections]),
  {Pid, Connection} = lists:keyfind(Pid, 1, State#state.connections),
  xox_request_handler:Method(Connection, Request, State);

handle_call(_Request, _From, State) ->
  {noreply, State}.

handle_cast({connected, Pid}, State) ->
  io:fwrite("Connected ~p~n", [Pid]),
  {noreply, State#state{connections = [{Pid, #connection{pid = Pid}} | State#state.connections]}};

handle_cast({disconnected, Pid}, State) ->
  io:fwrite("Disonnected ~p~n", [Pid]),
  Connections = lists:keydelete(Pid, 1, State#state.connections),
  {noreply, State#state{connections = Connections}};

handle_cast({send_all, Pid, Message}, State) ->
  {Pid, Connection} = lists:keyfind(Pid, 1, State#state.connections),
  Head = case Connection#connection.username of
           undefined ->
             "anonymous: ";
           Username ->
             binary_to_list(Username) ++ ": "
         end,
  Content = Head ++ binary_to_list(Message),
  lists:foreach(
    fun(User) ->
      case User of
        {UserPid, _} ->
          io:fwrite("Send to pid ~p~n", [UserPid]),
          UserPid ! {text, Content};
        _ -> ok
      end
    end,
    State#state.connections
  ),
  {noreply, State};

handle_cast(_Request, State) ->
  {noreply, State}.


get_method(Request) ->
  Method = maps:get(<<"method">>, Request, undefined),
  case Method of
    <<"auth">> ->
      auth;
    <<"message">> ->
      message;
    _ ->
      undefined
  end.