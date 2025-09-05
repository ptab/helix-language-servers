# Helix and containerized LSPs

A few weeks ago I decided to give Helix a shot, and coming from VSCode the first thing I tried to do was to replicate my DevContainer-based workflow.
Unfortunately, it doesn't look like Helix is ready for this ([evidence A](https://github.com/helix-editor/helix/issues/5454), [evidence B](https://github.com/helix-editor/helix/issues/7472)): I was able to configure it in such a way that it would start a containerized language server, but it would invariably terminate after a couple of seconds. Not great.

I decided to look around for inspiration, and in the README of [lspcontainers.nvim](https://github.com/lspcontainers/lspcontainers.nvim) I found [something very familiar](https://github.com/lspcontainers/lspcontainers.nvim#process-id):

> The LSP spec allows a client to send its process id to a language server, so that the server can exit immediately when it detects that the client is no longer running.  
> This feature fails to work properly on a containerized language server because the host and the container do not share the container namespace by default.  
> A container can share a process namespace with the host by passing the `--pid=host` flag to docker/podman, although it should be noted that this somewhat reduces isolation.  
> It is also possible to simply disable the process id detection.  
> ...  
> This is required for several LSPs, and they will exit immediately if this is not specified.  

The first thing I did was to start my devcontainer with `--pid=host`, but that did not make any difference - the language server still died after a few seconds.
So the logical next step was to try and stop Helix from sending the `processId` parameter.

Unfortunately [this seems non-configurable at the moment](https://github.com/helix-editor/helix/blob/d0218f7e78bc0c3af4b0995ab8bda66b9c542cf3/helix-lsp/src/client.rs#L560), so the only other option I could think of was to write a small script that intercepts the jsonrpc messages sent by Helix and removes the `params.processId` field from the `initialize` message before it reaches the language servers: [proxy.py](./proxy.py).
Then we create a small wrapper script:
```sh
#!/bin/sh
python3 proxy.py | docker exec -i <your container name here> "$@"
```
And set up `languages.toml` to call it:
```toml
[language-server.yaml-language-server]
command = "/path/to/wrapper.sh"
args = ["yaml-language-server", "--stdio"]
````

Turns out this actually worked, I was now able to have Helix use a containerized language server for more than a few seconds!

### Going the extra mile

Configuring a language server in `languages.toml` for every language I work with quickly became cumbersome.
One of the things I like about Helix is how, as long as it finds an LSP in `$PATH`, everything just works without any further fiddling.

Keeping the hacky solution theme, I took the opposite approach: instead of adding all the configs to `languages.toml`, I created a bunch of copy-pasteable wrapper scripts in [bin/](./bin). Now I can simply add this directory to `$PATH`:
```sh
export PATH="/path/to/helix-language-servers/bin:$PATH"
```
and Helix will automatically detect it:
```sh
❯ hx --health bash
Configured language servers:
  ✓ bash-language-server: /path/to/helix-language-servers/bin/bash-language-server
Configured debug adapter: None
Configured formatter:
  ✓ /path/to/helix-language-servers/bin/shfmt
Tree-sitter parser: ✓
Highlight queries: ✓
Textobject queries: ✓
Indent queries: ✓
```

So, in conclusion:  
✅  all my tooling and LSPs run inside a container  
✅  Helix can use them as if they were installed locally  
✅  I can reuse my development environment anywhere  
