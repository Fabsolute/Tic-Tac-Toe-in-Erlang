%%%-------------------------------------------------------------------
%%% @author ahmetturk
%%% @copyright (C) 2018, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. Jun 2018 19:05
%%%-------------------------------------------------------------------
-module(xox_game_handler).
-author("ahmetturk").
-behavior(gen_server).
-include("xox.hrl").

%% API
-export([start/0, start_link/0, new_game/2]).
-export([init/1, handle_call/3, handle_cast/2]).

-record(state, {
  waiting_o_list = [],
  waiting_x_list = [],
  game_list = []
}).

start() ->
  gen_server:start({local, ?MODULE}, ?MODULE, [], []).

start_link() ->
  gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

new_game(Connection, Marker) when is_atom(Marker) ->
  gen_server:call(?MODULE, {new_game, Connection, Marker}).


init([]) ->
  {ok, #state{}}.

handle_call({new_game, Connection, Marker}, _From, GameState) ->
  case Marker of
    x ->
      case length(GameState#state.waiting_o_list) of
        0 ->
          Game = #game{player1 = Connection, player1_marker = x},
          {reply, Game, GameState#state{waiting_x_list = [Game | GameState#state.waiting_x_list]}};
        _ ->
          [H | T] = GameState#state.waiting_o_list,
          Game = H#game{player2 = Connection},
          {reply, Game, GameState#state{waiting_o_list = T, game_list = [Game | GameState#state.game_list]}}
      end;
    o ->
      case length(GameState#state.waiting_x_list) of
        0 ->
          Game = #game{player1 = Connection, player1_marker = o},
          {reply, Game, GameState#state{waiting_o_list = [Game | GameState#state.waiting_o_list]}};
        _ ->
          [H | T] = GameState#state.waiting_x_list,
          Game = H#game{player2 = Connection},
          {reply, Game, GameState#state{waiting_x_list = T, game_list = [Game | GameState#state.game_list]}}
      end
  end;

handle_call(_Request, _From, GameState) ->
  {noreply, GameState}.

handle_cast(_Request, GameState) ->
  {noreply, GameState}.
