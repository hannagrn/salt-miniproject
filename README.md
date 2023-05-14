# salt-miniproject

Hanna Gröndahl 2023

## Aluksi

This repository is for storing my final project for Configuration management course in Haaga Helia UAS. Rest of the documentation is in Finnish.

## Projektin tarkoitus

Tämän miniprojektin tarkoituksena on tehdä Vagrantilla ja Saltilla herra-orja-arkkitehtuurin työympäristö. Herran on tarkoitus määritellä työasemilla käytössä olevia ohjelmia sekä muita määrityksiä. Projektin on tavoitteena on jäljitellä tilannetta, jossa yritys tarjoaa esiasennetun työaseman työntekijän käyttöön. Työntekijä tarvitsee ainakin toimisto-ohjelmistoja sekä piirto-ohjelmia tekniseempäänkin piirtämiseen. Työasema on varustettu tarvittavilla ohjelmilla sekä yrityksen ilmeen mukaisen käyttöliittymän kustomoinnilla. Tarkoituksena on tehdä ainakin Debian 11 -työasemia, mutta mahdollisesti myös Windows-työasemia. 

### Selvitettävä

- Ohjelmistot määrittelyineen
  - Aika moni Linux-jakelu sisältää valmiiksi hyviä ohjelmia, täytyy selvittää mitä muuta tarvitaan
  - Windowsiin samat ohjelmat: LibreOffice, Inkscape, binääristä Micro ja Draw.io
- Oikeiden määrittelytiedostojen selvittäminen: esim. mistä tiedostosta määritetään taustakuva

## Vaihe 1 - Projektin perustaminen & Vagrant

Kuten aina, ensin päivitetään pakettiluettelo `sudo apt update` ja tarvittaessa päivitetään paketit `sudo apt upgrade`. Aloitin kloonamalla tämän varaston kotihakemistooni `git clone git@github.com:hannagrn/salt-miniproject.git`. Vagrantin käyttö edellyttää VirtualBoxin ja Vagrantin asentamista host-koneelle. Loin projektihakemistoon Vagrantfilen, joka määrittelee Vagrantilla luotavan verkon ja koneet. Käytin Vagrantfilen pohjana [Tero Karvisen luomaa määrittelyä kolmen koneen verkolle](https://terokarvinen.com/2023/salt-vagrant/). Vagrantfile sisältää määrittelyt kahdelle orjalle ja yhdelle masterille. Kaikki käyttävät Debian 11 -käyttöjärjestelmää. Pystytin verkon ja käynnistin koneet `vagrant up`. Virtuaalikoneiden käynnistyminen vei noin 3 minuuttia.

