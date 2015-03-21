# UnOnline

### NOTICE: UnOnline depends on curl.
### Usage: `unonline [option] arg(s)`

### Options:
    	-h/--help                             display this help
    	-r/--range <ip_addr_1> <ip_addr_2>    log off any user whoes ip address ranges from <ip_addr_1> to <ip_addr_2>
        	-x(when using option -r)          log off any user whoes ip address ranges from <ip_addr_1> to <ip_addr_2> except for the local user
    	-v/--version                          display the version of UnOnline

### Examples:
		unonline 192.168.1.64
		unonline 192.168.1.34 192.168.1.210 192.168.1.115
		unonline -r 192.168.1.14 192.168.1.231 -x
