#!/bin/bash

if [ "$#" -ne 2 ]; then
	echo -e "\n"
    echo "Illegal number of parameters."
    echo "USAGE: arthas_execution_kubernetes.sh <POD_NAME_PATTERN> <ARTHAS_COMMAND>"
    echo "this command will apply the given <ARTHAS_COMMAND> to all pods having in its name the string <POD_NAME_PATTERN>"
    echo -e "\n"
    echo 'Example: arthas_execution_kubernetes.sh "my-pod" "dashboard"'
    echo -e "\n"
    exit;
fi


POD_NAME_PATTERN=$1
ARTHAS_COMMAND=$2

# this is the command that will be executed inside of the pod's shell to obtain 
# java pid for the application to be applied arthas command
 
PID_JAVA_SERVICE="ps -ef | grep -v 'grep java' | grep -v 'arthas-boot.jar' | grep java | awk '{print $"
PID_JAVA_SERVICE="${PID_JAVA_SERVICE}1'}"

POD_NAMES=$( kubectl get pods   | grep -P $POD_NAME_PATTERN | cut -d ' ' -f1 )

echo -e "\n"
echo "The following Arthas command:"
echo -e "\n"
echo $ARTHAS_COMMAND
echo -e "\n"
echo "will be applied to the following PODS:"
echo -e "\n"
echo $POD_NAMES  | tr ' ' '\n'  
echo -e "\n"
read -r -p "Are you sure? [y/N] " response
echo -e "\n"

case "$response" in

    [yY][eE][sS]|[yY]) 
        echo $POD_NAMES | tr ' ' '\n' | xargs -tI{} kubectl exec {} -- bash -c \
        "curl -O https://arthas.aliyun.com/arthas-boot.jar; java -jar arthas-boot.jar -c \"$ARTHAS_COMMAND\" \$($PID_JAVA_SERVICE)" 

        echo "The Arthas command was applied."
        ;;
    *)
        echo "The Arthas command was not applied."
        ;;
esac
