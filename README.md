# Laboratorio OSPF Multiárea en MikroTik (RouterOS v7)

Laboratorio de OSPFv2 con 4 routers MikroTik CHR, dos ABR, tres áreas (0, 10 y 20) y redistribución de una ruta externa desde un ASBR.

## Objetivos

- Configurar OSPF multiárea con un backbone (área 0) y dos áreas no backbone.
- Entender el rol de ABR, ASBR y routers internos.
- Verificar rutas intra-área (O), inter-área (IA) y externas (E2).
- Probar la convergencia ante la caída de un enlace.

## Herramientas

- GNS3 o EVE-NG
- MikroTik CHR (RouterOS v7)

## Topología

```
   ÁREA 10              ÁREA 0               ÁREA 20
 192.168.10.0/24                          192.168.20.0/24
       |                                         |
      [R1]-------10.0.12.0/30------[R2]=====[R3]-------10.0.34.0/30------[R4]
    (ASBR)   e1               e1  (ABR) e2 e1 (ABR)  e2             e1  (interno)
                                    10.0.23.0/30
```

| Router | Rol | Router-ID | Áreas |
|--------|-----|-----------|-------|
| R1 | Interno + ASBR | 1.1.1.1 | 10 |
| R2 | ABR | 2.2.2.2 | 10 y 0 |
| R3 | ABR | 3.3.3.3 | 0 y 20 |
| R4 | Interno | 4.4.4.4 | 20 |

## Plan de direccionamiento

| Enlace / red | Red | Extremos |
|--------------|-----|----------|
| R1 - R2 (área 10) | 10.0.12.0/30 | R1 .1 / R2 .2 |
| R2 - R3 (área 0) | 10.0.23.0/30 | R2 .1 / R3 .2 |
| R3 - R4 (área 20) | 10.0.34.0/30 | R3 .1 / R4 .2 |
| LAN R1 | 192.168.10.0/24 | R1 .1 (ether3) |
| LAN R4 | 192.168.20.0/24 | R4 .1 (ether3) |
| Loopbacks | 1.1.1.1 a 4.4.4.4 /32 | uno por router |
| Red externa simulada | 172.16.99.0/24 | blackhole en R1 |

## Configuración

Las interfaces de loopback se crean con un bridge vacío llamado `lo`.

### R1

```
/system identity set name=R1
/interface bridge add name=lo
/ip address
add address=1.1.1.1/32 interface=lo
add address=10.0.12.1/30 interface=ether1
add address=192.168.10.1/24 interface=ether3
/ip route add dst-address=172.16.99.0/24 blackhole

/routing ospf instance add name=ospf1 version=2 router-id=1.1.1.1 redistribute=static
/routing ospf area add name=area10 area-id=0.0.0.10 instance=ospf1
/routing ospf interface-template
add area=area10 interfaces=ether1 networks=10.0.12.0/30 type=ptp
add area=area10 networks=192.168.10.0/24 passive
add area=area10 networks=1.1.1.1/32 passive
```

### R2 (ABR área 10 / área 0)

```
/system identity set name=R2
/interface bridge add name=lo
/ip address
add address=2.2.2.2/32 interface=lo
add address=10.0.12.2/30 interface=ether1
add address=10.0.23.1/30 interface=ether2

/routing ospf instance add name=ospf1 version=2 router-id=2.2.2.2
/routing ospf area
add name=backbone area-id=0.0.0.0 instance=ospf1
add name=area10 area-id=0.0.0.10 instance=ospf1
/routing ospf interface-template
add area=area10 interfaces=ether1 networks=10.0.12.0/30 type=ptp
add area=backbone interfaces=ether2 networks=10.0.23.0/30 type=ptp
add area=backbone networks=2.2.2.2/32 passive
```

### R3 (ABR área 0 / área 20)

```
/system identity set name=R3
/interface bridge add name=lo
/ip address
add address=3.3.3.3/32 interface=lo
add address=10.0.23.2/30 interface=ether1
add address=10.0.34.1/30 interface=ether2

/routing ospf instance add name=ospf1 version=2 router-id=3.3.3.3
/routing ospf area
add name=backbone area-id=0.0.0.0 instance=ospf1
add name=area20 area-id=0.0.0.20 instance=ospf1
/routing ospf interface-template
add area=backbone interfaces=ether1 networks=10.0.23.0/30 type=ptp
add area=area20 interfaces=ether2 networks=10.0.34.0/30 type=ptp
add area=backbone networks=3.3.3.3/32 passive
```

### R4

```
/system identity set name=R4
/interface bridge add name=lo
/ip address
add address=4.4.4.4/32 interface=lo
add address=10.0.34.2/30 interface=ether1
add address=192.168.20.1/24 interface=ether3

/routing ospf instance add name=ospf1 version=2 router-id=4.4.4.4
/routing ospf area add name=area20 area-id=0.0.0.20 instance=ospf1
/routing ospf interface-template
add area=area20 interfaces=ether1 networks=10.0.34.0/30 type=ptp
add area=area20 networks=192.168.20.0/24 passive
add area=area20 networks=4.4.4.4/32 passive
```

## Verificación

Ejecutar en cada router y guardar capturas para el portfolio.

```
/routing ospf neighbor print
/routing ospf area print
/routing ospf lsa print
/ip route print where ospf
```

Resultados esperados:

1. R2 y R3 tienen vecinos en estado **Full** (R2 con R1 y R3; R3 con R2 y R4).
2. En R1 aparecen como **inter-área** las redes de las áreas 0 y 20 (por ejemplo 192.168.20.0/24).
3. En R4 aparece la red 172.16.99.0/24 como ruta **externa (E2)**, proveniente del ASBR R1.
4. En R2 y R3 aparecen LSA tipo 3 (resumen) y tipo 5 (externas).

Prueba de conectividad extremo a extremo, desde R1:

```
/ping 192.168.20.1 src-address=192.168.10.1
/tool traceroute 192.168.20.1 src-address=192.168.10.1
```

El traceroute debe pasar por 10.0.12.2, 10.0.23.2 y 10.0.34.2.

## Pruebas adicionales

- **Caída de enlace:** deshabilitar `ether2` en R2 y observar en R1 cómo desaparecen las rutas de las otras áreas y cuánto tarda en reconverger.
- **Autenticación:** agregar `auth=md5 auth-id=1 auth-key=<clave>` en los `interface-template` de un enlace y comprobar que la adyacencia solo se forma con la clave correcta.
- **Costos:** cambiar `cost=` en un `interface-template` y ver cómo cambia la métrica de las rutas.

## Extensiones sugeridas

- Convertir el área 20 en **stub** o **totally stubby** y comparar las rutas que recibe R4.
- Agregar un enlace redundante entre R1 y R3 y analizar la elección de camino.
- **Sumarizar rutas** en los ABR (area range) y verificar el efecto en las tablas.
- Pasar los routers de tipo ptp a broadcast con un switch y analizar la elección de DR/BDR.

## Archivos del repositorio sugeridos

```
ospf-multiarea-mikrotik/
├── README.md
├── topologia.png
├── configs/
│   ├── r1.rsc
│   ├── r2.rsc
│   ├── r3.rsc
│   └── r4.rsc
└── capturas/
```

Los `.rsc` se generan en cada router con `/export file=r1` (cambiando el nombre según el router).
