# -*- mode: perl; -*-
# You can install this project with curl -L http://cpanmin.us | perl - https://github.com/hrards/mojo-base-role-insideout/archive/master.tar.gz
requires "perl" => "5.10.0";

requires "Class::Method::Modifiers" => "2.12";
requires "Mojolicious" => "7.60";
requires "Role::Tiny" => "2.000006";

test_requires "Test::More" => "0.88";

on develop => sub {
  requires 'Test::Pod';
  requires 'Test::Pod::Coverage';
  requires 'Test::CPAN::Changes';
};
