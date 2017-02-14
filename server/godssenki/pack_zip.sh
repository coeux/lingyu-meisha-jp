echo "==pack yserver zip=="

rm release -rf
mkdir release
mkdir release/scene/
mkdir release/route/
mkdir release/login/
mkdir release/gateway/
mkdir release/invcode/

cp login/login release/login/
cp gateway/gateway release/gateway/
cp route/route release/route
cp scene/scene release/scene/
cp invcode/invcode release/invcode/

cp gmtool/ release -r

mkdir release/sql_scripts/
cp sql_scripts/sql.sh release/sql_scripts/
cp sql_scripts/*.sql release/sql_scripts/

mkdir release/repo/
cp repo/*.json release/repo/
cp repo/full_name.txt release/repo/

cp script/ release/ -r

mkdir release/simu_tool/
cp simu_script/ release/simu_tool/ -r
cp simu_client/client release/simu_tool/
cp tool/gen_robot.sh release/simu_tool

cp config.lua release/config.lua.backup
cp startup.sh release/

cp release release-`date +%Y-%m-%d` -r
zip -r release-`date +%Y-%m-%d`.zip release-`date +%Y-%m-%d`/
rm release-`date +%Y-%m-%d` -rf

echo "==pack yserver zip=="
