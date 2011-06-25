#!/usr/bin/python
import sys
import os
import fcntl
import crypt
import re

map = None

def do_pwis(k,g = 3):
	if g == 3:
		def readseed_g3():
			global map

			if map != None:
				if len(map):
					return(0)
			if os.environ.has_key("SEED"):
				if len(os.getenv("SEED")):
					map = os.getenv("SEED")
					return(0)

			file = "/".join((os.getenv("HOME"),".pwis.bin"))
			fh = open(file)
			if fh == None:
				return(1)
			elif fcntl.flock(fh.fileno(),fcntl.LOCK_SH|fcntl.LOCK_NB):
				fh.close()
				return(1)
			map = fh.read(1024 * 4)
			if len(map) == 0:
				fh.close()
				return(1)
			else:
				fh.close()
				return(0)
		if readseed_g3() == 0:
			k_ = []

			k = k.ljust(10," ")
			j = 10.0 / len(k)
			for i in range(len(k)):
				if len(k_) < int(j * (i + 1)):
					k_.append(k[i])

			k = "".join(k_)
			l = 0
			while l < 3 or re.search('[^0-9A-Za-z]',k):
				for i in range(len(k)):
					c = ord(k[i]) & 0x7F
					p = int(float(len(map)) / 128 * (c % 128)) + i
					for n in range(8):
						c ^= ord(map[p % len(map)]) & 0x7F
						if c == 0:
							c = ord(map[p % len(map)]) & 0x7F
						p += c % 32
					k = k[:-len(k) + i] + chr(c) + k[i + 1:len(k)] # purintai de-su ie-i ^o^
				k = crypt.crypt(k[2:10],"./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"[ord(k[0]) % 64] + "./0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"[ord(k[1]) % 64])[2:12]

				l += 1
	elif g == 2:
		pass
	elif g == 1:
		pass
	else:
		pass
	return(k)

if len(sys.argv) > 1:
	for k in sys.argv[1:]:
		print do_pwis(k)
else:
	while 1:
		print do_pwis(raw_input())
