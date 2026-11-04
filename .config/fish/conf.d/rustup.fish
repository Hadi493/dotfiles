# rustup writes this only for a user-local install; Arch's package does not.
test -f "$HOME/.cargo/env.fish"; and source "$HOME/.cargo/env.fish"
