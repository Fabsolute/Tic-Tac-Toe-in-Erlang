#!/bin/bash
rebar compile &&
export ERL_LIBS=_build/default/lib/
erl -eval "xox_app:start()"


