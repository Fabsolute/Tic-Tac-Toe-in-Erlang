-module(xox_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1, start/0]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start(_StartType, _StartArgs) ->
  Dispatch = cowboy_router:compile([
    {
      '_', [
      {"/", cowboy_static, {priv_file, xox, "index.html"}},
      {"/websocket", xox_ws_handler, []},
      {"/static/[...]", cowboy_static, {priv_dir, xox, "static"}}
    ]}
  ]),
  {ok, _} = cowboy:start_clear(http, [{port, 8080}], #{env=>#{dispatch=>Dispatch}}),
  xox_connection:start_link(),
  xox_sup:start_link().

stop(_State) ->
  ok.

start() ->
  application_start(xox).

application_start(App) ->
  application_start(App, application:start(App)).

application_start(_App, ok) ->
  ok;
application_start(_App, {error, {already_started, _App}}) ->
  ok;
application_start(App, {error, {not_started, Dep}}) ->
  ok = application_start(Dep),
  application_start(App);
application_start(App, {error, Reason}) ->
  erlang:error({app_start_failed, App, Reason}).