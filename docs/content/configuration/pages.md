+++
title = "Gitlab Pages"
description = "Gitlab Pages Configuration"
category = ["configuration"]
tags = ["configuration", "pages"]
+++

Gitlab Pages allows a user to host static websites from a project. Gitlab pages can be enabled with setting the envrionment variable `GITLAB_PAGES_ENABLED` to `true`.

# Gitlab Pages Access Control

 Since version `11.5.0` Gitlab pages supports access control. This allows only access to a published website if you are a project member, or have access to a certain project.
 Gitlab pages access control requires additional configuration before activating it through the variable `GITLAB_PAGES_ACCESS_CONTROL`.
 Gitab pages access control makes use of the Gitlab OAuth Module.

- Goto the Gitlab Admin area
- Select `Applications` in the menu
- Create `New Application`
  - Name: `Gitlab Pages`
  - Scopes:
    - api
  - Trusted: NO (Do not select)
  - Redirect URI: https://projects.<GITLAB_PAGES_DOMAIN>/auth

 Note about the `Redirect URI`; this can be tricky to configure or figure out, What needs to be achieved is to following, the redirect URI needs to end up at the `gitlab-pages` daemon with the `/auth` endpoint.
 This means that if you run your gitlab pages at domain `pages.example.io` this will be a wilcard domain where your projects are created based on their namespace. The best trick is to enter a NON-Existing gitlab project pages URI as the redirect URI.
 In the example above; the pages domain `projects` has been chosen. This will cause the nginx, either the built in or your own loadbalancer to redirect `*.<GITLAB_PAGES_DOMAIN>` to the `gitlab-pages` daemon. Which will trigger the pages endpoint.
 Make sure to choose own which does not exist and make sure that the request is routed to the `gitlab-pages` daemon if you are using your own HTTP load balancer in front of Gitlab.
 After creating the OAuth application endpoint for the Gitlab Pages Daemon. Gitlab pages access control can now be enabled.
 Add to following environment variables to your Gitlab Container.

 | Variable | R/O | Description |
|----------|-----|-------------|
| GITLAB_PAGES_ACCESS_CONTROL | Required | Set to `true` to enable access control. |
| GITLAB_PAGES_ACCESS_SECRET | Optional | Secret Hash, minimal 32 characters, if omitted, it will be auto generated. |
| GITLAB_PAGES_ACCESS_CONTROL_SERVER | Required | Gitlab instance URI, example: `https://gitlab.example.io` |
| GITLAB_PAGES_ACCESS_CLIENT_ID | Required | Client ID from earlier generated OAuth application |
| GITLAB_PAGES_ACCESS_CLIENT_SECRET | Required | Client Secret from earlier genereated OAuth application |
| GITLAB_PAGES_ACCESS_REDIRECT_URI | Required | Redirect URI, non existing pages domain to redirect to pages daemon, `https://projects.example.io` |

 After you have enabled the gitlab pages access control. When you go to a project `General Settings` -> `Permissions` you can choose the pages persmission level for the project.
