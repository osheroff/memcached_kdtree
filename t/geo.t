#!/usr/bin/perl

use strict;
use Test::More; 
use FindBin qw($Bin);
use lib "$Bin/lib";
use MemcachedTest;


my $server = new_memcached();
my $sock = $server->sock;

my @result;

sub set_key()
{
  my ($key, $val) = @_;
  my $len = length($val);
  print $sock "set $key 0 0 $len\r\n$val\r\n";
  is(scalar <$sock>, "STORED\r\n", "stored $key");
}

&set_key("key_SF1", "val_SF1");
&set_key("key_SF2", "val_SF2");
&set_key("key_NY1", "val_NY1");

print $sock "init_geo geo_1\r\n";
is (scalar <$sock>, "STORED\r\n");


my $geo_data = "37.749001\t-122.426147\tkey_SF1\r\n37.801104\t-122.272339\tkey_SF2\t42.940339\t-74.707031\tkey_3";
#    command = "set_geo #{cache_key} 0 #{expiry} #{value.size}\r\n#{value}\r\n"
my $geo_data_len = length($geo_data);
print $sock "set_geo geo_1 0 0 $geo_data_len\r\n$geo_data\r\n";
is (scalar <$sock>, "STORED\r\n");

# try a query within 25 miles of SF
print $sock "get_geo geo_1 37.748 -122.42 50 1\r\n";
is (scalar <$sock>, "VALUE key_SF1 0 7\r\n", "ok, got back the value correctly");
is (scalar <$sock>, "val_SF1\r\n");
is (scalar <$sock>, "END\r\n");

print $sock "delete geo_1\r\n";
is (scalar <$sock>, "DELETED\r\n");

print $sock "get_geo geo_4 37.748 -122.42 50 1\r\n";
#@result = mem_gets($sock, "foo");
#mem_gets_is($sock,$result[0],"foo","barval");

