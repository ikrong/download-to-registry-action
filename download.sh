function run_with_lines() {
    echo -e "$1" | tr ';' '\n' | while read -r line; do
      $2 "$line"
    done
}

function get_file_name() {
    arr=($1 )
    if [ "${arr[1]}" = "" ]; then
      filename=`basename $(echo "${arr[0]}" | cut -d'?' -f1)`
      echo "${arr[0]} $filename"
    else
      echo $1
    fi
}

function append() {
    echo $1 >> Dockerfile
}

function add() {
    cmd=`get_file_name "$1"`
    append "ADD $cmd"
}

function make_dockerfile() {
    append "FROM scratch"
    run_with_lines "$1" add
}

function login() {
    echo "Login to $1"
    u=$(echo $2 | cut -d':' -f1)
    p=$(echo $2 | cut -d':' -f2-)
    if [ "$u" = "" ]; then
        return
    fi
    if [ "$p" = "" ]; then
        return
    fi
    echo $p | docker login --password-stdin -u $u $1
}

function build() {
    docker build -t "$REGISTRY$REPO" .
    login $REGISTRY $CREDENTIAL
    docker push "$REGISTRY$REPO"
}

echo "" > Dockerfile

make_dockerfile $FILE_LIST