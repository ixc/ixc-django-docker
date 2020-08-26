This content has moved to https://stackoverflow.com/c/theic/questions/176 and https://github.com/ixc/ixc-django-docker/commit/d26db0a19b61b9ded8c6606feebbf3cd288db932

# *Project Name*

*One or two lines describing the project: what is it, who is the client, URL of production site if there is one.*

## Project's FAQs

### Git Branching:
- #### From which branch should I branch off the new branches?
- > A:
- #### Who should receive PR requests?
- > A:
- #### Which branch is following the `Staging` site?
- > A:
- #### Which branch is following the `Production` site?
- > A:

### Client:

- #### Which are the communications channels with the client?
- > A:
- #### Who are the client contacts and what are their roles?
- > A:
- #### Which are the ticketing system urls?
- > A:
- #### Should the client be contacted for questions/testing (or the client contact should be involved always)?
- > A:

### Budget:
- #### Where does the project's budget can be checked?
- > A:
- #### If we have further questions about the budget, who could I ask?
- > A:

### Sites:
- #### Which is the `Production` site URL?
- > A:
- #### Which is the `Staging` site URL?
- > A:
- ### In which server does the `Production` site lives ?
- > A:
- ### In which server does the `Staging` site lives ?
- > A:
- ### Where is the DNS configuration defined?
- > A:

### General:
- #### Which developers have worked/usually work on this project?
- > A:
- #### Where can I get a recent DB dump?
- > A:
 > For most of the projects DB dumps are created periodically using Restic, see: [https://github.com/ixc/restic-pg-dump-docker#restore-macos](https://github.com/ixc/restic-pg-dump-docker#restore-macos) for more details.
- #### Which command is used to run the tests?
- > A:


## Technical Overview

*A more detailed technical summary, briefly listing key components used e.g. Django 1.8, GLAMkit/ICEkit with Collections*

*Consider adding a diagram if there are any non-trivial site integrations, unusual deployment arrangements, or anything that can be quickly expressed visually.*

Integrations:

*List any non-standard integrations here with a brief description, account name, who owns it, 1Password credentials, and a link to a more detailed Integrations document.*

* *PayPal Payments for ticket sales. Account name someaccount@client.com is owned by IC, see "PayPal - Some Client" in 1Password. Further details in `docs/integrations.md#paypal`*

Deployments:

*List deployed environments here with a brief description, URLs to the site itself and its hosting environment*

* ***Staging** for client acceptance and integration testing at https://staging.somesite.com*
  * *Site admin URL if non-obvious (e.g. `/kiosk/`)*
  * *Hosting URL, e.g. Docker Cloud stack name and URL*
  * *Any special instructions for accessing or maintaining site, e.g. access via VPN or via IC proxy server*

*Mention here if the deployments are monitored by external services like NewRelic, DataDog, PingDom etc with corresponding URLs.*


## Resources

Documentation:

* *Link to code repository location (the canonical location of this README document)*
* *Link to project technical documentation and diagrams, e.g. `docs/` directory in repo*
* *Link to ticketing system, e.g. GitHub or Assembla (if different from the main code repository, or if spread between different places)*
* *Link to project specs, client briefs etc e.g. a Google Team Drive directory*

Contacts:

* *Link to client's HubSpot URL, which will (ideally) be the single central repository of all the contact details below, otherwise*
* *If a HubSpot URL isn't available or appropriate, list details for:*
  * *IC staff member who acts as client contact or project manager*
  * *Client contact*
  * *Any additional client- or project-specific communication channels, such as ZenDesk or Shared Slack Channels*
  * *Any relevant third-party service provider contacts, such as DNS provider or external design agency etc*


## Getting Started

*Link directly to a Getting Started guide document for new or returning developers, or include instructions here if they are **brief***

*For projects based on `ixc-django-docker` you can probably get away with something like the following...*

This project is based on [ixc-django-docker]. To get started with [Visual Studio Code] & [Docker]:

1. Clone the repository and open your local working copy with Visual Studio Code.

2. Save a copy of `.env.example` as `.env` and update as required.

3. Click the automatic `Reopen in Container` alert (bottom right), or click `><` (bottom left) > `Reopen in Container`.

4. Click the `Starting with Dev Container` alert (bottom right) to watch the logs, or just wait.

5. Hit `CTRL-SHIFT-(backtick)` to open a new terminal. A project shell will open when the container is ready.

6. Run commands as needed from the project shell, `runserver.sh`, `runtests.sh`, `manage.py shell_plus`, `run-p celery runserver` (multiple specific npm scripts), `npm run dev` (all npm scripts typically needed for dev), `docker-compose exec redis ...`, etc.

7. See [Run with Visual Studio Code & Docker](https://github.com/ixc/ixc-django-docker/blob/master/docs/run-with-vscode-and-docker.md) for more details.

[Docker]: https://docs.docker.com/get-docker/
[ixc-django-docker]: https://github.com/ixc/ixc-django-docker/
[Visual Studio Code]: https://code.visualstudio.com/
