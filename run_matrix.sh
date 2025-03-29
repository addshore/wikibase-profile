#!/bin/bash

# Load the matrix configuration
matrix_file="matrix.yml"
output_dir=".data"
summary_file="$output_dir/summary.csv"

# Create output directory if it doesn't exist
mkdir -p $output_dir

# Create summary CSV file with headings if it doesn't exist
if [ ! -f $summary_file ]; then
  echo "runtime,instance,async,image,sql,setting,load,entity_count,start_time,stop_time,time,success_line,statistics,entity_group,note" > $summary_file
fi

# Read the matrix configuration
instances=$(yq e '.instances[]' $matrix_file)
async=$(yq e '.async[]' $matrix_file)
images=$(yq e '.images[]' $matrix_file)
sql=$(yq e '.sql[]' $matrix_file)
settings=$(yq e '.settings[]' $matrix_file)
loads=$(yq e '.loads[]' $matrix_file)
entity_groups=$(yq e '.entity_groups[]' $matrix_file || echo "1")
entity_counts=$(yq e '.entity_counts[]' $matrix_file || echo "5000")

# Iterate over the matrix and run jobs
for instance in $instances; do
  for async_value in $async; do
    for image in $images; do
      for sql_version in $sql; do
        for setting in $settings; do
          for load in $loads; do
            for entity_group in $entity_groups; do
              for entity_count in $entity_counts; do
                runtime=$(date +%s)
                image_name=$(echo $image | tr '/' '-')
                job_dir="$output_dir/${runtime}_instance${instance}_async${async_value}_image${image_name}_sql${sql_version}_setting${setting}_load${load}_entityGroup${entity_group}_entityCount${entity_count}"
                mkdir -p $job_dir
                echo "Running job with instance=$instance, async=$async_value, image=$image, sql=$sql_version, setting=$setting, load=$load, entity_group=$entity_group, entity_count=$entity_count"
                # Export the env vars
                export PROFILE_IMAGE=$image
                export PROFILE_SETTINGS=$setting
                export PROFILE_SQL=$sql_version
                export ENTITY_GROUP=$entity_group
                export ENTITY_COUNT=$entity_count

                # Cleanup previous
                docker-compose down --volumes
                rm -f process.out

                # Run the job
                docker-compose up -d mysql wikibase1
                ./docker-compose-wait1.sh
                # docker-compose up -d wikibase2
                # ./docker-compose-wait2.sh
                docker-compose up -d --force-recreate wikibase1
                ./docker-compose-wait1.sh
                sleep 2

                echo "Running init.."
                start_time=$(date +%s)
                INSTANCES=$instance ./loads/init.sh
                stop_time=$(date +%s)
                total_time=$((stop_time - start_time))
                echo "Load time: $total_time" > $job_dir/load.out
                sleep 1
                echo "Running load.."
                start_time=$(date +%s)
                echo "Start time: $start_time" > $job_dir/start.out
                ASYNC=$async_value INSTANCES=$instance ENTITY_GROUP=$entity_group ENTITY_COUNT=$entity_count ./loads/$load.sh
                stop_time=$(date +%s)
                total_time=$((stop_time - start_time))
                echo "Stop time: $stop_time" > $job_dir/stop.out
                echo "Total time: $total_time" > $job_dir/time.o
                success_line=$(grep -o "success" process.out | wc -l)
                if [[ $load == *"rest"* ]]; then
                  success_line=$((success_line + $(grep -o '"type":"item"' process.out | wc -l)))
                fi
                echo "Success line: $success_line" > $job_dir/success_line.out
                cp process.out $job_dir/process.out
                # Get statistics, but do it twice to make sure things have finished processing, and sleep in the middle?
                # sleep 2
                # statistics=$(curl -s 'http://localhost:8181/w/api.php?action=query&format=json&meta=siteinfo&siprop=statistics')
                # sleep 2
                # statistics=$(curl -s 'http://localhost:8181/w/api.php?action=query&format=json&meta=siteinfo&siprop=statistics')
                # echo "Statistics: $statistics" > $job_dir/statistics.json
                # Escape commas in variables for CSV
                escaped_image=$(echo "$image" | sed 's/,/\\,/g')
                # escaped_statistics=$(echo "$statistics" | sed 's/,/\\,/g')
                escaped_statistics="{}" # This doesn't update fast enough to be useful
                escaped_setting=$(echo "$setting" | sed 's/,/\\,/g')
                escaped_load=$(echo "$load" | sed 's/,/\\,/g')

                # Append summary to CSV
                echo "$runtime,$instance,$async_value,$escaped_image,$sql_version,$escaped_setting,$escaped_load,$entity_count,$start_time,$stop_time,$total_time,$success_line,$escaped_statistics,$entity_group," >> $summary_file
                # And output it
                echo "$runtime,$instance,$async_value,$escaped_image,$sql_version,$escaped_setting,$escaped_load,$entity_count,$start_time,$stop_time,$total_time,$success_line,$escaped_statistics,$entity_group,"
                # And output the directory
                echo "Output directory: $job_dir"

                # Cleanup
                docker-compose down --volumes
              done
            done
          done
        done
      done
    done
  done
done
