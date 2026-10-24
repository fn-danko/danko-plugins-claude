# Claude Code peers inside Docker containers

Tested 2026-10-24, Claude Code v2.1.310, Docker 29.7, host UID 1000 / GID 100, no Remote Control on the containers — pure Unix-socket route.

The docs say container and host sessions can't reach each other. That's true by default only because a container doesn't see the host's socket dir and session registry. Share them and it works.

## Recipe

Image: any glibc distro + `tmux` + `ca-certificates` (+ `jq` if the user's SessionStart hooks need it — the second-mind hook fails without it, harmlessly). Create a user with the host UID/GID and a `/run/user/<uid>` dir owned by it, mode 0700.

```dockerfile
FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends tmux ca-certificates git jq procps \
 && rm -rf /var/lib/apt/lists/* \
 && useradd -u 1000 -g 100 -M -d /home/danko -s /bin/bash danko \
 && mkdir -p /home/danko /run/user/1000 /workspace \
 && chown 1000:100 /home/danko /run/user/1000 /workspace && chmod 700 /run/user/1000
ENV XDG_RUNTIME_DIR=/run/user/1000 HOME=/home/danko TERM=xterm-256color LANG=C.UTF-8
CMD ["sleep","infinity"]
```

```bash
docker run -d --name cc-peer-1 --hostname cc-peer-1 --user 1000:100 \
  --pid=host \
  -v /home/danko/.claude:/home/danko/.claude \
  -v /home/danko/.local/share/claude:/home/danko/.local/share/claude:ro \
  -v /run/user/1000/cc-socks:/run/user/1000/cc-socks \
  -v /etc/machine-id:/etc/machine-id:ro \
  -w /workspace <image>
docker exec -u 1000:100 cc-peer-1 tmux new-session -d -s cc -x 200 -y 50 \
  "/home/danko/.local/share/claude/versions/<ver> --name docker-1 --dangerously-skip-permissions"
```

The host `claude` is a native glibc binary (`readlink -f $(which claude)` → `~/.local/share/claude/versions/<ver>`), so mounting it read-only works in Debian.

## What each piece does

| Piece | Needed for | Without it |
|---|---|---|
| `cc-socks` dir mount | delivery | no inbox reachable [tested] |
| `~/.claude` mount (contains `sessions/` registry + auth) | discovery, login | peers not listed [inferred from registry design] |
| matching UID | socket is 0600, owner-only | connection refused [inferred] |
| `--pid=host` | PID verification of the other side | messaging still works, but: registry file names use in-container PIDs (`15.json`) and can collide; subscriber shows "no verifiable pid"; sender warned "no readable session-registry record vouches for it"; idle notice arrives late and without the one-line status [tested] |
| `/etc/machine-id` mount | identical `pidDomain` to host | no observable difference in our tests [tested] |

Results with this recipe: host ↔ container and container ↔ container messaging, and idle notices with status line, all worked [tested]. A container in its own PID namespace could still message a `--pid=host` one [tested].

## Trap: don't bind-mount `~/.claude.json` as a single file

Claude Code rewrites `~/.claude.json` via temp file + rename, which creates a new inode. A single-file bind mount stays pinned to the old inode, so after the first host write the container reads and writes an orphaned copy — the two sides silently diverge (observed: host inode 45365847 vs container 45360960) [tested]. Host sessions sharing the file are fine because they all open the path fresh. Options: omit it (container gets its own, may show first-run prompts), mount the parent dir, or use `CLAUDE_CONFIG_DIR` pointing at a shared directory [inferred].

## Cleanup

1. `docker exec <c> tmux send-keys -t cc C-u '/exit' Enter` — the session removes its socket and registry entry. (`pgrep -f versions/<ver>` will still match the tmux server's command line; that's not the Claude process.)
2. `docker rm -f <containers>`, `docker rmi <image>`.
3. Check `ls /run/user/1000/cc-socks ~/.claude/sessions` for stale entries of killed sessions.
4. Container sessions' transcripts land in `~/.claude/projects/-<workdir>/` (e.g. `-workspace`); check creation time (`stat -c %w`) before deleting — `/workspace` may also be used by other sandboxes.
