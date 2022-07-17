# Bash

Bash scripts and notes

## General examples

### Infinite loop
```
while true; do rm -f filename*; done
```
* change "rm -f filename*" for whatever instruction you need. 

### Files and directory size

```
du -sch . 
```

### knowing open ports
```
netstat -lntu
netstat --listen
```
## kill process by port

```
kill -9 $(lsof -ti:9998,9991,9999)
```

### Open a connection via port x

```
nc -l -vv -p 8000
```

### Example of use of cut + xargs
```
docker ps -a |cut -d " " -f 1 |xargs -i docker rm "{}"
```
### Sorting first 20 heaviest files

```
du -ah . | sort -n -r | head -n 20
```

### Grep/Find 
```
grep -Er “github.com|bitbucket” PATH
find PATH -name "requirements.txt" | xargs -i grep github.com '{}'|wc -l
grep "May  7 09:33" /var/log/maillog  | grep "id=" | wc -l
grep "May  7 09:" /var/log/maillog  | grep "id=" | cut -d':' -f2 | uniq -c | awk '{print "09:"$2" - mail_sent:"$1}'
grep "May  7 09:33" /var/log/maillog  | awk '{print $6}' | sort | uniq | grep -v conn | wc -l # -v to exclude 
find . -name '*.pdf' -newermt 2012-01-31 ! -newermt 2012-02-29 | wc -l #find with threshold time
sudo docker volume list |awk '{print $2}' 
```
### fizz or buzz example

```
#!/bin/bash
 
function isDivisibleBy {
    return $(($1%$2))
}
 
function fizzOrBuzz {
    output=""
    isDivisibleBy $1 3 && output="Fizz"
    isDivisibleBy $1 5 && output="${output}Buzz"
    if [ -z $output ]; then
        echo $1
    else
        echo $output;
    fi
}
 
for number in {1..100}; do
    echo "-`fizzOrBuzz $number`"
done

#!/bin/bash
 
function isDivisibleBy {
    return $(($1%$2))
}
 
function fizzOrBuzz {
    output=""
    if isDivisibleBy $1 3; then
        output="Fizz"
    fi
    if isDivisibleBy $1 5; then
        output="${output}Buzz"
    fi
    if [ -z $output ]; then
        echo $1
    else
        echo $output;
    fi
}
 
for number in {1..100}; do
    fizzOrBuzz $number
done

```

```
#!/bin/bash

## NICE COLOR AND UTF8
GREENCHECK="\e[32m\e[1m\u2713\e[0m\e[39m"
GREENOK="\e[32mOK\e[39m"
REDCROSS="\e[91m\e[1m\u274C\e[0m\e[39m"
REDERROR="\e[91mERROR\e[39m"

if [[ "$1" == "test" ]]; then
        CONF="docker-compose-test.yml"
elif [[ "$1" == "prod" ]]; then
        CONF="docker-compose.yml"
else
        echo -e "[${REDERROR}] You must provide a full restart mode 'test' or 'prod'"
        echo "Usage: $0 test   -or-   $0 prod"
        exit
fi

if [[ ! -f $CONF ]]; then
        echo -e "[${REDERROR}] Can not find Compose file '${CONF}'. Please check that you are running this script inside a Docker directory."
fi

echo -n " - Checking that RabbitMQ is running..."

CONTAINER=$(docker ps -a --format "{{.Status}} {{.Names}}" |  grep -i ${PWD##*/} | grep rabbit)
if [[ $(echo -e "$CONTAINER" | wc -l) -ne 1 ]]; then
        echo -e "[${REDERROR}]\n\t > Looks like there is more than 1 rabbit running (or old snapshots still present. Check manually."
        exit
fi
if [[ $(echo -e "$CONTAINER" | cut -d' ' -f1 | grep Up | wc -l) -eq 1 ]]; then
        echo -e "[${GREENOK}]"
fi

CONTAINERNAME=$(echo -e "$CONTAINER" | rev | cut -d' ' -f1 | rev | cut -d'_' -f2- | rev | cut -d'_' -f2- | rev)
docker-compose -f $CONF exec $CONTAINERNAME /bin/bash -c 'rabbitmqctl list_queues'
```
## References
* https://www.cyberciti.biz/faq/unix-linux-execute-command-using-ssh/   (Running comands remotely with ssh)
* https://devhints.io/bash (Cheatsheet) 



