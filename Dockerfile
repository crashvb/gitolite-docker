FROM crashvb/nginx:202302181749@sha256:5bef122b25395e0d5d300663b8adc1678f67efaef4a3e4ad3d0a8faa3e36644f
ARG org_opencontainers_image_created=undefined
ARG org_opencontainers_image_revision=undefined
LABEL \
	org.opencontainers.image.authors="Richard Davis <crashvb@gmail.com>" \
	org.opencontainers.image.base.digest="sha256:5bef122b25395e0d5d300663b8adc1678f67efaef4a3e4ad3d0a8faa3e36644f" \
	org.opencontainers.image.base.name="crashvb/nginx:202302181749" \
	org.opencontainers.image.created="${org_opencontainers_image_created}" \
	org.opencontainers.image.description="Image containing gitolite." \
	org.opencontainers.image.licenses="Apache-2.0" \
	org.opencontainers.image.source="https://github.com/crashvb/gitolite-docker" \
	org.opencontainers.image.revision="${org_opencontainers_image_revision}" \
	org.opencontainers.image.title="crashvb/gitolite" \
	org.opencontainers.image.url="https://github.com/crashvb/gitolite-docker"

# Install packages, download files ...
RUN docker-apt cgi.pm gitolite3 gitweb highlight markdown locales openssl pandoc patch && \
	git clone https://github.com/kogakure/gitweb-theme.git /usr/share/gitweb-theme && \
	rm --force --recursive /usr/share/gitweb-theme/.git

# Configure: gitolite
ENV GITOLITE_HOME=/var/lib/git
RUN useradd --comment "Gitolite" --home=${GITOLITE_HOME} --shell=/bin/bash git && \
	sed --in-place '/^umask/s/0077/0027/g' /usr/share/gitolite3/lib/Gitolite/Rc.pm

# Configure: gitweb
ENV GITWEB_HOME=/usr/share/gitweb GITWEB_THEME=/usr/share/gitweb-theme
COPY gitweb.cgi.patch ${GITWEB_HOME}/
COPY gitweb.css.patch ${GITWEB_THEME}/
COPY gitweb.conf.* /usr/local/share/gitweb/
# hadolint ignore=DL3003
RUN usermod --append --groups=git www-data && \
	(cd ${GITWEB_THEME} && ${GITWEB_THEME}/setup --install --verbose) && \
	patch ${GITWEB_HOME}/gitweb.cgi ${GITWEB_HOME}/gitweb.cgi.patch && \
	patch ${GITWEB_THEME}/gitweb.css ${GITWEB_THEME}/gitweb.css.patch && \
	rm ${GITWEB_HOME}/gitweb.cgi.* ${GITWEB_THEME}/gitweb.css.*

# Configure: nginx
COPY default.nginx /etc/nginx/sites-available/default

# Configure: root
COPY .gitconfig clone-gitolite-admin /root/

# Configure: sshd
RUN sed --in-place 's/^AcceptEnv LANG LC_\*$//g' /etc/ssh/sshd_config && \
	rm --force /etc/ssh/ssh_host_* && \
	mkdir --parents /var/run/sshd

# Configure: supervisor
COPY supervisord.sshd.conf /etc/supervisor/conf.d/sshd.conf

# Configure: system
RUN locale-gen en_US.UTF-8 && \
	dpkg-reconfigure --frontend=noninteractive locales

# Configure: entrypoint
COPY entrypoint.gitolite /etc/entrypoint.d/30gitolite
COPY entrypoint.gitweb /etc/entrypoint.d/40gitweb
COPY entrypoint.sshc /etc/entrypoint.d/20sshc
COPY entrypoint.sshd /etc/entrypoint.d/10sshd

# Configure: healthcheck
COPY healthcheck.sshd /etc/healthcheck.d/sshd

EXPOSE 22/tcp

VOLUME /etc/ssh ${GITOLITE_HOME}
