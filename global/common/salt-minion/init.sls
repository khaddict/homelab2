include:
  - base.saltstack

install_salt_minion:
  pkg.installed:
    - name: salt-minion

minion_config:
  file.managed:
    - name: /etc/salt/minion
    - source: salt://global/common/salt-minion/files/minion
    - mode: 644
    - user: root
    - group: root

service_salt_minion:
  service.running:
    - name: salt-minion
    - enable: True

install_vault_extension:
  cmd.run:
    - name: "salt-pip install saltext-vault"
    - unless: "salt-pip show saltext-vault"
    - require:
      - service: service_salt_minion
