# Bugsbunny

This is to show the issue of using custom folders for deps & build.
I'm not using this because I want to be fancy, although I also want that, I'm using this so that I manage to run multi-node elixir apps locally for development purposes. The issue that occurs without custom folders is explained afterwards, but this still looks like a bug so I guess it doesn't matter why I'm doing this.

This issue isn't a problem when packaging and deploying releases (as far as I've tested because everything is packed neatly but I haven't actually tried this current setup in full), but is essential for a working local development environment that mimics and allows testing multiple replica configurations easily and keeps parity with the swarm topology that is going to be deployed in production.

To run this, having docker rootless installed, run:
`docker compose up`

(if you're not running docker rootless, then use the `compose-root.yml` file, `docker compose -f compose-root.yml up` the only difference is the mounting of the docker sock, they're mapped to the default non-root file inside the container and when accessing them through the entry points scripts)

You'll see that it creates the folders in the umbrella root:

```
deps_1
deps_third_1
_build_1
_build_third_1
```

But then creates the deps folders inside all sub-apps

```
apps/server/deps_1
apps/server/deps_third_1
apps/db/deps_1
apps/db/deps_third_1
apps/third/deps_1
apps/third/deps_third_1
```

You can run `./clean_deps.sh` to remove them all whenever you want to start.

The deps&build folders are set on the entrypoints respectively for each "compose service". The reason I do this, is because when running locally with an overlay over the main folder - to be the context for the service - since all apps are in the same umbrella, using the default "deps" and "_build" folder had about I would say a 97% failure rate when doing "compose up", because the files would be compiling for one service, or even 1 replica of the same service, then they would start being compiled for another, and then in the end what happened was that protocols where missing crashing the app, then it would be started again, and something else would fail on the other service being compiled, and you would end up with a non-functioning cluster.
I first tried to separate only between build from the same replicas, but then in anger went all the way to separate the _build and deps folders by `service` + `node number`, to allow running an arbitrary number of replicas each one with their compilation artefacts.

I arrived here after solving a bunch of issues, that I had pointed in https://github.com/erlang/otp/issues/9848 - and I have tried a bunch of options before opening this issue and creating this minimal repo (I've removed the local clustering with a local adapter I wrote for docker compose because it's not needed here, and removed everything that seemed accessory from the umbrella down to this minimal example) - the things I've tried was for e.g. running the tasks `server.start` and `third.start` with `--no-compile`, using `MIX_CONCURRENCY_LOCK` to false, etc. I also ran this with an older version of esbuild, which was the default I had on the project, like 18, and updated it now to see if it would be the issue now...

I've turned the `MIX_DEBUG` on with true but I can't see where and why it's writing the deps inside the apps themselves.

The issue you can see here nonetheless is that the `phoenix_live_view` dependency is nowhere to be found. And so this creates an issue with:

```
server-1  | ✘ [ERROR] Could not resolve "phoenix"
server-1  | 
server-1  |     js/app.js:21:21:
server-1  |       21 │ import {Socket} from "phoenix"
server-1  |          ╵                      ~~~~~~~~~
```

```
server-1  | ✘ [ERROR] Could not resolve "phoenix_live_view"
server-1  | 
server-1  |     js/app.js:22:25:
server-1  |       22 │ import {LiveSocket} from "phoenix_live_view"
server-1  |          ╵                          ~~~~~~~~~~~~~~~~~~~
```

I'm thinking this is something where when using a custom `MIX_DEPS_PATH` some code path is not recognizing it's inside an umbrella, and decides on local paths for the apps, instead of the root path. It still doesn't explain why `phoenix_live_view` isn't in either place, but maybe can point to why... Strangely on my other project `phoenix` is found in the deps folder, but not `live_view` but on this fresh one both aren't found.

I've changed the `NODE_PATH` in the config so it assumes the right deps path, and you can see from the esbuild logging (that I've activated) that it's looking in the right folder but it's simply not there:

```
server-1  |     Read 40 entries for directory "/app/deps_1"
server-1  |     Failed to read directory "/app/deps_1/phoenix_live_view": open /app/deps_1/phoenix_live_view: no such file or directory
server-1  |     Failed to read directory "/app/deps_1/phoenix_live_view"
```

There's probably some bugs in mix aswell because ocasionally, even in normal setups sometimes you would be forced to nuke _build (or very rarely, deps too) to get out of a compilation issue, but this one isn't that.

To control options for the tasks, use the entry points.
To tear down and remove the volumes, `docker compose down -v`
To clean up all deps and build folders run  `./clean_deps.sh` or `./clean_deps.sh lock` to also remove the mix.lock file in case you want to update the deps versions inside the apps.


Lastly this can was setup relatively easily by doing:

```
mix new bugsbunny --umbrella

cd bugsbunny/apps
mix phx.new.web server --no-tailwind
mix phx.new.ecto db --module DB
mix new third --sup
```

then adding the compose files, changing the configs, the `mix.exs` `deps()` and adding `optional_applications` to `third` and `server` `mix.exs` of the opposite one (this isn't relevant though, since it happens the same either way), creating the tasks...