file_names=""

function run_with_lines() {
    while read -r line; do
      $2 "$line"
    done <<< $(echo -e "$1" | tr ';' '\n')
}

function get_file_url() {
    arr=($1 )
    echo "${arr[0]}"
}

function get_file_name() {
    arr=($1 )
    if [ "${arr[1]}" = "" ]; then
      filename=`basename $(echo "${arr[0]}" | cut -d'?' -f1)`
      echo "$filename"
    else
      echo "${arr[1]}"
    fi
}

function append() {
    echo $1 >> Dockerfile
}

function add() {
    url=$(get_file_url "$1")
    name=$(get_file_name "$1")
    # collect all file names
    if [ "$file_names" = "" ]; then
      file_names="$name"
    else
      file_names="$file_names;$name"
    fi
    append "ADD $url $name"
}

function make_dockerfile() {
    append "FROM scratch"
    run_with_lines "$1" add
    # set file list label 
    append "LABEL files=\"$file_names\""
    # nessary to create container
    append "CMD [ "/" ]"
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
    docker build -t "$REGISTRY/$REPO" .
    login $REGISTRY $CREDENTIAL
    docker push "$REGISTRY/$REPO"
}

echo "" > Dockerfile

make_dockerfile "$FILE_LIST"

echo "build content:"

cat Dockerfile

build