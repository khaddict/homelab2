{% set admin_api_key = salt['vault'].read_secret('kv/powerdns').admin_api_key %}
{% set login_webhook_url = salt['vault'].read_secret('kv/main').login_webhook_url %}
{% set pull_webhook_url = salt['vault'].read_secret('kv/main').pull_webhook_url %}
{% set github_commits_khaddict_webhook_url = salt['vault'].read_secret('kv/main').github_commits_khaddict_webhook_url %}
{% set github_pull_token = salt['vault'].read_secret('kv/main').github_pull_token %}

vars_bashrc:
  file.managed:
    - name: /root/.bashrc.d/vars.bashrc
    - source: salt://role/main/files/vars.bashrc
    - mode: 700
    - user: root
    - group: root
    - template: jinja
    - context:
        admin_api_key: {{ admin_api_key }}

login_script:
  file.managed:
    - name: /root/login/login.sh
    - source: salt://role/main/files/login.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - context:
        login_webhook_url: {{ login_webhook_url }}

login_service:
  file.managed:
    - name: /etc/systemd/system/login.service
    - source: salt://role/main/files/login.service
    - mode: 644
    - user: root
    - group: root

start_enable_login_service:
  service.running:
    - name: login
    - enable: True
    - watch:
      - file: login_service

github_commits_script:
  file.managed:
    - name: /root/github_commits/github_commits.sh
    - source: salt://role/main/files/github_commits.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - context:
        github_commits_khaddict_webhook_url: {{ github_commits_khaddict_webhook_url }}

github_commits_service:
  file.managed:
    - name: /etc/systemd/system/github_commits.service
    - source: salt://role/main/files/github_commits.service
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: github_commits_script
    - watch:
      - file: github_commits_script

github_commits_timer:
  file.managed:
    - name: /etc/systemd/system/github_commits.timer
    - source: salt://role/main/files/github_commits.timer
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: github_commits_script
    - watch:
      - file: github_commits_script

github_pull_script:
  file.managed:
    - name: /root/github_pull/github_pull.sh
    - source: salt://role/main/files/github_pull.sh
    - mode: 755
    - user: root
    - group: root
    - template: jinja
    - context:
        github_pull_token: {{ github_pull_token }}
        pull_webhook_url: {{ pull_webhook_url }}

github_pull_service:
  file.managed:
    - name: /etc/systemd/system/github_pull.service
    - source: salt://role/main/files/github_pull.service
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: github_pull_script
    - watch:
      - file: github_pull_script

github_pull_timer:
  file.managed:
    - name: /etc/systemd/system/github_pull.timer
    - source: salt://role/main/files/github_pull.timer
    - mode: 644
    - user: root
    - group: root
    - require:
      - file: github_pull_script
    - watch:
      - file: github_pull_script
