configure

edit firewall

set group address-group Threats-ban description "IPs and ranges to be banned in all connections; by ipset-threats"
set group address-group Threats-drop description "IPs and ranges to be dropped from incoming connections; by ipset-threats"
set group address-group Threats-prep description "Temporary space for loading lists before swapping into Threats-*; by ipset-threats"

for f in VPN_local WAN_in WAN_local WAN_out; do

    if [[ $f != *_out ]]; then
        set name $f rule 1 action drop
        set name $f rule 1 description "Drop all incoming traffic from banned IPs (threats.sh)"
        set name $f rule 1 log disable
        set name $f rule 1 protocol all
        set name $f rule 1 source group address-group Threats-ban

        set name $f rule 3 action drop
        set name $f rule 3 description "Drop incoming threat IPs (threats.sh)"
        set name $f rule 3 log disable
        set name $f rule 3 protocol all
        set name $f rule 3 source group address-group Threats-drop
        set name $f rule 3 state established disable
        set name $f rule 3 state new enable
        set name $f rule 3 state related enable
        set name $f rule 3 state invalid enable
    fi

    if [[ $f != *_in ]]; then
        set name $f rule 2 action drop
        set name $f rule 2 description "Drop all outgoing traffic to banned IPs (threats.sh)"
        set name $f rule 2 log disable
        set name $f rule 2 protocol all
        set name $f rule 2 destination group address-group Threats-ban
    fi

done

exit

commit
save
