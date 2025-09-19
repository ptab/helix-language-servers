# Helix and containerized LSPs

## TL;DR

1. Clone this repository
2. Add the `bin/` directory to your `$PATH` (place the following in your `~/.bashrc`, `~/.zshrc` or equivalent):
   ```sh
   export PATH="/path/to/helix-language-servers/bin:$PATH"
   ```
3. Start the devcontainer:
   ```sh
   dev up
   ```
4. Configure your languages in `languages.toml`:

   ```toml
   [[language]]
   name = "bash"
   formatter = { command = "dev", args = [ "run", "shfmt", "-i", "4" ] }

   [language-server.bash-language-server]
   command = "dev"
   args = [ "proxy", "bash-language-server", "start" ]
   ```

## Why this repository exists

#### Dev Containers

I like [dev containers](https://containers.dev/). It's very cool to be able to tell your IDE to open a repository inside its development container and immediately start working on it without the need for any sort of setup.
When you work with multiple different programming languages or, god forbid, different Python versions, this is really nice to have.

There are usually two types of workflow when working with devcontainers:

1. you open a project inside its devcontainer directly from your IDE. This is incredibly low-effort and doesn't even require you to have the repository cloned locally. This is how tools like GitHub Codespaces work.
2. you manage the devcontainer outside of your IDE, and after opening a project in the IDE, you tell it to attach to a running devcontainer.

#### Helix

I also like [Helix](https://helix-editor.com/). Despite its many awesome features, one of its major omissions is the lack of first-class support for devcontainers (this might one day come in the form of a plugin).

At the time of writing, Helix offers no support for workflow 1.
It is possible to configure it in such a way that it runs the language servers and formatters inside a devcontainer to enable workflow 2, provided they're configured in a certain way that will be explained soon.
This becomes a bit of an issue, because…

#### It's not easy to extend Dev Containers

There are a few common ways to organize devcontainers:

1. _project-centric_: a per-repository configuration with only the dependencies needed for that particular repository. You tell your IDE to start a devcontainer from a URL or the filesystem path where your project lives on. You run as many containers as projects you work on. Projects are workable from any workstation.
2. _developer-centric_: one single devcontainer with all the dependencies and personal settings you might need. You start your devcontainer first, then tell your IDE to "attach" to it. You run one single container regardless of how many projects you work on. Your personal dev environment is available in any workstation.
3. _mixed_: you can of course split your _developer-centric_ devcontainer into smaller _language-centric_ devcontainers. This is a less common option for reasons that will become apparent soon.

At `$DAY_JOB`, we typically go for project-centric devcontainers: write a `devcontainer.json` once, and then any developer can use it in their IDE (typically VSCode or IntelliJ IDEA) to bring up a working dev environment.
To make these containers work with Helix I need to add some custom configuration to each of them; however I don't really want to modify dozens of repositories to add configuration that no one else is particularly interested in.

Creating one large _developer-centric_ devcontainer is also not an option; we work with many different languages and toolkits and the entire point of using devcontainers was to avoid having to go through the hassle of configuring them all together.
Ideally, I would be able to take the "base" configuration in each project repository and extend it with my own custom configuration to make it work with Helix.

Unfortunately this is something that the devcontainer spec does not offer yet, but it's been asked a few times before so maybe it will arrive soon. For the time being, I had to come up with my own solution:

## Included in this repository

### [`.devcontainer/devcontainer.json`](./.devcontainer/devcontainer.json)

The devcontainer configuration with your own custom setup. Feel free to edit this file to match your needs, but do make sure to include `ghcr.io/ptab/devcontainer-features/helix-language-server-proxy` in the `features` block.
This feature is required to be able to use these language servers from Helix (see [ptab/devcontainer-features/helix-language-server-proxy](https://github.com/ptab/devcontainer-features/blob/main/src/helix-language-server-proxy/README.md) for a full explanation).

### [`bin/dev`](.bin/dev)

This script is mostly a wrapper over the standard [devcontainer CLI](https://github.com/devcontainers/cli). Add it to your path by placing this in your shell configuration:

```sh
export PATH="/path/to/helix-language-servers/bin:$PATH"
```

It offers the following commands:

#### `dev up`

Starts a devcontainer for the current directory.
If the current directory contains a `devcontainer.json` configuration, it starts a new container using that one as a base plus the one in this repository on top of it (effectively "merging" the two ones together).
If the current directory does not contain any devcontainer configuration, it starts a new container using only the configuration on this repository (referred to "helix container" from here onwards).

#### `dev run <cmd> [args]`

Runs `cmd [args]` on the container started for the current directory.
If the current directory contains a `devcontainer.json` configuration, it runs the command on the "merged container".
If the current directory does not contain any devcontainer configuration, it runs the command on the "helix container" if it's running.
If the "helix container" is not running, then it runs the command locally (outside of any container).

#### `dev proxy <cmd> [args]`

Shortcut for `dev run helix-language-server-proxy <cmd> [args]`. See [ptab/devcontainer-features/helix-language-server-proxy](https://github.com/ptab/devcontainer-features/blob/main/src/helix-language-server-proxy/README.md) for a full explanation of why this is needed.

#### `dev into`

Shortcut for `dev run /bin/zsh`.

## Tying it all together

Configure the Helix language settings in `languages.toml` for each language server you want to use; here's an example for Bash:

```toml
[[language]]
name = "bash"
formatter = { command = "dev", args = [ "run", "shfmt", "-i", "4" ] }

[language-server.bash-language-server]
command = "dev"
args = [ "proxy", "bash-language-server", "start" ]
```

> [!IMPORTANT]
> The command for language servers **must be** `dev proxy <cmd> [args]` otherwise the LSP will die immediately after starting up.
> See [ptab/devcontainer-features/helix-language-server-proxy](https://github.com/ptab/devcontainer-features/blob/main/src/helix-language-server-proxy/README.md) for a full explanation.

Start a devcontainer with `dev up` and you should now be able to get your nice language server features in Helix, running inside a devcontainer!
