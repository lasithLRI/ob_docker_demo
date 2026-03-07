BASE_URL=$(pwd)

DOCKER_COMPOSE_DIRECTORY=$BASE_URL/docker-compose
KEY_STORES_DIRECTORY=$BASE_URL/keystores
WSO2_IS_SERVER=$BASE_URL/wso2is_with_obiam
WSO2_AM_SERVER=$BASE_URL/wso2am_with_obam
MY_SQL=$BASE_URL/my_sql

lsof -ti:8000 | xargs kill -9 2>/dev/null || true


python3 -m http.server 8000 &
SERVER_PID=$!



cd "$MY_SQL"

docker build -t ob_database .
echo "mysql build complete"

cd "$WSO2_IS_SERVER"


docker build --build-arg BASE_PRODUCT_VERSION=7.1.0 --build-arg OB_TRUSTED_CERTS_URL=http://host.docker.internal:8000/trust_certs.zip --build-arg WSO2_OB_KEYSTORES_URL=http://host.docker.internal:8000/keystores --build-arg RESOURCE_URL=http://host.docker.internal:8000 --no-cache -t wso2is-ob:4.0.0 .
echo "IS server build complete"

cd "$WSO2_AM_SERVER"
docker build --build-arg BASE_PRODUCT_VERSION=4.5.0 --build-arg OB_TRUSTED_CERTS_URL=http://host.docker.internal:8000/trust_certs.zip --build-arg WSO2_OB_KEYSTORES_URL=http://host.docker.internal:8000/keystores --build-arg RESOURCE_URL=http://host.docker.internal:8000 --no-cache -t wso2am-ob:4.0.0 .
echo "AM server build complete"

cd "$DOCKER_COMPOSE_DIRECTORY/wso2am-with-wso2is"

docker compose up

echo "IS server uo and running"
