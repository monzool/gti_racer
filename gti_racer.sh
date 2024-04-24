#!/bin/bash

usage() {
cat << EOF
Usage: $0 [options]

    -v, --vehicle <character>   Character to use as vehicle. Default: 🚗
    -d, --distance <number>     Length of race track. Default: 25
    -m, --message <text>        Message to print at goal line: Defaukt: 🤦‍♂️

EOF
}


readonly race_delay=0.06
readonly explosion="💥"
readonly explosion_index=6
readonly explosion_delay=0.09
readonly fire="🔥"
readonly fire_index=4
readonly fire_delay=0.1
readonly flag="🏁"
readonly flag_index=1
readonly flag_delay=0.2



option_vehicle="🚗"
option_distance=25
option_message="🤦‍♂️"
option_debug=
parse_arguments() {
    get_option_value() {
        if [[ -n "$2" && ${2:0:1} != "-" ]]; then
            printf "${2}"
        else
            printf "Error: missing argument for ${1}\n" >&2
            exit 1
        fi
    }

    local params=
    while (( "$#" )); do
        case "${1}" in
            -v|--vehicle)
                option_vehicle=$(get_option_value ${@})
                shift 2
                ;;

            -d|--distance)
                option_distance=$(get_option_value ${@})
                if (( option_distance < 10 )); then
                    printf "Minimum distance: 10\n"
                    exit 1
                elif [[ "$option_width" == "full" ]]; then
                    option_distance=$(tput cols)
                fi
                shift 2
                ;;

            -m|--message)
                option_message=$(get_option_value ${@})
                shift 2
                ;;

            -h|--help)
                usage
                exit 0
                ;;

            -🐛)
                option_debug=true
                shift
                ;;

            -*|--*=)
                printf "Error: Unsupported flag ${1}\n" >&2
                exit 1
                ;;

            *)
                params="${params} ${1}"
                shift
                ;;
        esac
    done
    eval set -- "${params}"
}


race() {
    local vehicle="${1}"
    local distance=${2}
    local message="${3}"

    local pos=${distance}
    sleep_time=${race_delay}
    while true; do
        printf "\r"

        line=""
        for ((i = 1; i <= ${distance}; i++)); do
            if (( $i == ${pos} )); then
                if (( ${pos} <= ${flag_index} )); then
                    sleep_time=${flag_delay}
                    line="${line}${flag}"
                elif (( ${pos} <= ${fire_index} )); then
                    sleep_time=${fire_delay}
                    line="${line}${fire}"
                elif (( ${pos} <= ${explosion_index} )); then
                    sleep_time=${explosion_delay}
                    line="${line}${explosion}"
                else
                    line="${line}${vehicle}"
                fi
            else
                line="${line} "
            fi
        done
        printf "%s" "${line}"

        if [[ -n "${option_debug}" ]]; then
            printf "\n"
        fi

        ((pos--))
        if (( ${pos} <= 0 )); then
            printf "\r${message}\n"
            break
        fi

        sleep ${sleep_time}
    done
}

parse_arguments ${@}
race "${option_vehicle}" ${option_distance} "${option_message}"
