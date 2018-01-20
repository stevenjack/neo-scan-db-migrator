FROM smaj/neo-scan:latest

ARG VERSION

ENV POSTGRESS_HOST "postgress:5432"
ENV SUCCESS_COMMANDS "cd /data && mix ecto.drop && mix ecto.create && mix ecto.migrate"

LABEL authors="stevenjack"
LABEL version=${VERSION}

ADD neo-scan-db-migrator /neo-scan-db-migrator
RUN chmod u+x /neo-scan-db-migrator

ENTRYPOINT ["/neo-scan-db-migrator"]
