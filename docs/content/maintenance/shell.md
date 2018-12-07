+++
title = "Shell Access"
description = "Shell Access"
category = ["maintenance"]
tags = ["maintenance", "shell"]
+++

For debugging and maintenance purposes you may want access the containers shell. If you are using docker version `1.3.0` or higher you can access a running containers shell using `docker exec` command.

```bash
docker exec -it gitlab bash
```
