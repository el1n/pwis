#!/usr/bin/perl -l -s --

sub do_pwis()
{
	if($g == 3 || !defined($g)){
		if(
			&{sub(){
				if(length($map)){
					return(0);
				}elsif(defined($S)){
					$map = $S;
					return(0);
				}elsif(length($ENV{SEED})){
					$map = $ENV{SEED};
					return(0);
				}

				my $file = join("/",$ENV{HOME},".pwis.seed");
				if(defined($K)){
					$file = $K;
				}
				if(!open(FH,$file)){
					return(1);
				}elsif(!flock(FH,5)){
					close(FH);
					return(1);
				}elsif(!read(FH,$map,1024 * 4,0)){
					close(FH);
					return(1);
				}else{
					close(FH);
					return(0);
				}
			}} == 0
		){
			my @k;

			if(length($_) < 10){
				$_ = pack("A10",$_);
			}

			my $j = 10 / length($_);
			for(my $i = 0; $#k < 9; ++$i){
				if($#k + 1 < int($j * $i)){
					push(@k,substr($_,$i - 1,1));
				}
			}

			$_ = join(undef,@k);
			for(my $i = 0; $i < 3 || /[^0-9A-Za-z]/o || /^[A-Za-z]+$/o || /^[0-9]+$/o; ++$i){
				for my $i (0..(length($_) - 1)){
					my $c = vec($_,$i,8) & 0x7F;
					my $p = int(length($map) / 128 * ($c % 128)) + $i;
					for(0..7){
						if(($c ^= vec($map,$p % length($map),8) & 0x7F) == 0){
							$c = vec($map,$p % length($map),8) & 0x7F;
						}
						$p += $c % 32;
					}
					vec($_,$i,8) = $c;
				}
				$_ = substr(crypt(substr($_,2,10),join(undef,(qw(. /),0..9,A..Z,a..z)[vec($_,0,8) % 64,vec($_,1,8) % 64])),2,10);
			}
		}else{
		}
	}elsif($g == 2){
		my @k;
		my @s = (0,0);

		if(length($_) < 8){
			$_ = pack("A8",$_);
		}

		my $j = 8 / length($_);
		for(my $i = 0; $#k < 7; ++$i){
			if($#k + 1 < int($j * $i)){
				push(@k,substr($_,$i - 1,1));
			}
		}

		if(defined($S)){
			push(@s,$S);
		}elsif(length($ENV{SEED})){
			push(@s,$ENV{SEED});
		}elsif(length($ENV{HOSTNAME})){
			push(@s,$ENV{HOSTNAME});
		}
		for(my $i = 0; $i < length($s[2]); ++$i){
			$s[$i & 1] += ord(substr($s[2],$i,1));
		}
		$s[0] = (0..9,a..z,A..Z,qw(+ /))[$s[0] % 64];
		$s[1] = (0..9,a..z,A..Z,qw(+ /))[$s[1] % 64];

		$_ = substr(crypt(join(undef,@k),join(undef,@s[0,1])),-10);
	}elsif($g == 1){
		my @k;

		if(length($_) < 8){
			$_ = pack("A8",$_);
		}

		my $j = 8 / length($_);
		for(my $i = 0; $#k < 7; ++$i){
			if($#k + 1 < int($j * $i)){
				push(@k,substr($_,$i - 1,1));
			}
		}

		$_ = substr(crypt(join(undef,@k),$k[0].$k[7]),-10);
	}else{
		$_ = sprintf("E%d Unknown generating option %s. : -g=<1,2,3>",__LINE__,$g);
	}
	return($_);
}

if(defined(caller(0))){
}elsif($#ARGV != -1){
	foreach(@ARGV){
		print do_pwis();
	}
}else{
	while(<STDIN>){
		chomp();
		print do_pwis();
	}
}

1
