#!/bin/bash

usage_printf()
{
	echo Usage: $0 174 low/high
}

set_gpio_out()
{
	echo $1 > /sys/class/gpio/export #导出gpio
	echo out > /sys/class/gpio/gpio$1/direction
	if [ $2 == "low" ]
	then
		echo gpio$1 low 
		echo 0 > /sys/class/gpio/gpio$1/value
	else
		echo gpio$1 high
		echo 1 > /sys/class/gpio/gpio$1/value
	fi
	read -p "please confirm and enter any key to exit: " in_value
	echo $1 > /sys/class/gpio/unexport #释放gpio
}

if [ $# -eq 2 ]
then
	if ! echo $1 | grep -q '[^0-9]'
	then
		if [ $2 == "low" ] || [ $2 == "high" ]
		then
			set_gpio_out $1 $2
		else
			usage_printf	
		fi
	else
		usage_printf
	fi
else
	usage_printf
fi
