#!/bin/bash
# Max seconds for the dependency to initialize
INIT_TIME=30
# How many seconds between checks
SLEEP_TIME=150

# Get container start time in this format: 2022-05-30T09:45:17.858752818Z
get_container_starttime () {
  docker inspect --format='{{.State.StartedAt}}' $1
}

# Convert start time to seconds since epoch for easy math/comparison
get_starttime_secs () {
  date +%s -d $1
}

# Get current time as seconds since epoch
get_currenttime_secs () {
  date +%s
}

log () {
  echo "$(date +"%Y-%m-%d %a %H:%M:%S") $1"
}

# Iterate dependent containers
while :
do
  if docker container inspect $DEPENDENT_CONTAINER > /dev/null 2>&1 ; then
    dependentStartTime=$(get_container_starttime $DEPENDENT_CONTAINER)
    dependentStartSecs=$(get_starttime_secs $dependentStartTime)
    if [ ! docker container inspect $DEPENDENCY_CONTAINER > /dev/null 2>&1 ] ; then
      docker-compose rm -fsv $DEPENDENCY_CONTAINER
      docker-compose up -d $DEPENDENCY_CONTAINER
      sleep 3
    fi
    if [ ! docker container inspect $DEPENDENCY_CONTAINER > /dev/null 2>&1 ] ; then
      log "$DEPENDENCY_CONTAINER couldn't be started; you'll need to resolve this yourself."
    else
      dependencyStartTime=$(get_container_starttime $DEPENDENCY_CONTAINER)
      dependencyStartSecs=$(get_starttime_secs $dependencyStartTime)
      let "earliestValidStartSecs = $dependencyStartSecs + $INIT_TIME"
      let "gapTime = $dependentStartSecs - $earliestValidStartSecs"
      if [ $gapTime -lt 0 ] ; then
        currentTime=$(get_currenttime_secs)
        let "waitTime = $earliestValidStartSecs - $currentTime"
        if [ $waitTime -gt 0 ] ; then
          log "Waiting $waitTime seconds for $DEPENDENCY_CONTAINER to initialize..."
          sleep $waitTime
        fi
        log "$DEPENDENT_CONTAINER was started before $DEPENDENCY_CONTAINER initialized. Recreating..."
        docker-compose rm -fsv $DEPENDENT_CONTAINER
        docker-compose up -d $DEPENDENT_CONTAINER
      fi
    fi
  else
    log "Dependent container not running: $DEPENDENT_CONTAINER"
    log "Trying to start..."
    docker-compose rm -fsv -v $DEPENDENT_CONTAINER
    docker-compose up -d $DEPENDENT_CONTAINER
  fi
  sleep $SLEEP_TIME
done

