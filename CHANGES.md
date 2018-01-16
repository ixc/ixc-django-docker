# Breaking and other notable changes

(in development)

* Config templates are now rendered to the `$PROJECT_DIR/var/etc` directory for
  easier discovery and to avoid writing to potentially read-only file systems.

  The default templates can be overridden by setting the `LOGENTRIES_TMPL_CONF`,
  `NEWRELIC_TMPL_CONF`, `NGINX_TMPL_CONF`, `SUPERVISORD_TMPL_CONF`, or
  `SUPERVISORD_INCLUDE_TMPL_CONF` environment variables in your dotenv file.

* `supervisor.sh` no longer attempts to render `$PROJECT_DIR/etc/supervisor.tmpl.conf`
  as an alternative to the default include config (nginx proxy).

  Instead, you should explicitly set `SUPERVISORD_INCLUDE_TMPL_CONF=$PROJECT_DIR/etc/supervisord.include.tmpl.conf`
  in your dotenv file.
