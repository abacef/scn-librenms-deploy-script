if ! command -v docker > /dev/null; then
  echo "Docker is not installed. Please install docker."
  exit 1
fi

if ! command -v unzip > /dev/null; then
  echo "unzip is not installed. Please install it"
  exit 1
fi

if ! docker compose > /dev/null; then
  echo "docker compose not installed. Please install the docker compose plugin"
  exit 1
fi

set -e

cd librenms_image
docker build . -t scn-librenms
cd ..

if [ -f "librenms.sql" ]; then
  mkdir tmp
  cp db_image_with_backup/Dockerfile tmp
  cp librenms.sql tmp
  cd tmp
  docker build . -t scn_mariadb_librenms
  cd ..
  rm -r tmp
else
  cd db_image
  docker build . -t scn_mariadb_librenms
  cd ..
fi

docker compose -f compose/compose.yml up -d

sleep 5

if [ -f "rrd.zip" ]; then
  cd compose/librenms
  cp ../../rrd.zip .
  unzip rrd.zip
  rm rrd.zip
  cd ../..
fi
