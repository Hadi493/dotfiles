# Deno's installer writes its env file into the installing user's home.
test -f "$HOME/.deno/env.fish"; and source "$HOME/.deno/env.fish"
