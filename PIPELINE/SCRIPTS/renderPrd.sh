#!/bin/bash
set -x
dept=$1
proj=$2
app=$3

source /home/dmarom/ws/gitToken.sh

if [ -z "$dept" ] || [ -z "$proj" ] || [ -z "$app" ]|| [ -z "$MENORA_GIT_TOKEN" ]; then
    echo "Usage: $0 <dept> <Proj> <App>, MENORA_GIT_TOKEN needs to be set as Environment Variable" 
    exit 1
fi

source_repo=https://github.com/danielmarom78/menora.git
source_branch=main
source_chart_path=Application
source_dept_values_path=Application/$dept
source_values_files_path=Application/$dept/$proj/$app/prd

target_repo=https://github.com/danielmarom78/menora.git
target_branch=Production
target_app_path=/$dept/$proj/$app

yaml_path_app_name=pipeline.appName
yaml_path_namespace=pipeline.namespace

temp_dir=/tmp/RENDEDER
temp_dir_rendered=$temp_dir/RENDERED
temp_dir_source=$temp_dir/SOURCE
temp_dir_target=$temp_dir/TARGET


echo "############ Starting Script... (Dept=$dept, Proj=$proj, App=$app)"

set -e # Exit on any fail
rm -rf $temp_dir

git config --global user.email "Pipeline@redhat.com"
git config --global user.name "CI Pipeline"

# Clone sparse source
echo "############ 1/4 Cloning Source... (repo=$source_repo branch=$source_branch)"
mkdir -p $temp_dir_source
git clone -b $source_branch https://$MENORA_GIT_TOKEN:x-oauth-basic@${source_repo#https://} $temp_dir_source

# Clone target
echo "############ 2/4 Cloning target... (repo=$target_repo branch=$target_branch)"
mkdir -p $temp_dir_target
git clone -b $target_branch https://$MENORA_GIT_TOKEN:x-oauth-basic@${target_repo#https://} $temp_dir_target

# Render manifests
echo "############ 3/4 Rendering manifests..."

helm dependency build $temp_dir_source/$source_chart_path

rm -rf $temp_dir_target/$target_app_path

for val_file in $(find "$temp_dir_source/$source_values_files_path" -type f); do
    app_name=$(yq e .$yaml_path_app_name "$val_file")
    namespace=$(yq e .$yaml_path_namespace "$val_file")
    artifacts_render_path=$temp_dir_rendered/$app_name
    artifacts_target_path=$temp_dir_target/$target_app_path/$app_name/$namespace

    echo "Running Helm Lint... ($val_file app_name=$app_name, $yaml_path_namespace=$namespace)"
    helm lint $temp_dir_source/$source_chart_path -f "$val_file" --set application.envName=prd

    echo "Running Helm template..."
    mkdir -p $artifacts_render_path
    helm template $temp_dir_source/$source_chart_path -f "$val_file" -n $namespace --output-dir $artifacts_render_path --set application.envName=prd
    
    mkdir -p $artifacts_target_path
    cp $artifacts_render_path/proxy-chart/charts/application/templates/*.yaml $artifacts_target_path
done

printf '%s\n' "$(tree "$temp_dir_target")"

# Committing target
echo "############# 4/4 Commit & push rendered manifests..."
cd $temp_dir_target
git add .

if git diff --quiet && git diff --staged --quiet; then
echo "No changes to commit. Script finished successfully"
exit 0
fi

git commit -m "Committed by CI pipeline for app=$app project=$proj"
git push

echo "Script finished successfully"