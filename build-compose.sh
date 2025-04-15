#!/bin/bash

START_PORT=5000

TEACHERS=(
  ahaskell
  acraig
)

STUDENTS=(
  bsmith
  jdaily
)

echo "Checking for docker access"
docker system info > /dev/null 2>&1
dockerStatusExitCode=$?
if [[ $dockerStatusExitCode -ne 0 ]]; then
  echo "You do not have permission to access Docker, or Docker is not running!";
  exit 1;
fi
echo ""

echo "Bringing down previous compose project if it is running"
docker compose -f compose.yml down
echo ""

echo "Generating template"
echo ""

compose="services:"$'\n'

# Calculate longest username
longestuser=8;
for user in "${!TEACHERS[@]}"; do
  if [[ ${#user} -gt $longestuser ]]; then
    longestuser=${#user}
  fi
done

for user in "${!STUDENTS[@]}"; do
  if [[ ${#user} -gt $longestuser ]]; then
    longestuser=${#user}
  fi
done
longestuser=$(($longestuser + 1))

port=$START_PORT

printf "\e[4m\e[1m|%-8s|%-${longestuser}s|%9s|%5s|\e[0m\n" "Access" "Username" "Password" "Port"
for user in "${TEACHERS[@]}"; do
  pass="$(shuf -i 10000000-99999999 -n 1)"

  template=$(
  cat <<END_HEREDOC
  ${user}:
    build: .
    volumes:
      - ./config/${user}:/config
      - ./projects/${user}:/projects
      - ./projects:/projects-all
    ports:
      - ${port}:8080
    environment:
      - USERNAME=${user}
      - PASSWORD=${pass}
END_HEREDOC
  )

  compose+="${template}"$'\n'

  printf "|%-8s|%-${longestuser}s|%9s|%5s|\n" "Teacher" "${user}" "${pass}" "${port}"
  port=$(($port + 1))
done

echo ""
printf "\e[4m\e[1m|%-8s|%-${longestuser}s|%9s|%5s|\e[0m\n" "Access" "Username" "Password" "Port"
for user in "${STUDENTS[@]}"; do
  pass="$(shuf -i 10000000-99999999 -n 1)"

  template=$(
  cat <<END_HEREDOC
  ${user}:
    build: .
    volumes:
      - ./config/${user}:/config
      - ./projects/${user}:/projects
    ports:
      - ${port}:8080
    environment:
      - USERNAME=${user}
      - PASSWORD=${pass}
END_HEREDOC
  )

  compose+="${template}"$'\n'

  printf "|%-8s|%-${longestuser}s|%9s|%5s|\n" "Student" "${user}" "${pass}" "${port}"
  port=$(($port + 1))
done

echo "${compose}" > compose.yml
echo ""
echo "Template Saved in 'compose.yml'"