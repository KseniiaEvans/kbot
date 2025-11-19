# kbot

Minimal CLI service written in Go as part of "DevOps та Kubernetes. Practical intensive+".

## Requirements
- Go 1.20+ installed
- git (optional)

## Build
Set the embedded app version at build time:

```bash
go build -ldflags="-X github.com/KseniiaEvans/kbot/cmd.appVersion=1.0.0"
```

This produces a `kbot` binary in the current directory.

## Run
After building:

```bash
./kbot [flags] [args]
```

Run `./kbot --help` for available commands and flags.

To start bot:

```bash
./kbot start
```


## Development
- Edit code under the repository root.
- Use `go build` as shown above to produce local binaries.
