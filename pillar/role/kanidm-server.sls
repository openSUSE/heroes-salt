kanidm:
  config:
    # Each kanidmd instances points at itself to avoid load balancer outages giving
    # us a DR path where we can still login to the servers.
    uri: https://{{ grains['id'] }}

# This system has high security impact, and should only be accessible
# to accounts responsible for the system.
high-value-system: True
