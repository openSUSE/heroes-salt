def gw_with_cidr(gw, net):
    network, slash, cidr = net.partition('/')
    return f'{gw}{slash}{cidr}'
