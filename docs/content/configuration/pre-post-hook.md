+++
title = "Pre / Post User Configuration Hooks"
description = "User configuration of container with pre and post hook"
category = ["configuration"]
tags = ["configuration", "hooks", "container", "pre", "post"]
+++

When custom configuration of the container is required, a pre and/or post hook can be added to the container.

Pre and Post hooks are required to be bash scripts.

Location Pre Hook: `/etc/docker-gitlab/init.pre.d/`

Location Post Hook: `/etc/docker-gitlab/init.post.d/`

Scripts are excepted to have the following `shebang` at the top of their file `#!/usr/bin/env bash`

The entrypoint will take care of the executable bit.

If an error is encountered the script file silently fail.
