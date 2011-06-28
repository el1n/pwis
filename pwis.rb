#!/usr/bin/ruby

def do_pwis(k,g = 3)
	if g == 3
		def readseed_g3()
			if defined?($map) && $map.length() != 0
				return(0)
			elsif ENV.has_key?("SEED") && ENV["SEED"].length() != 0
				return(0)
			end

			file = [ENV["HOME"],".pwis.bin"].join("/")
			if !fh = open(file)
				return(1)
			elsif !fh.flock(File::LOCK_SH|File::LOCK_NB)
				fh.close()
				return(1)
			elsif !$map = fh.read(1024 * 4)
				fh.close()
				return(1)
			else
				fh.close()
				return(0)
			end
		end

		if readseed_g3() == 0
			k_ = []

			k = k.ljust(10," ")
			j = 10.0 / k.length()
			for i in 0..k.length()
				if k_.size() < Integer(j * (i + 1))
					k_.push(k[i,1])
				end
			end

			k = k_.join()
			l = 0
			while (l += 1) < 4 || /[^0-9A-Za-z]/ =~ k || /^[A-Za-z]+$/ =~ k || /^[0-9]+$/ =~ k
				for i in 0..(k.length() - 1)
					c = k[i] & 0x7F
					p = Integer(Float($map.length()) / 128 * (c % 128)) + i
					for _ in 0..7
						if (c ^= $map[p % $map.length()] & 0x7F) == 0
							c = $map[p % $map.length()] & 0x7F
						end
						p += c % 32
					end
					k[i,1] = c.chr()
				end
				k = k[2,8].crypt([".","/",Array("0".."9"),Array("A".."Z"),Array("a".."z")].flatten()[k[0] % 64] << [".","/",Array("0".."9"),Array("A".."Z"),Array("a".."z")].flatten()[k[1] % 64])[2,10]
			end
		else
		end
	elsif g == 2
	elsif g == 1
	else
	end
	return(k)
end

if ARGV.size() != 0
	for k in ARGV
		puts do_pwis(k)
	end
else
	while k = STDIN.gets()
		k.chomp!()
		puts do_pwis(k)
	end
end
