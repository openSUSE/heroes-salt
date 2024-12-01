import ipaddress
from hashlib import sha256


def gw_with_cidr(gw, net):
    _, slash, cidr = net.partition('/')
    return f'{gw}{slash}{cidr}'


def strip_cidr(address):
    return address.split('/')[0]


def convert_4to6(v4address, v6prefix):
    """
    Example arguments:
    v6prefix = 2a07:de40:b27e:64:: or 2a07:de40:b27e:64::/96
    v4address = 192.168.67.37
    Example return string:
    2a07:de40:b27e:64::c0a8:4325
    """

    ip4address = ipaddress.IPv4Address(v4address)
    ip6prefix = ipaddress.IPv6Address(v6prefix.split('/')[0])

    return str(ipaddress.ip_address(int(ip4address) + int(ip6prefix)))


def reverse_pointer(v6network):
  """
  Returns the reverse pointer for a given IPv6 network"
  """

  # network_address.reverse_pointer would not return the correct value for a v6 network
  # https://github.com/python/cpython/issues/125641#issuecomment-2451653325
  n = ipaddress.IPv6Network(v6network)
  return '.'.join(n.network_address.exploded.replace(':','')[:n.prefixlen//4][::-1]) + '.ip6.arpa.'


def sixify(instring, prefix):
  """
  Encodes a string into an IPv6 adress.

  Example arguments:
  instring = firstyear
  prefix = 2a07:de40:b27e:5002::
  Example return string:
  2a07:de40:b27e:5002:2fbe:4b0f:46e4:4dc1
  """

  prefix = prefix.split('/')[0]
  if prefix.endswith('::'):
    prefix = prefix.replace('::', ':')

  sb = sha256(bytes(instring, 'utf-8'))
  h = sb.hexdigest()

  address = prefix + h[:4] + ':' + h[4:8] + ':' + h[8:12] + ':' + h[12:16]

  # pass through ipaddress module to ensure only valid IPv6 addresses are returned
  try:
    return str(ipaddress.IPv6Address(address))
  except ipaddress.AddressValueError as error:
    __salt__['log.error'](f'sixify: failed to convert {instring}: {error}')  # noqa F821
    return None
