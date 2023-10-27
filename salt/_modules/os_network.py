import ipaddress

def gw_with_cidr(gw, net):
    network, slash, cidr = net.partition('/')
    return f'{gw}{slash}{cidr}'


def strip_cidr(address):
    return address.split('/')[0]


def convert_4to6(v4address, v6prefix):
    """
    Example arguments:
    v6prefix = 2a07:de40:b27e:64:: or 2a07:de40:b27e:64::/96
    v4address = 192.168.47.37
    Example return string:
    2a07:de40:b27e:0064:0000:0000:c0a8:2f25
    """

    ip4address = ipaddress.IPv4Address(v4address)
    ip6prefix = ipaddress.IPv6Address(v6prefix.split('/')[0])

    return str(ipaddress.ip_address(int(ip4address) + int(ip6prefix)))
