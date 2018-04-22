Sobre PF: http://www.dicas-l.com.br/arquivo/firewall_pf_package_filter.php#.WgC64mhSyUk

Carp & PFSync: http://artemisa.unicauca.edu.co/~mtrujillo/OpenBSD/pf/pt/carp.html#RulesetTips

Criando PF: https://openbsdpe.wordpress.com/2007/06/27/criando-um-firewall-openbsd-utilizando-pf/

Sobre NAT: https://www.openbsd.org/faq/pf/nat.html

No meu cenário é disponibilizado duas maquinas virtuais utilizando o sistema operaciona OPENBSD, os detalhes da instalação serão omitidos uma vez que não tem relevância ao que será demonstrado.

Temos então a primeira maquina virtual que utiliza o OPENBSD:

## Interfaces de rede OpenBSD Master:

"em0" responsável por comunicar com a Rede Local: 	192.168.100.1

"em1" responsável por pfsync:			  	10.10.10.1

"em2" responsável por se comunicar com a WAN/INTERNET:  192.168.10.201

## Interfaces de rede OpenBSD Slave 1:

"em0" responsável por comunicar com a Rede Local: 	192.168.100.2

"em1" responsável por pfsync:			  	10.10.10.2

"em2" responsável por se comunicar com a WAN/INTERNET:  192.168.10.202


Estes firewalls compartilharam o endereço 192.168.100.100 na rede local, para fazer o failover atraves do protocolo CARP, portanto este será o endereço que a rede local enchergará como gateway padrão.

Já do lado da WAN/Internet será compartilhado o endereço 192.168.10.250;

Tambem foi inserido um WebServer que responde pelo IP 192.168.100.110 o qual fica dentro da rede.

Regras de firewall:

Arquivo: /etc/pf.conf
```
pass out on em0 proto carp keep state
pass out on em2 proto carp keep state
pass on em1 proto pfsync
```
## NAT CONFIG
```
pass out on em2 inet from em0:network to any nat-to (em2)
```

## Port Forwading
```
pass in on egress proto tcp from any to any port 80 rdr-to 192.168.100.110
```


## Dificuldades:

Descobrir que o preempt nao estava sendo habilitado durante o boot, o que não fazia o computador master reassumir.

Para facilitar e ilustrar melhor, foi criado um script que realiza as configurações conforme as especificações acima:

Para a transferencia do Script foi utilizado os seguintes comandos
```
export PKG_PATH=”http://ftp.openbsd.org/pub/OpenBSD/$(uname -r)/packages/$(arch -s)/”
pkg_add wget
```
Feito isso temos a ferramenta wget disponivel para uso, portanto
```
wget http://webserver/scriptMaster.txt
```
