FROM buildpack-deps:stable

# INSTALL DEPENDENCIES AND SETUP USERS

RUN apt-get update &&\
  apt-get install -y less sudo zsh lsb-release locales docker.io supervisor && \
  echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen &&\
  locale-gen en_US.UTF-8 &&\
  groupadd node &&\
  useradd --gid node --shell /bin/bash --create-home node &&\
  groupadd wheel && \
  useradd -m -g users -G wheel,docker -s /bin/zsh --create-home develop &&\
  echo "Defaults exempt_group+=develop" > /etc/sudoers.d/default &&\
  printf "root ALL=(ALL:ALL) ALL \n%%wheel ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/default &&\
  runuser - develop /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# INSTALL NODE

ENV NODE_VERSION 18.6.0

RUN ARCH= && dpkgArch="$(dpkg --print-architecture)" \
  && case "${dpkgArch##*-}" in \
    amd64) ARCH='x64';; \
    ppc64el) ARCH='ppc64le';; \
    s390x) ARCH='s390x';; \
    arm64) ARCH='arm64';; \
    armhf) ARCH='armv7l';; \
    i386) ARCH='x86';; \
    *) echo "unsupported architecture"; exit 1 ;; \
  esac \
  # gpg keys listed at https://github.com/nodejs/node#release-keys
  && set -ex \
  && for key in \
    4ED778F539E3634C779C87C6D7062848A1AB005C \
    141F07595B7B3FFE74309A937405533BE57C7D57 \
    74F12602B6F1C4E913FAA37AD3A89613643B6201 \
    DD792F5973C6DE52C432CBDAC77ABFA00DDBF2B7 \
    61FC681DFB92A079F1685E77973F295594EC4689 \
    8FCCA13FEF1D0C2E91008E09770F7A9A5AE15600 \
    C4F0DFFF4E8C1A8236409D08E73BC641CC11F4C8 \
    890C08DB8579162FEE0DF9DB8BEAB4DFCF555EF4 \
    C82FA3AE1CBEDC6BE46B9360C43CEC45C17AB93C \
    108F52B48DB57BB0CC439B2997B01419BD92F80A \
  ; do \
      gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys "$key" || \
      gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "$key" ; \
  done \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/node-v$NODE_VERSION-linux-$ARCH.tar.xz" \
  && curl -fsSLO --compressed "https://nodejs.org/dist/v$NODE_VERSION/SHASUMS256.txt.asc" \
  && gpg --batch --decrypt --output SHASUMS256.txt SHASUMS256.txt.asc \
  && grep " node-v$NODE_VERSION-linux-$ARCH.tar.xz\$" SHASUMS256.txt | sha256sum -c - \
  && tar -xJf "node-v$NODE_VERSION-linux-$ARCH.tar.xz" -C /usr/local --strip-components=1 --no-same-owner \
  && rm "node-v$NODE_VERSION-linux-$ARCH.tar.xz" SHASUMS256.txt.asc SHASUMS256.txt \
  && ln -s /usr/local/bin/node /usr/local/bin/nodejs \
  # smoke tests
  && node --version \
  && npm --version

# INSTALL POSTGRES
ENV POSTGRES_VERSION 15

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' &&\
  wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - &&\
  apt-get update &&\
  apt-get -y install postgresql-client-$(echo $POSTGRES_VERSION) postgresql-$(echo $POSTGRES_VERSION) &&\
  echo "export PATH=/usr/lib/postgresql/$(echo $POSTGRES_VERSION)/bin/:$PATH" >> $(echo ~develop)/.zshrc &&\
  mkdir /db &&\
  chown postgres:postgres /db &&\
  runuser - postgres /bin/sh -c "/usr/lib/postgresql/$(echo $POSTGRES_VERSION)/bin/initdb -D /db/data/" &&\
  printf "[supervisord]\nnodaemon=true\npidfile=/tmp/supervisord.pid\n\n[program:postgres]\ncommand=/usr/lib/postgresql/$(echo $POSTGRES_VERSION)/bin/postgres -D /db/data/\ndirectory=/db/\nautostart=true\nautorestart=true\nuser=postgres" >> /etc/supervisor/conf.d/postgres.conf

USER develop
WORKDIR $HOME