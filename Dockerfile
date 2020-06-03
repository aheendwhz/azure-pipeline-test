FROM babelforce/ivr-sync

COPY config.yml /sync/config.yml
COPY pull-all.sh /sync/pull-all.sh
COPY data /sync/data