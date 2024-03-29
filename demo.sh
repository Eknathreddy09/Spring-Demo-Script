#!/usr/bin/env bash

# Load helper functions and set initial variables
vendir sync
. ./vendir/demo-magic/demo-magic.sh
export TYPE_SPEED=50
export DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"
TEMP_DIR="spring-demo-eknath"
PROMPT_TIMEOUT=10

# Function to pause and clear the screen
function talkingPoint() {
  wait
  clear
}

# Initialize SDKMAN and install required Java versions
function initSDKman() {
  local sdkman_init="${SDKMAN_DIR:-$HOME/.sdkman}/bin/sdkman-init.sh"
  if [[ -f "$sdkman_init" ]]; then
    source "$sdkman_init"
  else
    echo "SDKMAN not found. Please install SDKMAN first."
    exit 1
  fi
  sdk update
  sdk install java 8.0.392-librca
  sdk install java 17.0.9-librca
  sdk install java 21.0.1-graalce
}

# Prepare the working directory
function init {
  rm -rf "$TEMP_DIR"
  mkdir "$TEMP_DIR"
  cd "$TEMP_DIR" || exit
  clear
}

# Switch to Java 8 and display version
function useJava8 {
  displayMessage "Use Java 8, this is for educational purposes only, don't do this at home! (I have jokes.)"
  pei "sdk use java 8.0.392-librca"
  pei "java -version"
}

# Switch to Java 17 and display version
function useJava21 {
  displayMessage "Switch to Java 17 for Spring Boot 3"
  pei "sdk use java 21.0.1-graalce"
  pei "java -version"
}

# Switch to Java 21 and display version
function useJava17 {
  displayMessage "Switch to Java 21 for Spring Boot 3"
  pei "sdk use java 17.0.9-librca"
  pei "java -version"
}

# Create a simple Spring Boot application
function cloneApp {
  displayMessage "Clone a Spring Boot 2.6.0 application"
  pei "git clone https://github.com/dashaun/hello-spring-boot-2-6.git ./"
}

# Start the Spring Boot application
function springBootStart {
  displayMessage "Start the Spring Boot application"
  pei "./mvnw -q clean package spring-boot:start -DskipTests 2>&1 | tee '$1' &"
}

# Stop the Spring Boot application
function springBootStop {
  displayMessage "Stop the Spring Boot application"
  pei "./mvnw spring-boot:stop -Dspring-boot.stop.fork"
}

# Check the health of the application
function validateApp {
  displayMessage "Check application health"
  pei "http :8080/actuator/health"
}

# Display memory usage of the application
function showMemoryUsage {
  local pid=$1
  local log_file=$2
  local rss=$(ps -o rss= "$pid" | tail -n1)
  local mem_usage=$(bc <<< "scale=1; ${rss}/1024")
  echo "The process was using ${mem_usage} megabytes"
  echo "${mem_usage}" >> "$log_file"
}

# Prepare the dependencies file for 2.6
function sharreport26 {
  displayMessage "Prepare the dependencies file for SHAR Report"
  pei "./mvnw dependency:tree | grep -E '(org.springframework|io.micrometer)' > /Users/reddye/Desktop/SHARreports/spring-dependencies26.txt"
}

# Upgrade the application to Spring Boot 3.0
function rewriteApplication30 {
  displayMessage "Upgrade to Spring Boot 3.0"
  pei "./mvnw -U org.openrewrite.maven:rewrite-maven-plugin:run -Drewrite.recipeArtifactCoordinates=org.openrewrite.recipe:rewrite-spring:RELEASE -Drewrite.activeRecipes=org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_0"
}

# Prepare the dependencies file for 3.0
function sharreport30 {
  displayMessage "Prepare the dependencies file for SHAR Report"
  pei "./mvnw dependency:tree | grep -E '(org.springframework|io.micrometer)' > /Users/reddye/Desktop/SHARreports/spring-dependencies30.txt"
}

# Upgrade the application to Spring Boot 3.2
function rewriteApplication {
  displayMessage "Upgrade to Spring Boot 3.2"
  pei "./mvnw -U org.openrewrite.maven:rewrite-maven-plugin:run -Drewrite.recipeArtifactCoordinates=org.openrewrite.recipe:rewrite-spring:LATEST -DactiveRecipes=org.openrewrite.java.spring.boot3.UpgradeSpringBoot_3_2"
}

# Prepare the dependencies file for 3.2
function sharreport32 {
  displayMessage "Prepare the dependencies file for SHAR Report"
  pei "./mvnw dependency:tree | grep -E '(org.springframework|io.micrometer)' > /Users/reddye/Desktop/SHARreports/spring-dependencies32.txt"
}

# Build a native image of the application
function buildNative {
  displayMessage "Build a native image with AOT"
  pei "./mvnw -Pnative native:compile"
}

# Start the native image
function startNative {
  displayMessage "Start the native image"
  pei "./target/hello-spring 2>&1 | tee nativeWith3.2.log &"
}

# Stop the native image
function stopNative {
  displayMessage "Stop the native image"
  local npid=$(pgrep hello-spring)
  pei "kill -9 $npid"
}

# Build OCI images
function buildOCI {
  displayMessage "Build OCI images"
  pei "docker pull dashaun/builder:tiny && docker tag dashaun/builder:tiny paketobuildpacks/builder:tiny && docker tag dashaun/builder:tiny paketobuildpacks/builder:base"
  pei "./mvnw clean spring-boot:build-image -Dspring-boot.build-image.imageName=demo:0.0.1-JVM -Dspring-boot.build-image.createdDate=now"
  pei "./mvnw clean -Pnative spring-boot:build-image -Dspring-boot.build-image.imageName=demo:0.0.1-Native -Dspring-boot.build-image.createdDate=now"
}

# Display a message with a header
function displayMessage() {
  echo "#### $1"
  echo ""
}

function startupTime() {
  echo "$(sed -nE 's/.* in ([0-9]+\.[0-9]+) seconds.*/\1/p' < $1)"
}

# Compare and display statistics
function statsSoFar {
  displayMessage "Comparison of memory usage and startup times"
  echo ""
  echo "Spring Boot 2.6 with Java 8"
  grep -o 'Started HelloSpringApplication in .*' < java8with2.6.log
  echo "The process was using $(cat java8with2.6.log2) megabytes"
  echo ""
  echo ""
  echo "Spring Boot 3.0 with Java 17"
  grep -o 'Started HelloSpringApplication in .*' < java17with3.0.log
  echo "The process was using $(cat java17with3.0.log2) megabytes"
  echo ""
  echo ""
  echo "Spring Boot 3.2 with Java 21"
  grep -o 'Started HelloSpringApplication in .*' < java21with3.2.log
  echo "The process was using $(cat java21with3.2.log2) megabytes"
  echo ""
  echo ""
  echo "Spring Boot 3.2 with AOT processing, native image"
  grep -o 'Started HelloSpringApplication in .*' < nativeWith3.2.log
  echo "The process was using $(cat nativeWith3.2.log2) megabytes"
  echo ""
  echo ""
  MEM1="$(grep '\S' java8with2.6.log2)"
  MEM4="$(grep '\S' java17with3.0.log2)"
  MEM2="$(grep '\S' java21with3.2.log2)"
  MEM3="$(grep '\S' nativeWith3.2.log2)"
  echo ""
  echo "The Spring Boot 3.2 with Java 21 version is using $(bc <<< "scale=2; ${MEM2}/${MEM1}*100")% of the original footprint"
  echo "The Spring Boot 3.2 with AOT processing version is using $(bc <<< "scale=2; ${MEM3}/${MEM1}*100")% of the original footprint"
}

function statsSoFarTable {
  displayMessage "Comparison of memory usage and startup times"
  echo ""

  # Headers
  printf "%-35s %-25s %-15s %-15s %-15s %-15s %s\n" "Configuration" "Startup Time(seconds)" "(MB)Used" "(MB)Savings" "(Lib without OSS Support)" "(Lib with Vulnerabilities)" "(Lib with High Effort Upgrades)"
  echo "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

  # Spring Boot 2.6 with Java 8
  #STARTUP1=$(sed -nE 's/.* in ([0-9]+\.[0-9]+) seconds.*/\1/p' < java8with2.6.log)
  #STARTUP1=$(grep -o 'Started HelloSpringApplication in .*' < java8with2.6.log)
  MEM1=$(cat java8with2.6.log2)
  printf "%-35s %-25s %-15s %-20s %-25s %-25s %s\n" "Spring Boot 2.6 with Java 8" "$(startupTime 'java8with2.6.log')" "$MEM1" "-" "61%" "91%" "96%"
  
# Spring Boot 3.0 with Java 17
  #STARTUP4=$(sed -nE 's/.* in ([0-9]+\.[0-9]+) seconds.*/\1/p' < java17with3.0.log)
  #STARTUP4=$(grep -o 'Started HelloSpringApplication in .*' < java17with3.0.log)
  MEM4=$(cat java17with3.0.log2)
  PERC4=$(bc <<< "scale=2; 100 - ${MEM4}/${MEM1}*100")
  printf "%-35s %-25s %-15s %-20s %-25s %-25s %s\n" "Spring Boot 3.0 with Java 17" "$(startupTime 'java17with3.0.log')" "$MEM4" "$PERC4%" "64%" "32%" "0%"

  # Spring Boot 3.2 with Java 21
  #STARTUP2=$(grep -o 'Started HelloSpringApplication in .*' < java21with3.2.log)
  MEM2=$(cat java21with3.2.log2)
  PERC2=$(bc <<< "scale=2; 100 - ${MEM2}/${MEM1}*100")
  printf "%-35s %-25s %-15s %-20s %-25s %-25s %s \n" "Spring Boot 3.2 with Java 21" "$(startupTime 'java21with3.2.log')" "$MEM2" "$PERC2%" "0%" "0%" "0%"

  # Spring Boot 3.2 with AOT processing, native image
  #STARTUP3=$(grep -o 'Started HelloSpringApplication in .*' < nativeWith3.2.log)
  MEM3=$(cat nativeWith3.2.log2)
  PERC3=$(bc <<< "scale=2; 100 - ${MEM3}/${MEM1}*100")
  printf "%-35s %-25s %-15s %-20s %-25s %-25s %s \n" "Spring Boot 3.2 with AOT, native" "$(startupTime 'nativeWith3.2.log')" "$MEM3" "$PERC3%" "0%" "0%" "0%"

  echo "--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
}

function recommendation {
  displayMessage " Recommendations from Spring Team after reviewing the SHAR reports"
  echo "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
  echo ""
  echo "For Application using Spring 2.6, It is recommended to upgrade to 3.2 with help of Spring Consulting team or purchase spring runtime to extend your support until Mar 13, 2025, for 9 libraries which are set to expire in 5 months"
  echo ""
  echo "For Application using Spring 3.0, Either upgrade to 3.2.x or Purchase Spring Runtime to extend your support until Mar 13, 2025 to avoid the risk of any vulnerabilities"
  echo ""
  echo "For Application using spring 3.2, Purchase Spring Runtime to extend your support until Mar 13, 2025 , for 26 libraries which are set to expire in 8 months"
  echo ""
  echo "-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
}

# Display Docker image statistics
function imageStats {
  pei "docker images | grep demo"
}

# Main execution flow
initSDKman
init
useJava8
talkingPoint
cloneApp
talkingPoint
springBootStart java8with2.6.log
talkingPoint
validateApp
talkingPoint
showMemoryUsage "$(jps | grep 'HelloSpringApplication' | cut -d ' ' -f 1)" java8with2.6.log2
talkingPoint
springBootStop
talkingPoint
sharreport26
useJava17
rewriteApplication30
springBootStart java17with3.0.log
talkingPoint
validateApp
talkingPoint
showMemoryUsage "$(jps | grep 'HelloSpringApplication' | cut -d ' ' -f 1)" java17with3.0.log2
talkingPoint
springBootStop
talkingPoint
sharreport30
talkingPoint
rewriteApplication
talkingPoint
useJava21
talkingPoint
springBootStart java21with3.2.log
talkingPoint
validateApp
talkingPoint
sharreport32
showMemoryUsage "$(jps | grep 'HelloSpringApplication' | cut -d ' ' -f 1)" java21with3.2.log2
talkingPoint
springBootStop
talkingPoint
buildNative
talkingPoint
startNative
talkingPoint
validateApp
talkingPoint
showMemoryUsage "$(pgrep hello-spring)" nativeWith3.2.log2
talkingPoint
stopNative
talkingPoint
#statsSoFar
statsSoFarTable
recommendation
