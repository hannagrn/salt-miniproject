# salt-miniproject

Hanna Gröndahl 2023

## Aluksi

This repository is for storing my final project for Configuration management course in Haaga Helia UAS. Rest of the documentation is in Finnish.

## Projektin tarkoitus

Tämän miniprojektin tarkoituksena on tehdä Vagrantilla ja Saltilla herra-orja-arkkitehtuurin työympäristö. Herran on tarkoitus määritellä työasemilla käytössä olevia ohjelmia sekä muita määrityksiä. Projektin on tavoitteena on jäljitellä tilannetta, jossa yritys tarjoaa esiasennetun työaseman työntekijän käyttöön. Työntekijä tarvitsee ainakin toimisto-ohjelmistoja sekä piirto-ohjelmia tekniseempäänkin piirtämiseen. Työasema on varustettu tarvittavilla ohjelmilla sekä yrityksen ilmeen mukaisen käyttöliittymän kustomoinnilla. Tarkoituksena on tehdä ainakin Debian 11 -työasemia, mutta mahdollisesti myös Windows-työasemia. 

### Selvitettävä

- Työpöytäympäristön asennus
- Ohjelmistot määrittelyineen
  - Aika moni Linux-jakelu sisältää valmiiksi hyviä ohjelmia, täytyy selvittää mitä muuta tarvitaan
  - Windowsiin samat ohjelmat: LibreOffice, Inkscape, binääristä Micro ja Draw.io
- Oikeiden määrittelytiedostojen selvittäminen: esim. mistä tiedostosta määritetään taustakuva

## Vaihe 1 - Vagrant up

Kuten aina, ensin päivitetään pakettiluettelo `sudo apt update` ja tarvittaessa päivitetään paketit `sudo apt upgrade`. Loin projektihakemistoon Vagrantfilen, joka määrittelee Vagrantilla luotavan verkon ja koneet. Käytin Vagrantfilen pohjana [Tero Karvisen luomaa määrittelyä kolmen koneen verkolle](https://terokarvinen.com/2023/salt-vagrant/) sekä [Stackoverflow'sta ohjetta Xfce-työpöytäympäristön määrittelyyn](https://stackoverflow.com/questions/18878117/using-vagrant-to-run-virtual-machines-with-desktop-environment). Valitsin Xfce:n, sillä kaikessa yksinkertaisuudessaan se on oma suosikkini Linuxin työpöytäympäristöistä. Vagrantfile sisältää määrittelyt kahdelle orjalle ja yhdelle masterille. Kaikki käyttävät Debian 11 -käyttöjärjestelmää. 

    # -*- mode: ruby -*-
    # vi: set ft=ruby :

    $minion = <<MINION
    sudo apt-get update
    sudo apt-get -qy install salt-minion
    echo "master: 192.168.56.3">/etc/salt/minion
    sudo service salt-minion restart
    MINION

    $master = <<MASTER
    sudo apt-get update
    sudo apt-get -qy install salt-master
    MASTER

    Vagrant.configure("2") do |config|
      config.vm.box = "debian/bullseye64"

     # Install xfce and virtualbox additions
      config.vm.provision "shell", inline: "sudo apt-get update"
      config.vm.provision "shell", inline: "sudo apt-get install -y xfce4"
    # Permit anyone to start the GUI
      config.vm.provision "shell", inline: "sudo sed -i 's/allowed_users=.*$/allowed_users=anybody/' /etc/X11/Xwrapper.config"

      config.vm.provider "virtualbox" do |vb|
        # Display the VirtualBox GUI when booting the machine
          vb.gui = true

      end

      config.vm.define "deb001" do |deb001|
        deb001.vm.provision :shell, inline: $minion
        deb001.vm.network "private_network", ip: "192.168.56.10"
        deb001.vm.hostname = "deb001"
        deb001.vm.disk :disk, size: "100GB", primary: true

      end

      config.vm.define "deb002" do |deb002|
        deb002.vm.provision :shell, inline: $minion
        deb002.vm.network "private_network", ip: "192.168.56.11"
        deb002.vm.hostname = "deb002"
        deb002.vm.disk :disk, size: "100GB", primary: true

      end

      config.vm.define "master", primary: true do |master|
        master.vm.provision :shell, inline: $master
        master.vm.network "private_network", ip: "192.168.56.3"
        master.vm.hostname = "master"
      end
    end


Pystytin verkon ja käynnistin koneet `vagrant up`. Virtuaalikoneiden käynnistyminen vei 20 minuuttia. Työpöytäympäristön asentaminen kasvatti asennusaikaa huomattavasti. Jos taidot olisivat riittäneet, olisin asentanut Xfce:n vain orjille. Olisikohan se mahdollisesti onnistunut pkg-tilan avulla?

## Vaihe 2 - Avaimet & määrittely

Siirryin master-koneelle vagrant ssh. Saadakseni yhteyden Saltilla orjiin pyysin orjien avaimet `sudo salt-key -A`. Molemmat orjat ilmoittautuivat ja hyväksyin ne.

Määrittelin lyhyesti, mitä ohjelmistoja tarkalleen haluan. Tarkoituksena on siis luoda työympäristö, jossa on toimistotyöhön tarvittavat työkalut pienellä lisämausteella:
- Libreoffice (apt)
- Inkscape (apt)
- Draw.io (binääri)
- Micro (binääri)

Lisäksi haluan, että orjat käyttävät masterin määrittelemää taustakuvaa. Lopuksi, jotta työympäristöä pystyy ylipäänsä käyttämään, luon käyttäjän, jolle kirjautua.

## Vaihe 3 - LibreOffice & Inkscape

Tein ensin tilan LibreOfficen ja Inkscapen asentamiseksi. Tein niille yhteisen tilan, sillä ne molemmat asennetaan aptista pkg.installed-tilan avulla. Ajoin tilan `sudo salt '*' state.apply salt-miniproject/viaapt`. Tilan ajamisessa keksi huomattavan kauan, kuten huomataan deb002-koneen salt-raportista:

![image](https://github.com/hannagrn/salt-miniproject/assets/122886984/2cb3bb75-1a40-4dd5-be46-45c0d914d885)

Asentamisessa meni siis reilu kuusi minuuttia. Kysyin vielä LibreOfficelta, mihin se asensi Libreofficen varmistuakseni asennuksesta `sudo salt 'deb002' cmd.run 'which libreoffice'`:

    deb002:
        /usr/bin/libreoffice
        
Kokeilin vielä idempotenssia ajamalla asennuskomennon uudestaan. 

![image](https://github.com/hannagrn/salt-miniproject/assets/122886984/eae9c362-2941-4a07-9df5-4204774821e2)

Kahden tilan ajo onnistui, mutta mikään ei muuttunut, joten tila on idempotentti.

## Vaihe 4 - Draw.io ja Micro

Draw.io on näppärä työkalu prosessikaavioiden piirtämiseen. Käytän sitä töissä jonkin verran, koska se on kevyt ja helppokäyttöinen nopeaan prosessin luonnehdintaan. Lähtökohtaisesti sitä käytetään selainpohjaisesti, mutta siitä löytyy myös tiedostot paikalliseen asennukseen, jolloin sitä voi käyttää ilman verkkoyhteyttä. Tämän vuoksi halusin sisällyttää sen työasemaprojektiini.

Micro taas on tekstieditori komentorivityöskentelyyn. Se on mielestäni paras työkalu tekstin käsittelyyn Linuxin komentorivillä, ja koska teen Debian-työasemia, on tärkeää, että komentorivityöskentely sujuu tarvittaessa.

Hain ensin [Draw.ion asennustiedoston GitHubista](https://github.com/jgraph/drawio-desktop/releases). Valitsin zipatun x64-tiedoston, sillä sen pitäisi olla yhteensopiva Debianin kanssa. Latasin tiedoston `wget https://github.com/jgraph/drawio-desktop/releases/download/v21.2.8/draw.io-x64-21.2.8.zip`. 

[Micron asennustiedoston](https://github.com/zyedidia/micro/releases) hain myös GitHubista. Valitsin Linuxin 64-bittiselle arkkitehtuurille sopivan julkaisun. Latasin tiedoston `wget https://github.com/zyedidia/micro/releases/download/v2.0.11/micro-2.0.11-linux64-static.tar.gz`.

## Vaihe 5 - Taustakuva keskitetysti
