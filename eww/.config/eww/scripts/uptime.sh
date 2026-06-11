#!/usr/bin/env bash
# uptime desde /proc (uptime binario no está en el PATH de eww)
awk '{s=int($1);d=int(s/86400);h=int((s%86400)/3600);m=int((s%3600)/60); if(d>0)printf "%dd %dh",d,h; else if(h>0)printf "%dh %dm",h,m; else printf "%dm",m}' /proc/uptime
