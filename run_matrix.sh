#!/bin/bash

# Load the matrix configuration
matrix_file="matrix.yml"
output_dir=".data"
summary_file="$output_dir/summary.csv"

# Create output directory if it doesn't exist
mkdir -p $output_dir

# Create summary CSV file with headings if it doesn't exist
if [ ! -f $summary_file ]; then
  echo "runtime,instance,async,image,sql,setting,load,start_time,stop_time,time,success_line,statistics,note" > $summary_file
fi

# Read the matrix configuration
instances=$(yq e '.instances[]' $matrix_file)
async=$(yq e '.async[]' $matrix_file)
images=$(yq e '.images[]' $matrix_file)
sql=$(yq e '.sql[]' $matrix_file)
settings=$(yq e '.settings[]' $matrix_file)
loads=$(yq e '.loads[]' $matrix_file)

# Iterate over the matrix and run jobs
for instance in $instances; do
  for async_value in $async; do
    for image in $images; do
      for sql_version in $sql; do
        for setting in $settings; do
          for load in $loads; do
            runtime=$(date +%s)
            image_name=$(echo $image | tr '/' '-')
            job_dir="$output_dir/${runtime}_instance${instance}_async${async_value}_image${image_name}_sql${sql_version}_setting${setting}_load${load}"
            mkdir -p $job_dir
            echo "Running job with instance=$instance, async=$async_value, image=$image, sql=$sql_version, setting=$setting, load=$load"
            # Export the env vars
            export PROFILE_IMAGE=$image
            export PROFILE_SETTINGS=$setting
            export PROFILE_SQL=$sql_version
            # Run the job
            docker-compose up -d mysql wikibase1
            ./docker-compose-wait1.sh
            docker-compose up -d wikibase2
            ./docker-compose-wait2.sh
            docker-compose up -d --force-recreate wikibase1
            ./docker-compose-wait1.sh
            sleep 5
            echo "Running load.."
            start_time=$(date +%s)
            echo "Start time: $start_time" > $job_dir/start.out
            ASYNC=$async_value INSTANCES=$instance ./loads/$load.sh
            stop_time=$(date +%s)
            total_time=$((stop_time - start_time))
            echo "Stop time: $stop_time" > $job_dir/stop.out
            echo "Total time: $total_time" > $job_dir/time.out
            success_line=$(cat process.out | grep "success" | wc -l)
            echo "Success line: $success_line" > $job_dir/success_line.out
            cp process.out $job_dir/process.out
            rm process.out
            # Get statistics, but do it twice to make sure things have finished processing, and sleep in the middle?
            sleep 5
            statistics=$(curl -s 'http://localhost:8181/w/api.php?action=query&format=json&meta=siteinfo&siprop=statistics')
            sleep 5
            statistics=$(curl -s 'http://localhost:8181/w/api.php?action=query&format=json&meta=siteinfo&siprop=statistics')
            echo "Statistics: $statistics" > $job_dir/statistics.json
            # Append summary to CSV
            echo "$runtime,$instance,$async_value,$image,$sql_version,$setting,$load,$start_time,$stop_time,$total_time,$success_line,$statistics" >> $summary_file
            # And output it
            echo "$runtime,$instance,$async_value,$image,$sql_version,$setting,$load,$start_time,$stop_time,$total_time,$success_line,$statistics"
            docker-compose down --volumes
          done
        done
      done
    done
  done
done
