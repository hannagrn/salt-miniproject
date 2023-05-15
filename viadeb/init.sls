/tmp/drawio:
  file.managed:
    - source: salt://salt-miniproject/viadeb/drawio-amd64-21.2.8.deb
      - mode: '755'

drawio:
  cmd.run:
    - names:
      - 'sudo dpkg -i /tmp/drawio'
      - 'sudo apt -y -f install'
