#!/bin/bash
#
echo "------------------------------"
echo " Merging Kafka"
echo "------------------------------"

# Update sort order of index files

for i in $( ls ./pages/services/kafka/*/index.md );
do
  awk '/^menuWeight:/ {sub(/[[:digit:]]+$/,$NF+10)}1 {print}' $i > $i.tmp && mv $i.tmp $i
done

# Get values for version and directory variable

branch=$1
if [ -z "$1" ]; then echo "Enter a branch as the first argument."; exit 1; fi
directory=$2
if [ -z "$2" ]; then echo "Enter a directory name as the second argument."; exit 1; fi

# Create directory structure

echo "Creating new directories"
mkdir ./pages/services/kafka/$directory
mkdir ./pages/services/kafka/$directory/img
echo "New directories created: /pages/services/kafka/$directory and /pages/services/kafka/$directory/img"

# Move to the top level of the repo
root="$(git rev-parse --show-toplevel)"
cd $root

# pull dcos-commons
git remote rm dcos-commons
git remote add dcos-commons https://github.com/mesosphere/dcos-commons.git
git fetch dcos-commons > /dev/null 2>&1

# checkout each file in the merge list from dcos-kafka-service
while read p;
do
  echo $p
  # checkout
  git checkout dcos-commons/$branch $p

  # markdown files only
  if [ ${p: -3} == ".md" ]; then
        # insert tag ( markdown files only )
    awk -v n=2 '/---/ { if (++count == n) sub(/---/, "---\n\n<!-- This source repo for this topic is https://github.com/mesosphere/dcos-commons -->\n"); } 1{print}' $p > tmp && mv tmp $p
        # remove https://docs.mesosphere.com from links
    awk '{gsub(/https:\/\/docs.mesosphere.com\/1.9\//,"/1.9/");}{print}' $p > tmp && mv tmp $p
    awk '{gsub(/https:\/\/docs.mesosphere.com\/1.10\//,"/1.10/");}{print}' $p > tmp && mv tmp $p
    awk '{gsub(/https:\/\/docs.mesosphere.com\/1.10\//,"/1.11/");}{print}' $p > tmp && mv tmp $p
    awk '{gsub(/https:\/\/docs.mesosphere.com\/latest\//,"/latest/");}{print}' $p > tmp && mv tmp $p
    awk '{gsub(/https:\/\/docs.mesosphere.com\/service-docs\//,"/services/");}{print}' $p > tmp && mv tmp $p

      # add full path for images
    awk -v directory="$directory" '{gsub(/\(img/,"(/services/kafka/"directory"/img");}{print;}' $p > tmp && mv tmp $p
    
    # if it's not an index file, make a directory from the filename, rename file to "index.md"
    if [ ${p: -8} != "index.md" ]; then
      directory_from_filename=$p
      tmp_val=$(echo "$directory_from_filename" | sed 's/...$//')
      directory_from_filename=$tmp_val
      mkdir $directory_from_filename
      mv $p $directory_from_filename/index.md
    fi
  fi

cp -r frameworks/kafka/docs/* ./pages/services/kafka/$directory

done <scripts/merge-lists/dcos-kafka-service-merge-list.txt

git rm -rf frameworks

# Add version information to latest index file

sed -i '' -e "2s/.*/navigationTitle: Kafka $directory/g" ./pages/services/kafka/$directory/index.md
sed -i '' -e "2s/.*/title: Kafka $directory/g" ./pages/services/kafka/$directory/index.md
echo "---------------------------------------"
echo " Kafka merge complete"
echo "---------------------------------------"
