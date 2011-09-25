#!/home/acme/perl-5.12.3/bin/perl
use strict;
use warnings;
use Email::Date;
use Email::Folder;
use 5.12.0;

my $folder = Email::Folder->new(shift) || die $!;

my %seen;

while ( my $message = $folder->next_message ) {
    my $date       = $message->header("Date");
    my $time_piece = find_date($message);
    next unless $time_piece->year == 2011;

    my $from       = $message->header("From");
    my $message_id = $message->header("Message-Id");

    next if $seen{$from}++;

    my $ua = $message->header("User-Agent") || $message->header("X-Mailer");
    my $short_ua;
    if ( $ua && $ua =~ m{^([A-Za-z ]+[A-Za-z])} ) {
        $short_ua = $1;
        $short_ua = 'Thunderbird' if $short_ua eq 'Mozilla';
    } elsif ( $message->header('To') eq 'smokers-reports@perl.org' ) {
        $short_ua = 'A Perl smoker';
    } elsif ( $message->header('To') eq 'perl-thanks@perl.org' ) {
        $short_ua = 'perlthanks';
    } elsif ( $message->header('To') eq 'perlbug@perl.org' ) {
        $short_ua = 'perlbug';
    } elsif ( $message->header('From') eq
        'Perl5 Bug Summary <perlbug-summary@perl.org>' )
    {
        $short_ua = 'perlbug-summary';
    } elsif ( $message->header('From') eq
        '"CERT(R) Coordination Center" <cert@cert.org>' )
    {
        $short_ua = 'CERT';
    } elsif ( $ua && $ua eq '/home/nicholas/bin/summary.pl' ) {
        $short_ua = $ua;
    } elsif ( $message_id =~ /mail\.gmail\.com/
        || $message->header('From') =~ /gmail/ )
    {
        $short_ua = 'Gmail';
    } elsif ( $message_id =~ /phx\.gbl/ ) {
        $short_ua = 'Hotmail';
    } elsif ( $message_id =~ /blackberry/ ) {
        $short_ua = 'Blackberry';
    } elsif ( defined $message->header('X-MS-Has-Attach') ) {
        $short_ua = 'Exchange';
    } elsif ( $message->header('X-LinkedIn-Class') ) {
        $short_ua = 'LinkedIn';
    } elsif ( $message->header('X-X-Sender') ) {
        $short_ua = 'Pine';
    } elsif ( $message->header('Mime-Version') =~ /Apple/ ) {
        $short_ua = 'Apple Mail';
    } elsif ( $message->header('RT-Ticket') ) {
        $short_ua = 'RT';
    } elsif ( $message->header('NNTP-Posting-Host') ) {
        $short_ua = 'Google Groups';
    } else {
        warn $message->as_string;
        $short_ua = 'Unknown';
    }
    say $short_ua;
}
