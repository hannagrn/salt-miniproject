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
- Micro (apt)
- Draw.io (snap)

Lisäksi haluan, että orjat käyttävät masterin määrittelemää taustakuvaa. Lopuksi, jotta työympäristöä pystyy ylipäänsä käyttämään, luon käyttäjän, jolle kirjautua.

## Vaihe 3 - LibreOffice & Inkscape

Tein ensin tilan LibreOfficen ja Inkscapen asentamiseksi. Tein niille yhteisen viaapt-tilan, sillä ne molemmat asennetaan aptista pkg.installed-tilan avulla. Ajoin tilan `sudo salt '*' state.apply salt-miniproject/viaapt`. Tilan ajamisessa keksi huomattavan kauan, kuten huomataan deb002-koneen salt-raportista:

![image](https://github.com/hannagrn/salt-miniproject/assets/122886984/2cb3bb75-1a40-4dd5-be46-45c0d914d885)

Asentamisessa meni siis reilu kuusi minuuttia. Kysyin vielä LibreOfficelta, mihin se asensi Libreofficen varmistuakseni asennuksesta `sudo salt 'deb002' cmd.run 'which libreoffice'`:

    deb002:
        /usr/bin/libreoffice
        
Kokeilin vielä idempotenssia ajamalla asennuskomennon uudestaan. 

![image](https://github.com/hannagrn/salt-miniproject/assets/122886984/eae9c362-2941-4a07-9df5-4204774821e2)

Kahden tilan ajo onnistui, mutta mikään ei muuttunut, joten tila on idempotentti.

## Vaihe 4 - Draw.io _jollain_

Draw.io on näppärä työkalu prosessikaavioiden piirtämiseen. Käytän sitä töissä jonkin verran, koska se on kevyt ja helppokäyttöinen nopeaan prosessin luonnehdintaan. Lähtökohtaisesti sitä käytetään selainpohjaisesti, mutta siitä löytyy myös tiedostot paikalliseen asennukseen, jolloin sitä voi käyttää ilman verkkoyhteyttä. Tämän vuoksi halusin sisällyttää sen työasemaprojektiini.

Hain ensin [Draw.ion asennustiedoston GitHubista](https://github.com/jgraph/drawio-desktop/releases). Päädyin tekemään asennuksen deb-paketin kautta, koska se ylipäänsä onnistui. Myös snapilla (paketinhallintaohjelma) se periaattessa onnistuisi, mutta taidot eivät riittäneet. Latasin deb-paketin masterille `wget https://github.com/jgraph/drawio-desktop/releases/download/v21.2.8/drawio-amd64-21.2.8.deb` ja sitten jäin umpikujaan. Koitan saada selvitettyä esitykseen mennessä.

## Vaihe 5 - Micro, binääri vai apt?

Olin ensin ajatellut, että asennan micron binääristä _koska voin_. Pohdittuani vaihtoehtoja projektin kontekstissa, päädyin asentamaan sen aptin kautta. Tarkoitus on kuitenkin käyttää microa niin sanotussa peruskäytössä, ja siksi aptissa oleva versio riittää käyttäjälle. Sen avulla voi myös paremmin varmistua siitä, että paketti pysyy ajantasaisena. Päädyin lisäämään micron aiemmin tehtyyn viaapt-tilaan. Ajoin tilan orjille uudestaan `sudo salt --state-output=terse '*'  state.apply salt-miniproject/viaapt`. Alla deb001-koneen tulostus, jossa kaikki tilat onnistuvat, mutta vain yksi muutos tehdään, koska muut paketit ovat jo asennettuna. 

![image](https://github.com/hannagrn/salt-miniproject/assets/122886984/0e858ee6-823d-4a14-9378-219e220947ff)

## Vaihe 6 - Käyttäjän luonti & taustakuva keskitetysti

Tein newuser-tilan, jonka tarkoituksena on luoda käyttäjä, jolle orjalla voi kirjautua. Loin tilalle init.sls-tiedoston, ja ajoin sen orjilla `sudo salt '*' state.apply salt-miniproject/newuser`. Kirjautuminen ei kuitenkaan onnistunut, vaikka näin ssh:n yli, että käyttäjälle luotiin kotihakemisto. 

## Vaihe 7 - Kolmas kone ja huipputila
